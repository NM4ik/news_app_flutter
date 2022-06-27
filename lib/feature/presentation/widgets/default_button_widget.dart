import 'package:flutter/material.dart';
import 'package:news/common/app_colors.dart';

import '../../../common/app_variables.dart';

class DefaultButtonWidget extends StatelessWidget {
  const DefaultButtonWidget({Key? key, required this.function, required this.title}) : super(key: key);
  final VoidCallback function;
  final String title;

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: function,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 45),
        child: Text(
          title,
          style: Theme.of(context).textTheme.bodyText1,
        ),
      ),
      style: ElevatedButton.styleFrom(
        primary: AppColors.orangeColor,
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppVariables.kBorder * 1.5)),
      ),
    );
  }
}
