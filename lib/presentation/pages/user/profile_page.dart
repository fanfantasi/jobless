import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:jobless/core/widgets/radiobutton.dart';

import '../../bloc/theme/theme_cubit.dart';

class UserPage extends StatefulWidget {
  const UserPage({super.key});

  @override
  State<UserPage> createState() => _UserPageState();
}

class _UserPageState extends State<UserPage> {
  List<RadioModel> statusProfile = [];

  @override
  void initState() {
    statusProfile.add(RadioModel(false, 'employee', '', '',
        Icons.local_library_outlined, 'i want a job'.tr()));
    statusProfile.add(RadioModel(
        false, 'employers', '', '', Icons.face_6, 'i want an employee'.tr()));
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    return Scaffold(
      body: SingleChildScrollView(
        child: SizedBox(
          width: MediaQuery.of(context).size.width,
          height: MediaQuery.of(context).size.height,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    context.select((ThemeCubit themeCubit) =>
                            themeCubit.state.themeMode == ThemeMode.dark)
                        ? SvgPicture.asset(
                            'assets/icons/jobless.svg',
                            height: 62,
                          )
                        : SvgPicture.asset(
                            'assets/icons/jobless_dark.svg',
                            height: 62,
                          ),
                    Text(
                      'Jobless',
                      style: TextStyle(
                          fontSize: 28,
                          color: Theme.of(context).colorScheme.primary,
                          fontWeight: FontWeight.w900),
                    ),
                  ],
                ),
              ),
              Container(
                  height: MediaQuery.of(context).size.height / 2.5,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(16),
                      topRight: Radius.circular(16),
                    ),
                    boxShadow: [
                      BoxShadow(
                        offset: const Offset(0, 1),
                        blurRadius: 2,
                        color: Colors.black.withOpacity(0.3),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      Container(
                        margin: EdgeInsets.symmetric(
                            vertical: 6.0, horizontal: width / 2.3),
                        height: 4,
                        decoration: BoxDecoration(
                          color: Theme.of(context)
                              .colorScheme
                              .primary
                              .withOpacity(.05),
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                      const SizedBox(
                        height: 12.0,
                      ),
                      Expanded(
                          child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.person_pin_outlined,
                            size: 32,
                            color: Theme.of(context).primaryColor,
                          ),
                          Text('what are you looking for'.tr()),
                          Flexible(
                            child: ListView.builder(
                              itemCount: statusProfile.length,
                              scrollDirection: Axis.horizontal,
                              itemBuilder: (context, i) {
                                return Padding(
                                  padding: const EdgeInsets.only(
                                      left: 16.0, right: 8.0),
                                  child: InkWell(
                                    highlightColor: Colors.red,
                                    splashColor: Colors.blueAccent,
                                    onTap: () async {
                                      setState(() {
                                        for (var element in statusProfile) {
                                          element.isSelected = false;
                                        }
                                        statusProfile[i].isSelected = true;
                                      });
                                      await Future.delayed(
                                          const Duration(milliseconds: 300));
                                      if (statusProfile[i].options ==
                                          'employee') {
                                        if (!mounted) return;
                                        Navigator.pushNamed(
                                            context, '/category');
                                      } else {
                                        if (!mounted) return;
                                        Navigator.pushNamed(
                                            context, '/user-profile/employers');
                                      }
                                    },
                                    child: RadioItem(statusProfile[i]),
                                  ),
                                );
                              },
                            ),
                          )
                        ],
                      ))
                    ],
                  ))
            ],
          ),
        ),
      ),
    );
  }
}
