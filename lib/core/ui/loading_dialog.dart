import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:movie_test_project/core/network/request_manager.dart';
import 'package:synchronized/synchronized.dart';

class LoadingDialog {
  static final LoadingDialog _instance=LoadingDialog._private();

  var _lock = Lock();
  bool _isShowing = false;
  static void init(BuildContext context){
    _instance.context=context;
  }
  static LoadingDialog getInstance() {
    return _instance;
  }

  int totalLoading = 0;

  late BuildContext context;

  LoadingDialog._private() ;

  show({bool isShowImmediate = false}) async {
    await _lock.synchronized(() async {
      totalLoading++;
      if (isShowImmediate == true) {
        if (!_isShowing) {
          _showLoading();
          _isShowing = true;
        }
      } else if (totalLoading == 1 && !_isShowing) {
        WidgetsBinding.instance!.addPostFrameCallback((timeStamp) {
          if (totalLoading > 0 && !_isShowing) {
            _showLoading();
            _isShowing = true;
          }
        });
      }
      // }
    });
  }

  hide() async {
    await _lock.synchronized(() async {
      if (totalLoading == 0) return;
      totalLoading--;
      if (totalLoading == 0 && _isShowing) {
        _hideLoading();
        _isShowing = false;
      }
    });
  }

  clear() {
    while (totalLoading > 0) {
      hide();
    }
  }

  _showLoading() async {
     showDialog<void>(
        context: context,
        barrierDismissible: false,

        builder: (BuildContext context) {
          return Theme(
              data: Theme.of(context).copyWith(
                dialogBackgroundColor: Colors.transparent,
                shadowColor: Colors.transparent,
              ),
              child: AlertDialog(
                  contentPadding: EdgeInsets.zero,
                  content: Center(
                    child: Container(
                      width: 70,
                      height: 70,
                      padding: EdgeInsets.all(16),
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.all(Radius.circular(8)),
                          color: Colors.white),
                      child: CircularProgressIndicator(
                        valueColor:
                        AlwaysStoppedAnimation<Color>(Colors.grey),
                      ),
                    ),
                  )));
        }).whenComplete(() {
      totalLoading = 0;
      _isShowing = false;
      RequestManager.instance.cancelAll();
    });
  }

  _hideLoading() {
    Navigator.of(context, rootNavigator: true).pop(); //close the dialoge
  }
}
