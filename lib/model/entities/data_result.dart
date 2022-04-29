abstract class ResultData<T> {
  final int? status;
  final T? data;
  final String? message;

  ResultData({this.status, this.data, this.message});
}

class SuccessResultData<T> extends ResultData<T> {
  final T? data;
  final String? message;
  final int? status;

  SuccessResultData({this.data, this.message, this.status = 1})
      : super(data: data, message: message);
}

class ErrorResultData<T> extends ResultData<T> {
  final String? message;
  late final int? status;
  final T? data;

  ErrorResultData({this.message, this.data, this.status = 0})
      : super(message: message, status: status, data: data);
}
