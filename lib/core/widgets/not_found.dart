import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

class NotFound extends StatelessWidget {
  const NotFound({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SizedBox(
        height: MediaQuery.of(context).size.width / 2,
        child: Column(
          children: [
            Lottie.asset(
              'assets/lottie/not-found.json',
              fit: BoxFit.cover,
              height: MediaQuery.of(context).size.width / 2.2,
            ),
            Text(
              'page error'.tr(),
              style: TextStyle(color: Theme.of(context).disabledColor),
            )
          ],
        ),
      ),
    );
  }
}
