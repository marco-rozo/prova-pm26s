import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';

class CustomTextFormField extends StatelessWidget {
  final FocusNode? inputFocus;
  final TextEditingController inputController;
  final VoidCallback onTapCallBack;
  final String labelText;
  final IconData? icon;
  final TextInputType? keyboardType;
  final List<TextInputFormatter>? inputFormatters;
  final bool? obscureText;
  final bool isEnable;
  final int? maxLines;
  final int? minLines;
  final String? Function(String?)? validator;

  const CustomTextFormField({
    Key? key,
    this.inputFocus,
    required this.inputController,
    required this.onTapCallBack,
    required this.labelText,
    this.icon,
    this.keyboardType,
    this.inputFormatters,
    this.obscureText,
    required this.isEnable,
    this.validator,
    this.maxLines,
    this.minLines,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      validator: validator,
      controller: inputController,
      style: TextStyle(
        color: isEnable ? Colors.black87 : Color(0xffC7C7C7),
      ),
      focusNode: inputFocus ?? null,
      onTap: () => onTapCallBack,
      keyboardType: keyboardType,
      inputFormatters: inputFormatters ?? [],
      obscureText: obscureText ?? false,
      cursorColor: Colors.black87,
      maxLines: maxLines ?? 1,
      minLines: maxLines ?? 1,
      decoration: InputDecoration(
        isDense: true,
        contentPadding: EdgeInsets.symmetric(vertical: 12.0, horizontal: 10.0),
        labelText: labelText,
        labelStyle: TextStyle(
          color: Colors.black87,
          fontSize: 16,
        ),
        suffixIcon: icon != null
            ? Icon(
                icon,
                color: Colors.black87,
              )
            : null,
        errorBorder: OutlineInputBorder(
          borderSide: BorderSide(
            color: Colors.red,
            width: 1.5,
          ),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderSide: BorderSide(
            color: Colors.black87,
            width: 1.5,
          ),
        ),
        enabledBorder: OutlineInputBorder(
          borderSide: BorderSide(
            color: Color(0xffC7C7C7),
            width: 1.5,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderSide: BorderSide(
            color: Colors.black87,
            width: 1.5,
          ),
        ),
        border: OutlineInputBorder(
          borderSide: BorderSide(
            color: Color(0xffC7C7C7),
            width: 1.5,
          ),
        ),
        enabled: isEnable,
        fillColor: Colors.red,
      ),
    );
  }
}
