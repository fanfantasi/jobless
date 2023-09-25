import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'textfield.dart';

class FieldFormData extends StatelessWidget {
  final String? label;
  final TextEditingController? texteditor;
  final String? Function(String?)? validators;
  final int? maxLines;
  final bool readOnly;
  final TextInputType? keyboardType;
  final List<TextInputFormatter>? inputFormatters;
  final Function()? onTap;
  final String? placeholder;
  final Widget? suffixIcon;
  const FieldFormData(
      {super.key,
      this.label,
      this.texteditor,
      this.validators,
      this.maxLines,
      this.readOnly = false,
      this.keyboardType = TextInputType.text,
      this.inputFormatters,
      this.onTap,
      this.placeholder,
      this.suffixIcon});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Text(label!),
          ),
          TextFieldCustom(
            controller: texteditor!,
            maxLines: maxLines,
            readOnly: readOnly,
            keyboardType: keyboardType,
            validator: validators,
            placeholder: placeholder!,
            suffixIcon: suffixIcon,
            onSubmitted: onTap,
            inputFormatters: inputFormatters,
          ),
        ],
      ),
    );
  }
}
