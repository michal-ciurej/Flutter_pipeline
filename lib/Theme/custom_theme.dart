import 'package:alerts/Utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter_login/theme.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:material_color_utilities/material_color_utilities.dart';

import 'colors.dart';

class CustomTheme {


  static ThemeData get lightTheme { //1




      TextTheme: TextTheme(

      headline1: GoogleFonts.roboto(
          fontSize: 97, fontWeight: FontWeight.w300, letterSpacing: -1.5, color: Colors.black),
      headline2: GoogleFonts.roboto(
          fontSize: 61, fontWeight: FontWeight.w300, letterSpacing: -0.5, color: Colors.black),
      headline3: GoogleFonts.roboto(fontSize: 48, fontWeight: FontWeight.w400),
      headline4: GoogleFonts.roboto(
          fontSize: 34, fontWeight: FontWeight.w400, letterSpacing: 0.25),
      headline5: GoogleFonts.roboto(fontSize: 24, fontWeight: FontWeight.w600),
      headline6: GoogleFonts.roboto(fontSize: 20, fontWeight: FontWeight.bold),
      subtitle1: GoogleFonts.roboto(
          fontSize: 16, fontWeight: FontWeight.w400, letterSpacing: 0.15),
      subtitle2: GoogleFonts.roboto(
          fontSize: 14, fontWeight: FontWeight.w600, letterSpacing: 0.1),
      bodyText1: GoogleFonts.roboto(
          fontSize: 16, fontWeight: FontWeight.w400, letterSpacing: 0.5),
      bodyText2: GoogleFonts.roboto(
          fontSize: 14, fontWeight: FontWeight.w200, letterSpacing: 0.25),
      button: GoogleFonts.roboto(
          fontSize: 14, fontWeight: FontWeight.w500, letterSpacing: 1.25),
      caption: GoogleFonts.roboto(
          fontSize: 12, fontWeight: FontWeight.w400, letterSpacing: 0.4),
      overline: GoogleFonts.roboto(
          fontSize: 10, fontWeight: FontWeight.w400, letterSpacing: 1.5),
    );


    return ThemeData( //2

        primarySwatch: createMaterialColor(Color(0xFF136d1b)),
        primaryColor: Color(0xFF136d1b),
        //primaryColor: Color(0xFF25b432),
        fontFamily: 'Roboto',
        scaffoldBackgroundColor: Colors.white,
        textTheme: TextTheme(

          headline1: GoogleFonts.roboto(
              fontSize: 97, fontWeight: FontWeight.w300, letterSpacing: -1.5, color: Colors.black),
          headline2: GoogleFonts.roboto(
              fontSize: 61, fontWeight: FontWeight.w300, letterSpacing: -0.5, color: Colors.black),
          headline3: GoogleFonts.roboto(fontSize: 48, fontWeight: FontWeight.w400),
          headline4: GoogleFonts.roboto(
              fontSize: 34, fontWeight: FontWeight.w400, letterSpacing: 0.25),
          headline5: GoogleFonts.roboto(fontSize: 24, fontWeight: FontWeight.w600),
          headline6: GoogleFonts.roboto(fontSize: 20, fontWeight: FontWeight.bold),
          subtitle1: GoogleFonts.roboto(
              fontSize: 16, fontWeight: FontWeight.w400, letterSpacing: 0.15),
          subtitle2: GoogleFonts.roboto(
              fontSize: 14, fontWeight: FontWeight.w500, letterSpacing: 0.1),
          bodyText1: GoogleFonts.roboto(
              fontSize: 16, fontWeight: FontWeight.w400, letterSpacing: 0.5),
          bodyText2: GoogleFonts.roboto(
              fontSize: 14, fontWeight: FontWeight.w400, letterSpacing: 0.25),
          button: GoogleFonts.roboto(
              fontSize: 14, fontWeight: FontWeight.w500, letterSpacing: 1.25),
          caption: GoogleFonts.roboto(
              fontSize: 12, fontWeight: FontWeight.w400, letterSpacing: 0.4),
          overline: GoogleFonts.roboto(
              fontSize: 10, fontWeight: FontWeight.w400, letterSpacing: 1.5),
        ),


      iconTheme: const IconThemeData(
      color: Color(0xFF136d1b), //change your color here
    )




        //


    );



  }
}