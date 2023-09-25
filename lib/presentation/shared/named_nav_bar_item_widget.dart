import 'package:flutter/cupertino.dart';
import 'package:jobless/core/widgets/bottom_navy_bar.dart';

class NamedNavigationBarItemWidget extends BottomNavyBarItem {
  final Widget? screen;

  NamedNavigationBarItemWidget(
      {required this.screen,
      required Widget icon,
      required Widget title,
      TextAlign? textAlign})
      : super(icon: icon, title: title, textAlign: textAlign);
}
