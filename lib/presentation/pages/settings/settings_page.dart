import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:jobless/core/widgets/listcustom.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        titleSpacing: 0,
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: ClipRRect(
            borderRadius: const BorderRadius.all(Radius.circular(8)),
            child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
                color: Theme.of(context).primaryColor.withOpacity(.1),
                child: Icon(
                  Icons.arrow_back_ios,
                  color: Theme.of(context).primaryColor,
                )),
          ),
        ),
        title: Text(
          'settings'.tr(),
          style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
      ),
      body: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8.0),
              child: Column(
                children: [
                  ListCustom(
                    icon: Icons.line_style_rounded,
                    color: Theme.of(context).primaryIconTheme.color,
                    title: 'categories'.tr(),
                    onTap: () {
                      Navigator.pushNamed(context, '/settings-categories');
                    },
                  ),
                  ListCustom(
                    icon: Icons.list_alt_outlined,
                    color: Theme.of(context).primaryIconTheme.color,
                    title: 'industrialtype'.tr(),
                    onTap: () {
                      Navigator.pushNamed(context, '/profile-form-employers');
                    },
                  ),
                ],
              ))),
    );
  }
}
