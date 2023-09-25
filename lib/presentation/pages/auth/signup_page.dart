import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:form_field_validator/form_field_validator.dart';
import 'package:jobless/core/widgets/textfield.dart';
import 'package:jobless/presentation/bloc/auth/auth_cubit.dart';
import 'package:jobless/presentation/bloc/theme/theme_cubit.dart';
import 'package:rounded_loading_button/rounded_loading_button.dart';

class SignUpPage extends StatefulWidget {
  const SignUpPage({super.key});

  @override
  State<SignUpPage> createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {
  GlobalKey<FormState> formSignOutKey = GlobalKey<FormState>();
  final TextEditingController _textEmailController = TextEditingController();
  final TextEditingController _textPasswordController = TextEditingController();
  final RoundedLoadingButtonController _btnSignOutController =
      RoundedLoadingButtonController();

  bool offSecureText = true;
  Icon lockIcon = const Icon(Icons.visibility_off_outlined, size: 20);

  @override
  void initState() {
    super.initState();
  }

  void onLockPressed() {
    if (offSecureText) {
      setState(() {});
      offSecureText = false;
      lockIcon = const Icon(
        Icons.remove_red_eye_outlined,
        size: 20,
      );
    } else {
      setState(() {});
      offSecureText = true;
      lockIcon = const Icon(
        Icons.visibility_off_outlined,
        size: 20,
      );
    }
  }

  @override
  void dispose() {
    _textEmailController.dispose();
    _textPasswordController.dispose();
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
        title: const Text('Sign Up'),
      ),
      body: SingleChildScrollView(
        child: SizedBox(
          width: MediaQuery.of(context).size.width,
          height: MediaQuery.of(context).size.height - kToolbarHeight * 1.5,
          child: Column(
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
                          fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ),
              Form(
                key: formSignOutKey,
                child: Column(
                  children: [
                    Text(
                      'slogan jobless'.tr(),
                      style: TextStyle(
                          fontSize: 18,
                          color: Theme.of(context).colorScheme.primary,
                          fontWeight: FontWeight.w800),
                    ),
                    const SizedBox(
                      height: 24.0,
                    ),
                    TextFieldCustom(
                      validator: MultiValidator([
                        RequiredValidator(errorText: 'email is required'.tr()),
                        EmailValidator(
                            errorText: 'enter a valid email address'.tr()),
                      ]),
                      controller: _textEmailController,
                      placeholder: 'Email',
                      prefixIcon: const Icon(Icons.email),
                    ),
                    TextFieldCustom(
                      validator: MultiValidator([
                        RequiredValidator(
                            errorText: 'password is required'.tr()),
                        MinLengthValidator(6,
                            errorText:
                                'password must be at least 6 digits long'.tr()),
                      ]),
                      controller: _textPasswordController,
                      placeholder: 'Password',
                      suffixIcon: IconButton(
                        icon: lockIcon,
                        onPressed: () => onLockPressed(),
                      ),
                      prefixIcon: const Icon(Icons.lock),
                      obscureText: offSecureText,
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16.0),
                      child: RoundedLoadingButton(
                        animateOnTap: true,
                        errorColor: Colors.red.shade200,
                        controller: _btnSignOutController,
                        onPressed: () async {
                          if (!context.mounted) return;

                          FocusScope.of(context).unfocus();
                          if (formSignOutKey.currentState!.validate()) {
                            BlocProvider.of<AuthCubit>(context)
                                .signOut(
                                    email: _textEmailController.text,
                                    password: _textPasswordController.text)
                                .then((value) {
                              if (value) {
                                Navigator.pushNamedAndRemoveUntil(
                                    context, '/', (route) => false);
                              } else {
                                _btnSignOutController.reset();
                                Fluttertoast.showToast(
                                    msg: context
                                        .read<AuthCubit>()
                                        .auth!
                                        .message);
                              }
                            });
                          } else {
                            _btnSignOutController.error();
                            Future.delayed(const Duration(milliseconds: 500),
                                () {
                              _btnSignOutController.reset();
                            });
                          }
                        },
                        borderRadius: 16,
                        elevation: 0,
                        width: MediaQuery.of(context).size.width,
                        color: Theme.of(context).primaryColor,
                        child: Text(
                          'create account'.tr(),
                          style: const TextStyle(
                              color: Colors.white,
                              fontSize: 16.0,
                              fontWeight: FontWeight.w600),
                        ),
                      ),
                    ),
                    const SizedBox(
                      height: 12.0,
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 16.0),
                      child: RichText(
                        text: TextSpan(children: [
                          TextSpan(
                            text: 'already have an account?'.tr(),
                            style: TextStyle(
                                color: Theme.of(context).colorScheme.primary),
                          ),
                          TextSpan(
                              text: 'login'.tr(),
                              style: TextStyle(
                                  color: Theme.of(context).primaryColor),
                              recognizer: TapGestureRecognizer()
                                ..onTap = () => Navigator.pop(context))
                        ]),
                      ),
                    )
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
