import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:synchronized/synchronized.dart' as sync;

import '../../main.dart';

class RequestManager {
  static final RequestManager instance = RequestManager._internal();
  List<RequestInfo> _requests = [];

  RequestManager._internal();

  var _lockAddRemove = sync.Lock();
  var _lockCancel = sync.Lock();

  Future<void> addRequest(RequestInfo requestInfo) async {
    await _lockAddRemove.synchronized(() async {
      _requests.add(requestInfo);
      if (requestInfo.isShowLoading) {
        loadingDialog.show(
            isShowImmediate: requestInfo is DioRequestInfo
                ? requestInfo.isShowImmediate
                : false);
      }
    });
  }

  Future<bool> removeRequest(RequestInfo requestInfo) async {
    return await _lockAddRemove.synchronized(() async {
      bool contained = _requests.contains(requestInfo);
      _requests.remove(requestInfo);
      if (contained) {
        if (requestInfo.isShowLoading) loadingDialog.hide();
      }
      return true;
    });
  }

  Future<bool> cancelRequest(RequestInfo requestInfo) async {
    return await _lockCancel.synchronized(() async {
      await requestInfo.cancelRequest();
      if (requestInfo.isShowLoading) loadingDialog.hide();
      return true;
    });
  }

  Future<bool> cancelAll() async {
    for (var requestInfo in _requests) {
      await cancelRequest(requestInfo);
      if (requestInfo.isShowLoading) loadingDialog.hide();
    }
    return true;
  }

  Future<bool> cancelByGroup(dynamic group) async {
    for (var requestInfo in _requests) {
      if (requestInfo.requestGroup != group) continue;
      await cancelRequest(requestInfo);
      if (requestInfo.isShowLoading) loadingDialog.hide();
    }
    return true;
  }
}

class DioRequestInfo extends RequestInfo {
  late CancelToken cancelToken;
  bool isShowImmediate = false;

  DioRequestInfo(
      {CancelToken? cancelToken,
      this.isShowLoading = true,
      dynamic requestGroup,
      this.isShowImmediate = false})
      : super(isShowLoading: isShowLoading, requestGroup: requestGroup) {
    this.cancelToken = cancelToken ?? CancelToken();
  }

  @override
  Future<bool> cancelRequest() async {
    cancelToken.cancel("You canceled this request");
    await RequestManager.instance.removeRequest(this);
    return true;
  }

  @override
  bool isShowLoading;
}

abstract class RequestInfo {
  bool isShowLoading = true;
  dynamic requestGroup;

  RequestInfo({this.isShowLoading = true, this.requestGroup});

  Future<bool> cancelRequest();
}
