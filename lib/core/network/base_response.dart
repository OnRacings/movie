import 'package:movie_test_project/core/common/common_function.dart';
import 'package:movie_test_project/core/network/api_caller.dart';
import 'package:movie_test_project/core/network/i_base_response.dart';
import 'package:movie_test_project/core/ui/toast_view.dart';

class BaseResponse extends IBaseResponse {
  int? status;

  String messages = "Đã xảy ra lỗi khi lấy dữ liệu";
  static const String successMessage = "Lấy dữ liệu thành công";
  static const String failureMessage = "Đã xảy ra lỗi khi lấy dữ liệu";
  dynamic data;
  int? errorCode;
  bool? isDefaultMesasge;
  int? messageCode;
  Map<String, dynamic>? rawJson;
  static const int parseError = -1;

  @override
  success(Map<String, dynamic> json, responseData,
      {String message = successMessage}) {
    status = 1;
    messages = message;
    _parserData(responseData, json);
    return this;
  }

  @override
  failure({String message = failureMessage, int? status}) {
    this.status = status ?? 0;
    messages = message;
    return this;
  }

  @override
  bool isValidJson(Map<String, dynamic> json) {
    return json["status"] != null;
  }

  @override
  bool isSuccess(
      {bool isDontShowErrorMessage = false,
      bool isShowSuccessMessage = false,
      void Function(String)? onError}) {
    if (status == BaseApiCaller.cancel) return false;
    if (status != 1 && !isDontShowErrorMessage) {
      showErrorToast(messages);
    }
    if (status == 1 && isShowSuccessMessage) {
      showSuccessToast(isNotNullOrEmpty(messages) ? messages : "Thành công");
    }
    if (status != 1) {
      onError?.call(messages);
    }
    return status == 1;
  }

  BaseResponse();

  @override
  fromJson(Map<String, dynamic> json, dynamic responseData,
      {String dataKey = "data"}) {
    try {
      rawJson = json;
      status = json['status'];
      messages = getResponseMessage(json);
      errorCode = getErrorCode(json);
      isDefaultMesasge = true;
      _parserData(responseData, json[dataKey]);
      if (isNotNullOrEmpty(json['messages'])) {
        if (json['messages'] is String) {
          isDefaultMesasge = false;
        } else if (json['messages'] is List<String>) {
          isDefaultMesasge = false;
        } else {
          isDefaultMesasge = false;
          messageCode = json['messages'][0]['type'];
        }
      }
    } catch (e) {
      status = parseError;
      messages = "Có lỗi khi phân tích gói tin ($status)";
      print(e.toString());
    }
    return this;
  }

  void _parserData(responseData, Map<String, dynamic> json) {
    try {
      if (responseData != null && json != null) {
        if (json is List) {
          responseData.fromJson(json);
          data = responseData;
        } else {
          responseData.fromJson(json);
          data = responseData;
        }
      }
    } catch (ex) {
      status = parseError;
      messages = "Có lỗi khi phân tích gói tin ($status)";
      print(ex.toString());
    }
  }
}

String getResponseMessage(Map<String, dynamic> json) {
  if (BaseApiCaller.cancel == json["status"]) {
    return "Bạn đã hủy yêu cầu";
  }
  String messages = json["status"] == 1
      ? BaseResponse.successMessage
      : BaseResponse.failureMessage;
  if (isNotNullOrEmpty(json['messages'])) {
    if (json['messages'] is String) {
      messages = json['messages'];
    } else if (json['messages'] is List<String>) {
      messages = json['messages'].join("\n");
    } else {
      messages = (json['messages'] as List)
          .map((e) => e["content"])
          .toList()
          .join("\n");
    }
  }
  return messages;
}

int? getErrorCode(Map<String, dynamic> json) {
  if (json["status"] == 1) return null;
  if (isNotNullOrEmpty(json['messages']) &&
      json['messages'] is List &&
      json['messages'][0]['type'] != null) {
    return json['messages'][0]['type'];
  }
  return null;
}
