import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:jobless/core/config.dart';
import 'package:jobless/core/widgets/list_widget.dart';
import 'package:jobless/core/widgets/loadingwidget.dart';
import 'package:jobless/core/widgets/popover.dart';
import 'package:jobless/presentation/bloc/theme/theme_cubit.dart';
import 'package:jobless/presentation/bloc/user/user_cubit.dart';
import 'package:photo_gallery/photo_gallery.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../gallery/gallery_page.dart';

class ProfileEmployeePage extends StatefulWidget {
  const ProfileEmployeePage({super.key});

  @override
  State<ProfileEmployeePage> createState() => _ProfileEmployeePageState();
}

class _ProfileEmployeePageState extends State<ProfileEmployeePage> {
  File? photoProfile;
  Medium? mediumSelected;

  void logout() async {
    FirebaseMessaging.instance
        .unsubscribeFromTopic(context.read<UserCubit>().user!.id!);
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.clear();
    if (!mounted) return;

    Navigator.pushNamedAndRemoveUntil(context, '/', (route) => false);
  }

  Future<void> openMediaModal() async {
    final action = CupertinoActionSheet(
      actions: [
        Material(
          child: Column(
            children: [
              InkWell(
                onTap: () {},
                child: Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 16.0, vertical: 16.0),
                  child: Row(
                    children: [
                      Icon(CupertinoIcons.photo_camera,
                          color: Colors.blue[400]),
                      const SizedBox(
                        width: 10.0,
                      ),
                      Text(
                        "camera".tr(),
                        style: const TextStyle(fontSize: 16),
                      ),
                    ],
                  ),
                ),
              ),
              InkWell(
                onTap: () async {
                  Navigator.pop(context);
                  Medium? medium = await Navigator.push(
                    context,
                    CupertinoPageRoute(
                      builder: (context) => const GalleryPage(),
                    ),
                  );
                  if (medium != null) {
                    final File file = await medium.getFile();
                    setState(() {
                      photoProfile = file;
                      mediumSelected = medium;
                    });
                  }
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 16.0, vertical: 16.0),
                  child: Row(
                    children: [
                      Icon(CupertinoIcons.photo_fill_on_rectangle_fill,
                          color: Colors.blue[400]),
                      const SizedBox(
                        width: 10.0,
                      ),
                      Text(
                        "gallery".tr(),
                        style: const TextStyle(fontSize: 16),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        )
      ],
      cancelButton: CupertinoActionSheetAction(
        child: Text(
          "cancel".tr(),
          style: const TextStyle(fontSize: 16),
        ),
        onPressed: () {
          Navigator.pop(context);
        },
      ),
    );
    showCupertinoModalPopup(context: context, builder: (context) => action);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        titleSpacing: 0,
        leading: Padding(
          padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 12.0),
          child: context.select((ThemeCubit themeCubit) =>
                  themeCubit.state.themeMode == ThemeMode.dark)
              ? SvgPicture.asset(
                  'assets/icons/jobless.svg',
                  height: 62,
                )
              : SvgPicture.asset(
                  'assets/icons/jobless_dark.svg',
                  height: 62,
                ),
        ),
        title: const Text(
          'Profile',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
      ),
      body: SingleChildScrollView(
        // controller: widget.controller,
        physics: const BouncingScrollPhysics(),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8.0),
          child: Column(
            children: [
              Container(
                height: 92,
                width: MediaQuery.of(context).size.width,
                padding:
                    const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
                margin: const EdgeInsets.symmetric(
                    vertical: 12.0, horizontal: 12.0),
                decoration: BoxDecoration(
                  // color: Theme.of(context).colorScheme.onPrimary,
                  borderRadius: BorderRadius.circular(16.0),
                ),
                child: Row(
                  children: [
                    AspectRatio(
                      aspectRatio: 4 / 3,
                      child: Container(
                        decoration: BoxDecoration(
                          // add border
                          border: Border.all(
                              width: 3,
                              color: Theme.of(context)
                                  .primaryIconTheme
                                  .color!
                                  .withOpacity(.8)),
                          // set border radius
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Stack(
                          children: [
                            Positioned.fill(
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(12),
                                child: CachedNetworkImage(
                                  fit: BoxFit.cover,
                                  imageUrl:
                                      "${Config.baseUrl}/${Config.imageEmployee}/${context.read<UserCubit>().user!.employeeProfile!.photo ?? ''}",
                                  placeholder: (context, url) => const Center(
                                      child: LoadingWidget(
                                    fallingDot: true,
                                  )),
                                  errorWidget: (context, url, error) =>
                                      context.select((ThemeCubit themeCubit) =>
                                              themeCubit.state.themeMode ==
                                              ThemeMode.dark)
                                          ? SvgPicture.asset(
                                              'assets/icons/jobless.svg',
                                              fit: BoxFit.cover,
                                            )
                                          : SvgPicture.asset(
                                              'assets/icons/jobless_dark.svg',
                                              fit: BoxFit.cover,
                                            ),
                                ),
                              ),
                            ),
                            Positioned(
                              bottom: 0,
                              top: 0,
                              right: 0,
                              left: 0,
                              child: IconButton(
                                onPressed: () => openMediaModal(),
                                icon: ClipOval(
                                  child: Container(
                                    color: Theme.of(context)
                                        .primaryIconTheme
                                        .color!
                                        .withOpacity(.6),
                                    padding: const EdgeInsets.all(4.0),
                                    child: Icon(Icons.add_a_photo_outlined,
                                        color: Theme.of(context)
                                            .colorScheme
                                            .onPrimary
                                            .withOpacity(.8)),
                                  ),
                                ),
                              ),
                            )
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(
                      width: 12,
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          context
                                  .read<UserCubit>()
                                  .user!
                                  .employeeProfile!
                                  .fullname ??
                              '',
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(
                          height: 8.0,
                        ),
                        Text(
                          context.read<UserCubit>().user!.email!,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        Text(
                          context
                                  .read<UserCubit>()
                                  .user!
                                  .employeeProfile!
                                  .skill ??
                              '',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    )
                  ],
                ),
              ),
              const SizedBox(
                height: 12.0,
              ),
              widgetSettings(
                icon: Icons.person,
                color: Theme.of(context).primaryIconTheme.color,
                title: 'profile'.tr(),
                onTap: () => debugPrint('notification'),
              ),
              widgetSettings(
                icon: Icons.notifications,
                color: Theme.of(context).primaryIconTheme.color,
                title: 'notifications'.tr(),
                onTap: () => debugPrint('notification'),
              ),
              widgetSettings(
                icon: context.select((ThemeCubit themeCubit) =>
                        themeCubit.state.themeMode == ThemeMode.dark)
                    ? Icons.light_mode
                    : Icons.dark_mode,
                color: context.select((ThemeCubit themeCubit) =>
                        themeCubit.state.themeMode == ThemeMode.dark)
                    ? Colors.yellow[700]
                    : Theme.of(context).primaryIconTheme.color,
                title: context.select((ThemeCubit themeCubit) =>
                        themeCubit.state.themeMode == ThemeMode.dark)
                    ? 'light mode'.tr()
                    : 'dark mode'.tr(),
                trailing: CupertinoSwitch(
                    activeColor: Theme.of(context).primaryColor,
                    value: context.select((ThemeCubit themeCubit) =>
                        themeCubit.state.themeMode == ThemeMode.dark),
                    onChanged: (bool value) {
                      context.read<ThemeCubit>().updateAppTheme();
                    }),
                onTap: () => debugPrint('Tampilan'),
              ),
              widgetSettings(
                icon: Icons.translate,
                color: Theme.of(context).primaryIconTheme.color,
                title: 'languages'.tr(),
                onTap: () => showButtomSheet(),
              ),
              widgetSettings(
                icon: Icons.help_outline_rounded,
                color: Theme.of(context).primaryIconTheme.color,
                title: 'helps'.tr(),
                onTap: () => debugPrint('Help'),
              ),
              widgetSettings(
                icon: Icons.logout,
                color: Colors.red,
                title: 'logout'.tr(),
                onTap: () => showModalBottomSheet(
                  backgroundColor: Colors.transparent,
                  context: context,
                  builder: (context) {
                    return Popover(
                      child: Column(
                        children: [
                          Text(
                            'logout'.tr(),
                            style: const TextStyle(
                                fontSize: 18.0, fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(
                            height: 18.0,
                          ),
                          Text('logout desc'.tr()),
                          const SizedBox(
                            height: 24.0,
                          ),
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Align(
                              alignment: Alignment.bottomRight,
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  ElevatedButton(
                                    onPressed: () => Navigator.pop(context),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Theme.of(context)
                                          .primaryIconTheme
                                          .color!
                                          .withOpacity(.5),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(25),
                                      ),
                                      elevation: 15.0,
                                    ),
                                    child: Padding(
                                      padding: const EdgeInsets.all(8.0),
                                      child: Text(
                                        'no'.tr(),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(
                                    width: 12.0,
                                  ),
                                  ElevatedButton(
                                    onPressed: () => logout(),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Theme.of(context)
                                          .primaryIconTheme
                                          .color,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(25),
                                      ),
                                      elevation: 15.0,
                                    ),
                                    child: Padding(
                                      padding: const EdgeInsets.all(8.0),
                                      child: Text(
                                        'yes'.tr(),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          )
                        ],
                      ),
                    );
                  },
                ),
              ),
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 12.0),
                child: Text('Version 1.1.1'),
              )
            ],
          ),
        ),
      ),
    );
  }

  Widget widgetSettings(
      {IconData? icon,
      Color? color,
      String? title,
      Widget? trailing,
      Function()? onTap}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
      margin: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 4.0),
      decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.onPrimary,
          borderRadius: BorderRadius.circular(12.0),
          boxShadow: [
            BoxShadow(
              color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
              spreadRadius: .5,
              blurRadius: .1,
              offset: const Offset(0, .8),
            ),
          ]),
      child: ListTile(
        leading: ClipRRect(
          borderRadius: const BorderRadius.all(Radius.circular(8)),
          child: Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 8.0, vertical: 8.0),
              color: color!.withOpacity(.1),
              width: 42,
              height: 42,
              child: Center(
                child: Icon(
                  icon,
                  color: color,
                ),
              )),
        ),
        title: Text(title!),
        trailing: trailing ?? const Icon(Icons.arrow_forward_ios_outlined),
        onTap: onTap,
      ),
    );
  }

  void showButtomSheet() {
    showModalBottomSheet(
      backgroundColor: Colors.transparent,
      context: context,
      builder: (context) {
        return Popover(
          child: Container(
            color: Theme.of(context).primaryColor.withOpacity(.1),
            child: Column(
              children: [
                InkWell(
                  onTap: () {
                    Navigator.pop(context);
                    context.setLocale(const Locale('id'));
                  },
                  child: buildListItem(
                    context,
                    title: Text('Indonesia',
                        style: TextStyle(
                            color: Theme.of(context)
                                .colorScheme
                                .primary
                                .withOpacity(.7))),
                    leading: Icon(Icons.translate,
                        color: Theme.of(context).primaryColor),
                    trailing: context.locale.languageCode == 'id'
                        ? Icon(
                            Icons.check_rounded,
                            color: Colors.green.shade600,
                          )
                        : SizedBox.fromSize(),
                  ),
                ),
                Divider(
                  height: .5,
                  color: Theme.of(context).colorScheme.primary.withOpacity(.1),
                ),
                InkWell(
                  onTap: () {
                    Navigator.pop(context);
                    context.setLocale(const Locale('en'));
                  },
                  child: buildListItem(
                    context,
                    title: const Text('English'),
                    leading: Icon(Icons.translate,
                        color: Theme.of(context).primaryColor),
                    trailing: context.locale.languageCode == 'en'
                        ? Icon(
                            Icons.check_rounded,
                            color: Colors.green.shade600,
                          )
                        : SizedBox.fromSize(),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
