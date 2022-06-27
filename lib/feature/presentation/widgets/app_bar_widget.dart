import 'package:flutter/material.dart';
import 'package:news/common/app_colors.dart';

class AppBarWidget extends StatelessWidget {
  const AppBarWidget({Key? key, required this.title}) : super(key: key);
  final String title;

  @override
  Widget build(BuildContext context) {
    return AppBar(
      centerTitle: true,
      backgroundColor: AppColors.appBarColor,
      title: Text(
        title,
        style: Theme.of(context).textTheme.headline1,
      ),
      elevation: 0,
    );
  }
}
