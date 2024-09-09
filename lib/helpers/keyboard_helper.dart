import 'package:flutter/material.dart';

abstract class KeyboardHelper {
  static void hideKeyboard(BuildContext context) {
    FocusManager.instance.primaryFocus?.unfocus();
  }
}
