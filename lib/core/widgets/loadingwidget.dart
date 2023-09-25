import 'package:flutter/material.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';

class LoadingWidget extends StatelessWidget {
  final bool fallingDot;
  const LoadingWidget({Key? key, this.fallingDot = false}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Center(
      child: fallingDot
          ? LoadingAnimationWidget.fallingDot(
              size: 32, color: Theme.of(context).primaryColor)
          : LoadingAnimationWidget.dotsTriangle(
              size: 32, color: Theme.of(context).primaryColor),
    );
  }
}
