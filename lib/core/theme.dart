import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:jobless/core/config.dart';

class ThemeModel {
  final lightTheme = ThemeData(
    primarySwatch: Colors.blue,
    primaryColor: Config().appThemeColor,
    scaffoldBackgroundColor: Colors.white,
    shadowColor: Colors.grey[200],
    brightness: Brightness.light,
    fontFamily: GoogleFonts.montserrat().fontFamily,
    colorScheme: ColorScheme.light(
        primary: Colors.black.withOpacity(.8), //text
        secondary: Colors.blueGrey[600]!, //text
        onPrimary: Colors.white, //card -1
        onSecondary: Colors.grey[100]!, //card -2
        primaryContainer: Colors.grey[200]!, //card color -3
        secondaryContainer: Colors.grey[300]!, //card color -4
        surface: Colors.grey[300]!, //shadow color -1
        onBackground: Colors.grey.shade200, //loading card color
        background: Config().appThemeColor),
    dividerColor: Colors.grey[300],
    iconTheme: IconThemeData(color: Colors.grey[900]),
    primaryIconTheme: IconThemeData(
      color: Config().appThemeColor,
    ),
    appBarTheme: AppBarTheme(
      color: Colors.white,
      elevation: 0,
      titleTextStyle: TextStyle(
          fontSize: 16,
          fontFamily: GoogleFonts.montserrat().fontFamily,
          fontWeight: FontWeight.w600,
          color: Colors.grey[800]),
      iconTheme: IconThemeData(color: Colors.grey[900]),
      actionsIconTheme: IconThemeData(color: Colors.grey[900]),
      centerTitle: false,
      systemOverlayStyle: SystemUiOverlayStyle.dark,
    ),
    bottomNavigationBarTheme: BottomNavigationBarThemeData(
      backgroundColor: Colors.transparent,
      selectedItemColor: Config().appThemeColor,
      unselectedItemColor: Colors.blueGrey[200],
    ),
    popupMenuTheme: PopupMenuThemeData(
      textStyle: TextStyle(
        color: Colors.grey[900],
        fontWeight: FontWeight.w500,
        fontFamily: GoogleFonts.montserrat().fontFamily,
      ),
    ),
  );

  final darkTheme = ThemeData(
    //visualDensity: VisualDensity.adaptivePlatformDensity,
    primarySwatch: Colors.blue,
    primaryColor: Config().appThemeColor,
    scaffoldBackgroundColor: const Color(0xff303030),
    shadowColor: Colors.grey[850],
    brightness: Brightness.dark,
    fontFamily: GoogleFonts.montserrat().fontFamily,
    colorScheme: ColorScheme.dark(
        primary: Colors.white, //text
        secondary: Colors.blueGrey[200]!, //text
        onPrimary: Colors.grey[800]!, //card color -1
        onSecondary: Colors.grey[800]!, //card color -2
        primaryContainer: Colors.grey[800]!, //card color -3
        secondaryContainer: Colors.grey[800]!, //card color -4
        surface: const Color(0xff303030), //shadow color - 1
        onBackground: Colors.grey[700]!, //loading card color
        background: Colors.white),
    dividerColor: Colors.grey[300],
    iconTheme: const IconThemeData(color: Colors.white),
    primaryIconTheme: const IconThemeData(
      color: Colors.white,
    ),
    appBarTheme: AppBarTheme(
        color: const Color(0xff303030),
        elevation: 0,
        titleTextStyle: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            fontFamily: GoogleFonts.montserrat().fontFamily,
            color: Colors.white),
        iconTheme: const IconThemeData(color: Colors.white),
        actionsIconTheme: const IconThemeData(color: Colors.white),
        centerTitle: false,
        systemOverlayStyle: SystemUiOverlayStyle.light),

    bottomNavigationBarTheme: BottomNavigationBarThemeData(
      backgroundColor: Colors.transparent,
      selectedItemColor: Colors.white,
      unselectedItemColor: Colors.grey[500],
    ),

    popupMenuTheme: PopupMenuThemeData(
      textStyle: TextStyle(
          color: Colors.white,
          fontFamily: GoogleFonts.montserrat().fontFamily,
          fontWeight: FontWeight.w500),
    ),
  );
}
