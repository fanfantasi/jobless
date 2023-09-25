import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:jobless/presentation/bloc/theme/theme_cubit.dart';

class ChatsPage extends StatefulWidget {
  const ChatsPage({super.key});

  @override
  State<ChatsPage> createState() => _ChatsPageState();
}

class _ChatsPageState extends State<ChatsPage> {
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
          'Chats',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }
}
