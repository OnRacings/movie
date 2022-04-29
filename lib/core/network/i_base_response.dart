import 'package:flutter/material.dart';

abstract class IBaseResponse {
  bool isValidJson(Map<String, dynamic> json);

  success(Map<String, dynamic> json, responseData, {String message});

  failure({String message, int? status});

  bool isSuccess(
      {bool isDontShowErrorMessage = false,
      bool isShowSuccessMessage = false,
      void Function(String)? onError});

  fromJson(Map<String, dynamic> json, dynamic responseData);
}
