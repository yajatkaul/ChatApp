import 'package:delightful_toast/delight_toast.dart';
import 'package:delightful_toast/toast/components/toast_card.dart';
import 'package:delightful_toast/toast/utils/enums.dart';
import 'package:flutter/material.dart';

void showToast(String message, bool success, BuildContext context) {
  DelightToastBar(
    position: DelightSnackbarPosition.top,
    autoDismiss: true,
    builder: (context) => ToastCard(
      leading: Icon(
        success ? Icons.check_circle : Icons.flutter_dash,
        size: 28,
      ),
      title: Text(
        message,
        style: const TextStyle(
          fontWeight: FontWeight.w700,
          fontSize: 14,
        ),
      ),
    ),
  ).show(context);
}
