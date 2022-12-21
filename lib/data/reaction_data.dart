import 'package:flutter/material.dart';
import 'package:flutter_reaction_button/flutter_reaction_button.dart';
import 'package:flutter_svg/flutter_svg.dart';

final defaultInitialReaction = Reaction<String>(
  value: null,
  icon: Row(
    children: [
      SvgPicture.asset(
        "assets/images/thumbs-up.svg",
        height: 20,
        color: Colors.grey,
      ),
      const SizedBox(width: 5.0),
      const Text('Like',
          style: TextStyle(
            fontSize: 14.0,
            color: Colors.grey,
          )),
    ],
  ),
);

final reactions = [
  Reaction<String>(
    value: 'Like',
    title: _buildTitle('Like'),
    previewIcon: _buildReactionsPreviewIcon('assets/images/like.gif'),
    icon: _buildReactionsIcon(
      'assets/images/like.gif',
      const Text(
        'Like',
        style: TextStyle(
          color: Color(0XFF3b5998),
        ),
      ),
    ),
  ),
  Reaction<String>(
    value: 'Happy',
    title: _buildTitle('Happy'),
    previewIcon: _buildReactionsPreviewIcon('assets/images/haha.gif'),
    icon: _buildReactionsIcon(
      'assets/images/haha2.png',
      const Text(
        'Happy',
        style: TextStyle(
          color: Color(0XFFf05766),
        ),
      ),
    ),
  ),
  Reaction<String>(
    value: 'Sad',
    title: _buildTitle('Sad'),
    previewIcon: _buildReactionsPreviewIcon('assets/images/sad.gif'),
    icon: _buildReactionsIcon(
      'assets/images/sad2.png',
      const Text(
        'Sad',
        style: TextStyle(
          color: Color(0XFFffda6b),
        ),
      ),
    ),
  ),
  Reaction<String>(
    value: 'Angry',
    title: _buildTitle('Angry'),
    previewIcon: _buildReactionsPreviewIcon('assets/images/angry.gif'),
    icon: _buildReactionsIcon(
      'assets/images/angry2.png',
      const Text(
        'Angry',
        style: TextStyle(
          color: Color(0XFFed5168),
        ),
      ),
    ),
  ),
  Reaction<String>(
    value: 'In love',
    title: _buildTitle('In love'),
    previewIcon: _buildReactionsPreviewIcon('assets/images/love.gif'),
    icon: _buildReactionsIcon(
      'assets/images/love2.png',
      const Text(
        'In love',
        style: TextStyle(
          color: Colors.pink,
        ),
      ),
    ),
  ),
  Reaction<String>(
    value: 'Surprised',
    title: _buildTitle('Surprised'),
    previewIcon: _buildReactionsPreviewIcon('assets/images/wow.gif'),
    icon: _buildReactionsIcon(
      'assets/images/wow2.png',
      const Text(
        'Surprised',
        style: TextStyle(
          color: Color(0XFFffda6b),
        ),
      ),
    ),
  ),
];

Container _buildTitle(String title) {
  return Container(
    padding: const EdgeInsets.symmetric(horizontal: 7.5, vertical: 2.5),
    decoration: BoxDecoration(
      color: Colors.red,
      borderRadius: BorderRadius.circular(15),
    ),
    child: Text(
      title,
      style: const TextStyle(
        color: Colors.white,
        fontSize: 10,
        fontWeight: FontWeight.bold,
      ),
    ),
  );
}

Padding _buildReactionsPreviewIcon(String path) {
  return Padding(
    padding: const EdgeInsets.symmetric(horizontal: 3.5, vertical: 5),
    child: Image.asset(path, height: 40),
  );
}

Container _buildReactionsIcon(String path, Text text) {
  return Container(
    color: Colors.transparent,
    child: Row(
      children: <Widget>[
        Image.asset(path, height: 20),
        const SizedBox(width: 5),
        text,
      ],
    ),
  );
}
