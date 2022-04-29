import 'package:flutter/material.dart';

class ListMoveRequestParams {
  int? page;
  String? apiKey;

  Map<String, dynamic> getParams() {
    return {"page": page, "api_key": apiKey};
  }
}
