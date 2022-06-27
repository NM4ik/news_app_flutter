import 'dart:developer';

import 'package:bot_toast/bot_toast.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:news/common/app_theme.dart';
import 'package:news/feature/data/models/user_model.dart';
import 'package:news/feature/data/repository/user_repository.dart';
import 'package:news/feature/presentation/screens/news_screen.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:news/feature/presentation/screens/login_screen.dart';
import 'package:news/feature/presentation/screens/router_screen.dart';
import 'package:news/locator_service.dart' as locator;
import 'package:intl/date_symbol_data_local.dart';
import 'package:provider/provider.dart';

import 'feature/presentation/state/authentication_state.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    name: "newsApp",
    options: const FirebaseOptions(
        apiKey: "AIzaSyBPZQkW0p_YTCCwo-gnVYkqzsf5VxdLNrY",
        appId: "1:464287590982:android:fe38eafa70fd07a1703847",
        messagingSenderId: "464287590982",
        projectId: "newsapp-5614b"),
  );
  await locator.init();
  initializeDateFormatting('ru');
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthenticationState()),
      ],
      child: MaterialApp(
        builder: BotToastInit(),
        navigatorObservers: [BotToastNavigatorObserver()],
        debugShowCheckedModeBanner: false,
        theme: MyTheme.mainTheme,
        home: const RouterScreen(),
      ),
    );
  }
}
