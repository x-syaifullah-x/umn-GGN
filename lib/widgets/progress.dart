import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

Container circularProgress() {
  return Container(
    alignment: Alignment.center,
    padding: const EdgeInsets.only(top: 10.0),
    child: const CupertinoActivityIndicator(),
  );
}

Container linearProgress() {
  return Container(
    padding: const EdgeInsets.only(bottom: 10.0),
    child: LinearProgressIndicator(
      valueColor: AlwaysStoppedAnimation(Colors.red[800]),
    ),
  );
}
