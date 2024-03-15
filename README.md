# simpleworld

A new Flutter project.

## Getting Started

This project is a starting point for a Flutter application.

A few resources to get you started if this is your first Flutter project:

- [Lab: Write your first Flutter app](https://flutter.dev/docs/get-started/codelab)
- [Cookbook: Useful Flutter samples](https://flutter.dev/docs/cookbook)

For help getting started with Flutter, view our
[online documentation](https://flutter.dev/docs), which offers tutorials,
samples, guidance on mobile development, and a full API reference.

### SDK Platform
- 34
- 33
- 31
- 30
- 29
- 28
### SDK Build-Tools
- 33.0.1
- 34.0.0

### FLUTTER SDK MAX
- 3.7.12
    - ref 4d9e56e


This will generate a JSON format file containing all messages that 
need to be translated.
~/.pub-cache/hosted/pub.dev/universal_html-2.2.2/lib/src/html/dom/element_subclasses.dart:2752:30: Error: The argument type 'String?' can't be assigned to the parameter type 'Object' because 'String?' is nullable and 'Object' isn't.
 - 'Object' is from 'dart:core'.
    final parsed = css.parse(text);
    replace to
    final parsed = css.parse(text!!);
