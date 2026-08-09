import 'package:fluttertoast/fluttertoast.dart';
import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

/// Point unique des notifications toast - une confirmation apres chaque
/// action CRUD (guide ultime), pas d'emoji, couleurs de la charte.
class AppToast {
  AppToast._();

  static void success(String message) => _show(message, AppColors.success);

  static void error(String message) => _show(message, AppColors.primary);

  static void _show(String message, Color color) {
    Fluttertoast.showToast(
      msg: message,
      toastLength: Toast.LENGTH_LONG,
      gravity: ToastGravity.BOTTOM,
      backgroundColor: color,
      textColor: Colors.white,
      fontSize: 14,
    );
  }
}
