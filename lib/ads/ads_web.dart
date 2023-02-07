import 'dart:html' as html;
import 'dart:ui' as ui;

import 'package:flutter/cupertino.dart';

Widget webAds({
  required double width,
  required double height,
  required String src,
  required String adViewType,
}) {
  // ignore: undefined_prefixed_name
  ui.platformViewRegistry.registerViewFactory(adViewType, (int viewID) {
    return html.IFrameElement()
      // ..width = "${width}px"
      // ..height = '200'
      ..src = src
      ..style.border = 'none';
  });
  return SizedBox(
    width: width,
    height: height,
    child: HtmlElementView(
      viewType: adViewType,
    ),
  );
}

// import 'package:flutter/cupertino.dart';

// Widget webAds({
//   required double width,
//   required double height,
//   required String src,
//   required String adViewType,
// }) =>
//     Container();
