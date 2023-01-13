// import 'dart:html';
// import 'dart:ui' as ui;
// import 'package:flutter/cupertino.dart';

// Widget webAds(double width) {
//   const String adViewType = 'adViewType';
//   // ignore: undefined_prefixed_name
//   ui.platformViewRegistry.registerViewFactory(
//     adViewType,
//     (int viewID) => IFrameElement()
//       ..width = "${width - 10}"
//       ..height = '100'
//       ..src = 'assets/assets/adsense.html'
//       ..style.border = 'none',
//   );
//   return Container(
//     width: width,
//     height: 100,
//     margin: EdgeInsets.only(top: 200),
//     child: const HtmlElementView(
//       viewType: adViewType,
//     ),
//   );
// }
