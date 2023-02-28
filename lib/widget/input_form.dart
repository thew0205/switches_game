import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class InputForm extends StatelessWidget {
  const InputForm(
      {Key? key,
      this.hintText,
      this.textEditingController,
      this.validator,
      this.onSaved,
      this.errorText,
      this.maxLines,this.textCapitalization,
      this.keyboardType})
      : super(key: key);
  final String? hintText;
  final TextEditingController? textEditingController;
  final String? Function(String?)? validator;
  final void Function(String?)? onSaved;
  final String? errorText;
  final int? maxLines;
  final TextInputType? keyboardType;
  final TextCapitalization? textCapitalization;
  @override
  Widget build(BuildContext context) {
    return TextFormField(
      textCapitalization:textCapitalization?? TextCapitalization.sentences,
      keyboardType: keyboardType,
      maxLines: maxLines ?? 1,
      onSaved: onSaved,
      validator: validator,
      controller: textEditingController,
      style:
          GoogleFonts.sourceSansPro(fontSize: 16, fontWeight: FontWeight.w400),
      decoration: InputDecoration(
        hintText: hintText,
        errorText: errorText,
        filled: true,
        fillColor: const Color(0xe5e5e5e5),
        enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(4),
            borderSide: BorderSide.none),
        border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(4),
            borderSide: BorderSide.none),
      ),
    );
  }
}
