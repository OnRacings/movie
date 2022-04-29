import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:cookie_jar/cookie_jar.dart';
import 'package:dio/adapter.dart';
import 'package:dio/dio.dart';
import 'package:movie_test_project/core/common/common_function.dart';
import 'package:movie_test_project/core/network/base_response.dart';
import 'package:movie_test_project/core/network/i_base_response.dart';
import 'package:movie_test_project/core/network/request_manager.dart';
import 'package:dio_cookie_manager/dio_cookie_manager.dart';

import '../../main.dart';

typedef ProgressListener = void Function(int total, int progress, int percent);

class BaseApiCaller<T> {
  static late BaseApiCaller _instance = BaseApiCaller();
  String directory = "";
  static const int timeout_code = 900;
  static const int dio_error_default = 901;
  static const int dio_error_response = 902;
  static const int dio_error_no_reason = 903;
  static const int cancel = 904;
  ParamType paramType = ParamType.json;

  static BaseApiCaller get instance {
    if (getIt.isRegistered<BaseApiCaller>()) return getIt.get<BaseApiCaller>();
    return _instance;
  }
  Future<String> getToken() async{
    return "";
  }
  Future<String> getBaseUrl() async{
    return "";
  }
  BaseApiCaller() {
    _dio = Dio();
    (_dio.httpClientAdapter as DefaultHttpClientAdapter).onHttpClientCreate =
        (client) {
      client.badCertificateCallback =
          (X509Certificate cert, String host, int port) {
        return true;
      };
    };
    _dio.interceptors
        .add(InterceptorsWrapper(onRequest: (options, handler) async {
      String? token = await getToken();
      var customHeaders = {
        'Content-type': 'application/json',
        'Authorization': "Bearer $token"
      };
      String? baseUrl = await getBaseUrl();
      options.responseType = ResponseType.plain;
      options.connectTimeout = 30000;
      options.receiveTimeout = 30000;
      options.sendTimeout = 30000;
      options.headers.addAll(customHeaders);
      return handler.next(options);
    }));
    _dio.interceptors.add(LogInterceptor(responseBody: true));
  }
  IBaseResponse getBaseResponse() {
    return BaseResponse();
  }

  RequestInfo getRequestInfo(
      {bool isShowLoading: true,
      bool isShowImmediate: false,
      dynamic requestGroup}) {
    return DioRequestInfo(
        isShowLoading: isShowLoading, isShowImmediate: isShowImmediate);
  }

  late Dio _dio;

  Future<T> get(String path, dynamic responseData,
      {required Map<String, dynamic> params,
      bool isLoading = true,
      dynamic requestGroup,
      RequestInfo? requestInfo}) async {
    _printParams(params, path);
    requestInfo ??=
        getRequestInfo(isShowLoading: isLoading, requestGroup: requestGroup);
    addRequest(requestInfo);
    var responseJson;
    try {
      Response response = await _dio.get(path,
          queryParameters: params,
          cancelToken: (requestInfo as DioRequestInfo).cancelToken);
      responseJson = parserResponse(response, params, responseData);
    } on DioError catch (ex) {
      return errorException(dioError: ex);
    } on Exception {
      return errorException();
    } finally {
      removeRequest(requestInfo);
    }
    return responseJson;
  }

  String _printParams(Map<String, dynamic> params, String path,
      {bool isJson = false}) {
    if (isNullOrEmpty(params)) {
      print("param for $path:   $params");
      return "";
    }
    String result = "";
    if (isJson == false) {
      StringBuffer sb = StringBuffer();
      for (String key in params.keys) {
        if (params[key] is! Map)
          sb.write('"$key":"${params[key]}",\n');
        else {
          sb.write('"$key":${_printParams(params[key], path)},\n');
        }
      }
      result = sb.toString();
    } else {
      try {
        result = jsonEncode(params);

        int count = (result.length / 900).ceil();
        int end = 0;
        for (int i = 0; i < count; i++) {
          end = (i + 1) * 900;
          if (end > result.length) {
            end = result.length;
          }
          print("param for $path[$i]:  ${result.substring(i * 900, end)}");
        }
      } catch (e) {
        print(e);
      }
    }
    return result;
  }

  int getTotalPage(Map<String, dynamic> json) {
    if (json["status"] == 0 || json["data"]?["paging"]?["pageTotal"] == null) {
      return 0;
    }
    return json["data"]["paging"]["pageTotal"];
  }

  void addPagingToParams(
      int pageSize, int pageIndex, Map<String, dynamic> params,
      {String? pageSizeKey, String? pageIndexKey}) {
    if (params["Paging"] == null) {
      params["Paging"] = {
        pageSizeKey ?? "NumberOfPage": pageSize,
        pageIndexKey ?? "Page": pageIndex
      };
    }
  }

  void onTokenExpired() {}

  T parserResponse(
      Response response, Map<String, dynamic>? params, dynamic responseData) {
    switch (response.statusCode) {
      case 200:
        var responseJson = json.decode(response.data.toString());
        if(getBaseResponse().isValidJson(responseJson)) {
          T baseResponse =
              getBaseResponse().fromJson(responseJson, responseData);
          return baseResponse;
        }else{
          return getBaseResponse().success(responseJson,responseData!);
        }
      case 400:
        return getErrorResponse(
            message: "Cú pháp không hợp lệ", code: response.statusCode!);
      case 401:
      case 403:
        onTokenExpired();
        return getErrorResponse(
            message: "Có vấn đề khi xác thực trong tài khoản của bạn",
            code: response.statusCode!);
      case 404:
        return getErrorResponse(
            message: "Không thể truy cập đến máy chủ",
            code: response.statusCode!);
      case 500:
      case 504:
        return getErrorResponse(
            message: "Máy chủ gặp lỗi", code: response.statusCode!);
      default:
        return getErrorResponse(
            message: "Kết nối đến máy chủ thất bại",
            code: response.statusCode!);
    }
  }

  Future<T> errorException(
      {String message: "Kết nối đến máy chủ thất bại.",
      DioError? dioError,
      int code: 0}) async {
    String resultCode = "";
    if (dioError != null) {
      switch (dioError.type) {
        case DioErrorType.cancel:
          {
            message = "";
            code = cancel;
            return getErrorResponse(
                message: message, code: code, isNotAddCode: true);
          }
        case DioErrorType.connectTimeout:
        case DioErrorType.receiveTimeout:
        case DioErrorType.sendTimeout:
          {
            message = "Máy chủ không phản hồi";
            code = timeout_code;
            break;
          }
        case DioErrorType.other:
          {
            if (dioError.error is SocketException &&
                isNotNullOrEmpty(dioError.error?.osError?.errorCode))
              resultCode = " (${dioError.error?.osError?.errorCode})";
            message = "Không tìm thấy máy chủ$resultCode";
            code = dio_error_default;
            return getErrorResponse(
                message: message, code: code, isNotAddCode: true);
          }
        case DioErrorType.response:
          {
            return parserResponse(dioError.response!, null, null);
          }
      }
    }
    return getErrorResponse(message: message, code: code);
  }

  T getErrorResponse({String? message, int? code, bool isNotAddCode: false}) {
    String stringCode = " ($code).";
    if (code == timeout_code) {
      stringCode = " (timeout)";
    }
    return getBaseResponse().failure(status: code,message:"$message${isNotAddCode ? "" : stringCode}" );
  }

  addRequest(RequestInfo requestInfo) async {
    await RequestManager.instance.addRequest(requestInfo);
  }

  removeRequest(RequestInfo requestInfo) async {
    await RequestManager.instance.removeRequest(requestInfo);
  }
}

enum ParamType { json, map }
