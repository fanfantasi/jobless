import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:jobless/core/widgets/textfield.dart';
import 'package:jobless/presentation/bloc/theme/theme_cubit.dart';

class ForgotPage extends StatefulWidget {
  const ForgotPage({super.key});

  @override
  State<ForgotPage> createState() => _ForgotPageState();
}

class _ForgotPageState extends State<ForgotPage> {
  final TextEditingController _textEmailController = TextEditingController();

  @override
  void dispose() {
    _textEmailController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
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
        title: const Text('Forgot Password'),
      ),
      body: SingleChildScrollView(
        child: SizedBox(
          width: MediaQuery.of(context).size.width,
          height: MediaQuery.of(context).size.height - kToolbarHeight * 1.5,
          child: Column(
            children: [
              SizedBox(
                height: MediaQuery.of(context).size.height / 3,
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
                          fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ),
              Text(
                'forgot your password'.tr(),
                style: TextStyle(
                    fontSize: 18,
                    color: Theme.of(context).colorScheme.primary,
                    fontWeight: FontWeight.w800),
              ),
              const SizedBox(
                height: 24.0,
              ),
              TextFieldCustom(
                controller: _textEmailController,
                placeholder: 'Email',
                prefixIcon: const Icon(Icons.email),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                      backgroundColor: Theme.of(context).colorScheme.background,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      minimumSize:
                          Size(MediaQuery.of(context).size.width - 32, 42)),
                  onPressed: () => debugPrint('disini'),
                  child: Text(
                    'send'.tr(),
                    style: const TextStyle(
                        fontSize: 16.0, fontWeight: FontWeight.w600),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
