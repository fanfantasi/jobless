import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:jobless/presentation/bloc/auth/auth_cubit.dart';
import 'package:jobless/presentation/bloc/user/user_cubit.dart';

import 'core/widgets/loadingwidget.dart';

class AppPage extends StatefulWidget {
  const AppPage({super.key});

  @override
  State<AppPage> createState() => _AppPageState();
}

class _AppPageState extends State<AppPage> {
  late StreamSubscription<AuthState> stream;

  @override
  void initState() {
    BlocProvider.of<AuthCubit>(context).isSignIn(isSubscribe: true);
    isSignIn();
    super.initState();
  }

  @override
  void dispose() {
    stream.cancel();
    super.dispose();
  }

  Future<void> isSignIn() async {
    stream = context.read<AuthCubit>().stream.listen((event) {
      if (event is Authenticated) {
        if (event.user.data.employeeProfile != null ||
            event.user.data.employersProfile != null) {
          if (!mounted) return;
          BlocProvider.of<UserCubit>(context).initialUser();
          Navigator.pushNamedAndRemoveUntil(
              context, '/dashboard', (route) => false);
        } else {
          if (!mounted) return;
          Navigator.pushNamedAndRemoveUntil(
              context, '/user-profile', (route) => false);
        }
      } else {
        if (!mounted) return;
        Navigator.pushNamedAndRemoveUntil(
            context, '/welcome', (route) => false);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
          child: SizedBox(
        width: MediaQuery.of(context).size.width,
        height: MediaQuery.of(context).size.height,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            SvgPicture.asset('assets/icons/jobless.svg'),
            Text(
              'Jobless',
              style: TextStyle(
                  fontSize: 22,
                  letterSpacing: 1.5,
                  color: Theme.of(context).colorScheme.primary,
                  fontWeight: FontWeight.w800),
            ),
            const SizedBox(
              height: 24.0,
            ),
            const LoadingWidget()
          ],
        ),
      )),
    );
  }
}
