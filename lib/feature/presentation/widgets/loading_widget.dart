import 'package:flutter/material.dart';
import 'package:news/common/app_colors.dart';

class LoadingWidget extends StatelessWidget {
  const LoadingWidget({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: SizedBox(
        child: CircularProgressIndicator(
          color: AppColors.orangeColor,
        ),
      ),
    );
  }
}
