import 'package:dtpocketfm/utils/color.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

// ignore: must_be_immutable
class MyTextFormField extends StatelessWidget {
  dynamic mHint,
      mObscureText,
      mController,
      mkeyboardType,
      mTextInputAction,
      mInputBorder,
      mTextColor,
      mHintTextColor,
      mTextAlign,
      mMaxLine,
      mMaxLength,
      mReadOnly;

  MyTextFormField({
    super.key,
    required this.mHint,
    this.mObscureText,
    this.mController,
    this.mkeyboardType,
    this.mTextInputAction,
    this.mInputBorder,
    this.mHintTextColor,
    this.mTextColor,
    this.mTextAlign,
    this.mMaxLine,
    this.mReadOnly,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: mController,
      keyboardType: mkeyboardType,
      textInputAction: mTextInputAction,
      obscureText: mObscureText,
      maxLength: mMaxLength,
      maxLines: mMaxLine,
      readOnly: mReadOnly ?? false,
      decoration: InputDecoration(
        hintText: mHint,
        hintStyle: GoogleFonts.montserrat(
          // fontSize: 15,
          color: mHintTextColor,
          fontWeight: FontWeight.w500,
          fontStyle: FontStyle.normal,
        ),
        filled: true,
        border: mInputBorder,
        fillColor: appBgColor,
        isCollapsed: true,
      ),
      style: GoogleFonts.montserrat(
        textStyle: TextStyle(
          // fontSize: 15,
          color: mTextColor,
          fontWeight: FontWeight.w500,
          fontStyle: FontStyle.normal,
        ),
      ),
    );
  }
}
