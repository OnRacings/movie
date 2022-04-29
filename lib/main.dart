import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:movie_test_project/common/di.dart';
import 'package:movie_test_project/core/ui/loading_dialog.dart';
import 'package:movie_test_project/screens/list_movie_screen.dart';
import 'package:movie_test_project/screens/splash_screen.dart';

late final LoadingDialog loadingDialog;
GlobalKey<NavigatorState> navigationKey = GlobalKey();
GetIt getIt = GetIt.instance;

void main() {
  inject();
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance?.addPostFrameCallback((timeStamp) {

      Future.delayed(Duration(seconds: 1)).then((value) {
       LoadingDialog.init(navigationKey.currentContext!);
       loadingDialog=LoadingDialog.getInstance();
        Navigator.pushReplacement(
            navigationKey.currentContext!,
            MaterialPageRoute(
              builder: (context) => const ListMovieScreen(),
            ));
      });
    });

  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      navigatorKey: navigationKey,
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const SplashScreen(),
    );
  }
}
