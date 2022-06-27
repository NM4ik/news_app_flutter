import 'package:flutter/material.dart';
import 'package:news/common/app_colors.dart';
import 'package:news/common/app_variables.dart';
import 'package:news/feature/presentation/screens/news_screen.dart';
import 'package:news/feature/presentation/state/authentication_state.dart';
import 'package:news/feature/presentation/widgets/route_animation.dart';
import 'package:provider/provider.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({Key? key}) : super(key: key);

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  @override
  Widget build(BuildContext context) {
    final state = context.watch<AuthenticationState>();

    final Shader linearGradient = const LinearGradient(
      colors: <Color>[Color(0xff7D7D7D), Color(0xffFFFFFF)],
    ).createShader(const Rect.fromLTWH(0.0, 0.0, 300, 0));

    return Scaffold(
      backgroundColor: AppColors.scaffoldBackgroundColor,
      body: SafeArea(
          minimum: const EdgeInsets.symmetric(vertical: AppVariables.kEdgeVerticalPadding, horizontal: AppVariables.kEdgeHorizontalPadding),
          child: Center(
              child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Spacer(),
              Text(
                'МОИ\nНОВОСТИ',
                style: Theme.of(context).textTheme.headline1!.copyWith(
                      fontSize: 41,
                      foreground: Paint()..shader = linearGradient,
                    ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(
                height: 10,
              ),
              Text(
                'добро пожаловать',
                style: Theme.of(context).textTheme.bodyText2!.copyWith(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const Spacer(),
              ElevatedButton(
                  onPressed: () async {
                    await state.googleSignIn();
                    Navigator.of(context).pushReplacement(createRouteAnimFromBottom(const NewsScreen()));
                  },
                  style:
                      ElevatedButton.styleFrom(primary: Colors.white, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppVariables.kBorder))),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 80),
                    child: state.isLoading
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              color: AppColors.orangeColor,
                              strokeWidth: 3,
                            ))
                        : Text(
                            'Вход',
                            style: Theme.of(context).textTheme.bodyText1!.copyWith(color: Colors.black, fontSize: 16, fontWeight: FontWeight.bold),
                          ),
                  )),
              const Spacer(),
            ],
          ))),
    );
  }
}
