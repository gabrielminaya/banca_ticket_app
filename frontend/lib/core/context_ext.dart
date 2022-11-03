import 'package:flutter/material.dart';

extension BuildContextExtensions on BuildContext {
  void showModal(Widget child) {
    showDialog(
      context: this,
      builder: (context) {
        return Dialog(
          child: child,
        );
      },
    );
  }
}
