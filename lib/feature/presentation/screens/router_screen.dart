import 'package:flutter/material.dart';
import 'package:news/feature/presentation/screens/news_screen.dart';
import 'package:provider/provider.dart';
import '../state/authentication_state.dart';
import 'login_screen.dart';

class RouterScreen extends StatefulWidget {
  const RouterScreen({Key? key}) : super(key: key);

  @override
  State<RouterScreen> createState() => _RouterScreenState();
}

class _RouterScreenState extends State<RouterScreen> {
  @override
  Widget build(BuildContext context) {
    final user = Provider.of<AuthenticationState>(context, listen: false).currentUser;

    return user == null ? const LoginScreen() : const NewsScreen();
  }
}
