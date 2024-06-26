import 'package:flutter/material.dart';

const textInputDecoration=InputDecoration(
  border: OutlineInputBorder(
    borderRadius: BorderRadius.all(Radius.circular(28.0)),
  ),
  fillColor: Colors.white,
  filled: true,
  isDense: true,
  contentPadding: EdgeInsets.all(8.0)
);

var buttonStyleSignIn= ButtonStyle(
  fixedSize: WidgetStateProperty.all<Size>(Size(250.0, 50)),
  backgroundColor: WidgetStateProperty.all<Color>(Colors.purple[200]!),
  shape: WidgetStateProperty.all<RoundedRectangleBorder>(RoundedRectangleBorder(
    borderRadius: BorderRadius.circular(28.0),
  )),
  foregroundColor: WidgetStateProperty.all<Color>(Colors.white),
  side: WidgetStateProperty.all<BorderSide>(
      const BorderSide(color: Colors.white, width: 2.0)),
);

var buttonStyleSignUp=ButtonStyle(
  fixedSize: WidgetStateProperty.all<Size>(Size(250.0, 50)),
  backgroundColor: WidgetStateProperty.all<Color>(Colors.white),
  shape: WidgetStateProperty.all<RoundedRectangleBorder>(RoundedRectangleBorder(
    borderRadius: BorderRadius.circular(28.0),
  )),
  foregroundColor: WidgetStateProperty.all<Color>(Colors.purple[200]!),
  side: WidgetStateProperty.all<BorderSide>(
      BorderSide(color: Colors.purple[200]!, width: 2.0)),
);