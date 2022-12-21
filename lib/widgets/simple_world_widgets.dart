import 'package:another_flushbar/flushbar.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:nb_utils/nb_utils.dart';

SharedPreferences? preferences;
String? globalID = '';
String? globalName = '';
String? globalImage = '';
String? globalToken = '';
String? globalBio = '';
String? globalCountry = '';
String? globalCover = '';
String globalCredits = '';
String? globalDisplayName = '';

Widget commonCachedNetworkImage(String? url,
    {double? height,
    double? width,
    BoxFit? fit,
    AlignmentGeometry? alignment,
    bool usePlaceholderIfUrlEmpty = true,
    double? radius}) {
  if (url!.validate().isEmpty) {
    return placeHolderWidget(
        height: height,
        width: width,
        fit: fit,
        alignment: alignment,
        radius: radius);
  } else if (url.validate().startsWith('http')) {
    return CachedNetworkImage(
      imageUrl: url,
      height: height,
      width: width,
      fit: fit,
      alignment: alignment as Alignment? ?? Alignment.center,
      errorWidget: (_, s, d) {
        return placeHolderWidget(
            height: height,
            width: width,
            fit: fit,
            alignment: alignment,
            radius: radius);
      },
      placeholder: (_, s) {
        if (!usePlaceholderIfUrlEmpty) return const SizedBox();
        return placeHolderWidget(
            height: height,
            width: width,
            fit: fit,
            alignment: alignment,
            radius: radius);
      },
    );
  } else {
    return Image.asset(url,
            height: height,
            width: width,
            fit: fit,
            alignment: alignment ?? Alignment.center)
        .cornerRadiusWithClipRRect(radius ?? defaultRadius);
  }
}

Widget placeHolderWidget(
    {double? height,
    double? width,
    BoxFit? fit,
    AlignmentGeometry? alignment,
    double? radius}) {
  return Image.asset('assets/images/placeholder.jpg',
          height: height,
          width: width,
          fit: fit ?? BoxFit.cover,
          alignment: alignment ?? Alignment.center)
      .cornerRadiusWithClipRRect(radius ?? defaultRadius);
}

InputDecoration buildInputDecoration(String name, {Widget? prefixIcon}) {
  return InputDecoration(
    prefixIcon: prefixIcon,
    hintText: name,
    hintStyle: primaryTextStyle(),
    focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8.0),
        borderSide: const BorderSide(color: grey, width: 0.5)),
    enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8.0),
        borderSide: const BorderSide(color: grey, width: 0.5)),
  );
}

Widget nbAppTextFieldWidget(TextEditingController controller, String hintText,
    TextFieldType textFieldType,
    {FocusNode? focus, FocusNode? nextFocus}) {
  return AppTextField(
    controller: controller,
    textFieldType: textFieldType,
    textStyle: primaryTextStyle(size: 14),
    focus: focus,
    nextFocus: nextFocus,
    textInputAction: TextInputAction.next,
    decoration: InputDecoration(
      contentPadding:
          const EdgeInsets.only(left: 16, right: 16, top: 8, bottom: 8),
      filled: true,
      fillColor: grey.withOpacity(0.1),
      hintText: hintText,
      hintStyle: secondaryTextStyle(),
      border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
    ),
  );
}

simpleworldtoast(title, msg, BuildContext context) {
  Flushbar(
    title: title,
    message: msg,
    titleColor: Colors.black,
    messageColor: Colors.black,
    icon: Icon(
      title == "Error" ? Icons.error : Icons.check,
      color: Colors.black,
    ),
    backgroundColor: Colors.grey.shade300,
    duration: const Duration(seconds: 2),
  ).show(context);
}

extension StringExtension on String {
  String capitalize() {
    return "${this[0].toUpperCase()}${this.substring(1)}";
  }
}

// ignore: must_be_immutable
class CustomtextField extends StatefulWidget {
  final TextInputType? keyboardType;
  final Function()? onTap;
  final FocusNode? focusNode;
  final TextInputAction? textInputAction;
  final Function()? onEditingComplate;
  final void Function()? onSubmitted;
  final dynamic controller;
  final int? maxLines;
  final TextCapitalization? textCapitalization;
  final dynamic onChange;
  final String? errorText;
  final String? hintText;
  final String? labelText;
  bool obscureText = false;
  bool readOnly = false;
  bool autoFocus = false;
  final Widget? suffixIcon;

  final Widget? prefixIcon;
  CustomtextField({
    this.keyboardType,
    this.onTap,
    this.focusNode,
    this.textInputAction,
    this.onEditingComplate,
    this.onSubmitted,
    this.controller,
    this.maxLines,
    this.onChange,
    this.errorText,
    this.hintText,
    this.labelText,
    this.textCapitalization,
    this.obscureText = false,
    this.readOnly = false,
    this.autoFocus = false,
    this.prefixIcon,
    this.suffixIcon,
  });

  @override
  _CustomtextFieldState createState() => _CustomtextFieldState();
}

class _CustomtextFieldState extends State<CustomtextField> {
  @override
  Widget build(BuildContext context) {
    return TextField(
      focusNode: widget.focusNode,
      readOnly: widget.readOnly,
      textInputAction: widget.textInputAction,
      onTap: widget.onTap,
      autofocus: widget.autoFocus,
      maxLines: widget.maxLines,
      onEditingComplete: widget.onEditingComplate,
      obscureText: widget.obscureText,
      keyboardType: widget.keyboardType,
      controller: widget.controller,
      onChanged: widget.onChange,
      style: const TextStyle(color: Colors.black, fontSize: 14),
      cursorColor: Colors.black,
      decoration: InputDecoration(
        filled: true,
        fillColor: Colors.white,
        prefixIcon: widget.prefixIcon,
        suffixIcon: widget.suffixIcon,
        labelText: widget.labelText,
        contentPadding:
            const EdgeInsets.symmetric(vertical: 15.0, horizontal: 20),
        errorStyle: const TextStyle(color: Colors.white),
        errorText: widget.errorText,
        focusedErrorBorder: OutlineInputBorder(
          borderSide: const BorderSide(color: Colors.black),
          borderRadius: BorderRadius.circular(10),
        ),
        hintText: widget.hintText,
        labelStyle: const TextStyle(color: Colors.black),
        hintStyle: TextStyle(color: Colors.grey.shade800, fontSize: 12),
        focusedBorder: OutlineInputBorder(
          borderSide: BorderSide(color: Colors.grey.shade600, width: 1),
          borderRadius: BorderRadius.circular(10),
        ),
        enabledBorder: OutlineInputBorder(
          borderSide: BorderSide(color: Colors.grey.shade600, width: 1),
          borderRadius: BorderRadius.circular(10),
        ),
      ),
    );
  }
}

// class CustomButtom extends StatelessWidget {
//   final Color? color;
//   final String? title;
//   final Function()? onPressed;
//   CustomButtom({
//     this.color,
//     this.title,
//     this.onPressed,
//   });
//   @override
//   Widget build(BuildContext context) {
//     // ignore: deprecated_member_use
//     return RaisedButton(
//       color: color,
//       child: Text(
//         title!,
//         style: const TextStyle(
//             fontSize: 14, fontWeight: FontWeight.w700, color: Colors.white),
//       ),
//       shape: RoundedRectangleBorder(
//         borderRadius: BorderRadius.circular(5),
//       ),
//       onPressed: onPressed,
//     );
//   }
// }

simpleAlertBox(
    {required BuildContext context, Widget? title, Widget? content}) {
  return showDialog(
    context: context,
    builder: (context) {
      return AlertDialog(
        title: title,
        content: content,
        actions: <Widget>[
          // ignore: deprecated_member_use
          // FlatButton(
          //   child: const Text('OK'),
          //   onPressed: () {
          //     Navigator.pop(context);
          //   },
          // )
          TextButton(
            child: const Text('OK'),
            onPressed: () {
              Navigator.pop(context);
            },
          )
        ],
      );
    },
  );
}
