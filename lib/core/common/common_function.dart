import 'package:flutter/material.dart';

bool isNullOrEmpty(dynamic object) {
  if (object == null) return true;
  if (object is String) {
    return object.isEmpty;
  }
  if (object is List) {
    return object.length == 0;
  }
  if (object is Map) {
    return object.length == 0;
  }
  if (object is Set) {
    return object.length == 0;
  }
  return false;
}

bool isNotNullOrEmpty(dynamic object) {
  return !isNullOrEmpty(object);
}

bool isNullOrZero(dynamic object) {
  if (object == null) return true;
  if (object is int || object is double) {
    if (object == 0) return true;
  }
  return isNullOrEmpty(object);
}
