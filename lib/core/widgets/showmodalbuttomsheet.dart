import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

import 'popover.dart';

Future<void> showButtomSheetInfo(
    {BuildContext? context, bool? success, String? desc}) async {
  showModalBottomSheet(
    backgroundColor: Colors.transparent,
    context: context!,
    builder: (context) {
      return Popover(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
          child: Column(
            children: [
              Center(
                child: Lottie.asset(
                    success!
                        ? 'assets/lottie/success.json'
                        : 'assets/lottie/error.json',
                    fit: BoxFit.cover,
                    height: kToolbarHeight * 4),
              ),
              Text(
                success ? 'successful'.tr() : 'oops, failed'.tr(),
                style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 32,
                    color: Theme.of(context).primaryColor),
              ),
              const SizedBox(
                height: 8.0,
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(
                  desc!,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                      color: Theme.of(context)
                          .colorScheme
                          .primary
                          .withOpacity(.8)),
                ),
              ),
              const SizedBox(
                height: 12.0,
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12.0),
                margin: const EdgeInsets.symmetric(vertical: 12.0),
                width: double.infinity,
                height: kToolbarHeight - 10,
                child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      side: BorderSide(
                        color: Theme.of(context).primaryColor,
                        width: 1.0,
                      ),
                      backgroundColor: Theme.of(context).primaryIconTheme.color,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(32.0),
                      ),
                    ),
                    child: Text(
                      success ? 'Ok' : 'try again'.tr(),
                      style: TextStyle(
                          color: Theme.of(context).colorScheme.onPrimary,
                          fontWeight: FontWeight.bold),
                    ),
                    onPressed: () {
                      Navigator.pop(context);
                      if (success) Navigator.pop(context, true);
                    }),
              ),
            ],
          ),
        ),
      );
    },
  );
}
