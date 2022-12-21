import 'package:flutter/material.dart';

header(context,
    {bool isAppTitle = false,
    bool iscenterTitle = false,
    String? titleText,
    removeBackButton = false,
    showMessengerButton = false}) {
  return AppBar(
    toolbarHeight: 50,
    iconTheme: IconThemeData(
      color: Theme.of(context).appBarTheme.iconTheme!.color,
    ),
    automaticallyImplyLeading: removeBackButton ? false : true,
    title: Text(
      isAppTitle ? "Simple World" : titleText!,
      style: Theme.of(context).textTheme.headline5!.copyWith(
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
    ),
    centerTitle: iscenterTitle ? true : false,
    backgroundColor: Theme.of(context).scaffoldBackgroundColor,
    elevation: 0.0,
  );
}
