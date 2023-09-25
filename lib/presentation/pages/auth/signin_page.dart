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
import 'package:lottie/lottie.dart';
import 'package:rounded_loading_button/rounded_loading_button.dart';

class SignInPage extends StatefulWidget {
  const SignInPage({super.key});

  @override
  State<SignInPage> createState() => _SignInPageState();
}

class _SignInPageState extends State<SignInPage> {
  GlobalKey<FormState> formSignInKey = GlobalKey<FormState>();
  final TextEditingController _textEmailController = TextEditingController();
  final TextEditingController _textPasswordController = TextEditingController();
  final RoundedLoadingButtonController _btnLoginController =
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
    _btnLoginController.reset();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: SizedBox(
          width: MediaQuery.of(context).size.width,
          height: MediaQuery.of(context).size.height,
          child: Column(
            children: [
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.only(top: kToolbarHeight),
                  child: Center(
                    child: Lottie.asset('assets/lottie/hero.json',
                        fit: BoxFit.cover),
                  ),
                ),
              ),
              Form(
                key: formSignInKey,
                child: Column(
                  children: [
                    Text(
                      'login to continue'.tr(),
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
                      validator: MultiValidator([
                        RequiredValidator(errorText: 'email is required'.tr()),
                        EmailValidator(
                            errorText: 'enter a valid email address'.tr()),
                      ]),
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
                        controller: _btnLoginController,
                        onPressed: () async {
                          if (!context.mounted) return;

                          FocusScope.of(context).unfocus();
                          if (formSignInKey.currentState!.validate()) {
                            BlocProvider.of<AuthCubit>(context)
                                .signIn(
                                    email: _textEmailController.text,
                                    password: _textPasswordController.text)
                                .then((value) {
                              if (value) {
                                Navigator.pushNamedAndRemoveUntil(
                                    context, '/', (route) => false);
                              } else {
                                _btnLoginController.reset();
                                Fluttertoast.showToast(
                                    msg: context
                                        .read<AuthCubit>()
                                        .auth!
                                        .message);
                              }
                            });
                          } else {
                            _btnLoginController.error();
                            Future.delayed(const Duration(milliseconds: 500),
                                () {
                              _btnLoginController.reset();
                            });
                          }
                        },
                        borderRadius: 16,
                        elevation: 0,
                        width: MediaQuery.of(context).size.width,
                        child: Text(
                          'login'.tr(),
                          style: const TextStyle(
                              color: Colors.white,
                              fontSize: 16.0,
                              fontWeight: FontWeight.w600),
                        ),
                      ),
                    ),
                    TextButton(
                      style: ButtonStyle(
                        overlayColor:
                            MaterialStateProperty.all(Colors.transparent),
                      ),
                      onPressed: () => Navigator.pushNamed(context, '/forgot'),
                      child: Text(
                        'forgot password'.tr(),
                        style: TextStyle(color: Theme.of(context).primaryColor),
                      ),
                    ),
                    const SizedBox(
                      height: 12.0,
                    ),
                    Text('or continue with'.tr()),
                    Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16.0, vertical: 12.0),
                      child: SizedBox(
                        width: MediaQuery.of(context).size.width,
                        child: ElevatedButton.icon(
                          icon: SvgPicture.asset('assets/icons/google.svg',
                              height: 24),
                          label: Text(
                            "Google",
                            style: TextStyle(
                                color: Theme.of(context).colorScheme.primary),
                          ),
                          onPressed: () =>
                              context.read<ThemeCubit>().updateAppTheme(),
                          style: ElevatedButton.styleFrom(
                            // elevation: 2,
                            backgroundColor:
                                Theme.of(context).colorScheme.onPrimary,
                            minimumSize: Size(
                                MediaQuery.of(context).size.width - 32, 52),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12.0),
                            ),
                          ),
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 16.0),
                      child: RichText(
                        text: TextSpan(children: [
                          TextSpan(
                            text: "don't have an account?".tr(),
                            style: TextStyle(
                                color: Theme.of(context).colorScheme.primary),
                          ),
                          TextSpan(
                              text: 'create account'.tr(),
                              style: TextStyle(
                                  color: Theme.of(context).primaryColor),
                              recognizer: TapGestureRecognizer()
                                ..onTap = () =>
                                    Navigator.pushNamed(context, '/signout'))
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
