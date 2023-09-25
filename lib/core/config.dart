import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class Config {
  static const appName = 'Jobless';
  static String fcmToken = '';
  static const baseUrl = 'http://192.168.1.10:8080';
  static const imageTips = 'uploads/tips';
  static const imageEmployee = 'uploads/employee';
  static const imageEmployers = 'uploads/employers';
  static const imageGallery = 'uploads/gallery';
  static const resume = 'uploads/applicants';
  static const supportEmail = 'fan.fantasi@gmail.com';
  static const privacyPolicyUrl = 'https://www.mrb-lab.com/privacy-policy';
  static const iOSAppID = '000000';
  final number = NumberFormat("###,###");
  //app theme color
  final Color appThemeColor = Colors.blueAccent;

  //languages
  static const List<String> languages = ['English', 'Indonesia'];

  static const darkLogo = 'assets/icons/jobless_dark.svg';
  static const lightLogo = 'assets/icons/jobless.svg';

  static bool isLoadedLocation = false;
  static bool isLoadedCategories = false;
  static bool isLoadedTypeVacancy = false;

  static bool isChangeTab = false;
  static String params = '';
  static String recommended = '';

  static bool isError = false;
}
