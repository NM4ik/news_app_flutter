import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class MyTheme{
  static ThemeData mainTheme = ThemeData(

    textTheme: TextTheme(
      headline1: GoogleFonts.inter(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white, ),
      headline2: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.white, ),
      bodyText1: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w400, color: Colors.white, ),
      bodyText2: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w500, color: const Color(0xFFBBBBBB), ),
    )
  );
}