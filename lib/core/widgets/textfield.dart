import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class TextFieldCustom extends StatelessWidget {
  final TextEditingController controller;
  final String? placeholder;
  final Widget? prefixIcon;
  final Widget? suffixIcon;
  final int? maxLines;
  final int? maxLength;
  final bool readOnly;
  final bool obscureText;
  final TextInputType? keyboardType;
  final String? Function(String?)? validator;
  final List<TextInputFormatter>? inputFormatters;
  final Function(String)? onChange;
  final Function()? onSubmitted;
  const TextFieldCustom(
      {super.key,
      required this.controller,
      required this.placeholder,
      this.prefixIcon,
      this.suffixIcon,
      this.maxLength,
      this.keyboardType,
      this.maxLines = 1,
      this.obscureText = false,
      this.readOnly = false,
      this.validator,
      this.inputFormatters,
      this.onChange,
      this.onSubmitted});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8.0),
      child: TextFormField(
        controller: controller,
        maxLength: maxLength,
        maxLines: maxLines,
        readOnly: readOnly,
        keyboardType: keyboardType ?? TextInputType.text,
        decoration: InputDecoration(
          focusColor: Colors.green,
          enabledBorder: OutlineInputBorder(
            borderRadius: const BorderRadius.all(
              Radius.circular(16.0),
            ),
            borderSide: BorderSide(
              color: Theme.of(context).colorScheme.onBackground,
              width: 1,
            ),
          ),
          suffixIcon: suffixIcon,
          prefixIcon: prefixIcon,
          focusedBorder: OutlineInputBorder(
            borderRadius: const BorderRadius.all(
              Radius.circular(16.0),
            ),
            borderSide: BorderSide(
                color: Theme.of(context).colorScheme.primary.withOpacity(.2)),
          ),
          errorBorder: OutlineInputBorder(
            borderRadius: const BorderRadius.all(
              Radius.circular(16.0),
            ),
            borderSide: BorderSide(color: Colors.red.withOpacity(.6)),
          ),
          focusedErrorBorder: OutlineInputBorder(
            borderRadius: const BorderRadius.all(
              Radius.circular(16.0),
            ),
            borderSide: BorderSide(color: Colors.red.withOpacity(.6)),
          ),
          hintText: placeholder,
          fillColor: Colors.red,
          contentPadding:
              const EdgeInsets.symmetric(vertical: 6, horizontal: 12.0),
        ),
        onChanged: onChange,
        onTap: onSubmitted,
        validator: validator,
        obscureText: obscureText,
        inputFormatters: inputFormatters,
      ),
    );
  }
}
