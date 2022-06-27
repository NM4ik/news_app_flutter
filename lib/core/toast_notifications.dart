import 'package:bot_toast/bot_toast.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:news/common/app_colors.dart';

class BotToastNotification {
  static void showInfo(String title) => BotToast.showSimpleNotification(
      title: title, backgroundColor: AppColors.orangeColor, titleStyle: GoogleFonts.inter(color: Colors.white, fontSize: 14, fontWeight: FontWeight.normal));
  static void showError(String title) => BotToast.showSimpleNotification(
      title: title, backgroundColor: Colors.red, titleStyle: GoogleFonts.inter(color: Colors.white, fontSize: 14, fontWeight: FontWeight.normal));
}
