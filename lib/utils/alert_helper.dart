import 'package:custom_quick_alert/custom_quick_alert.dart';
import 'package:flutter/material.dart';
import 'package:inventify/theme.dart';

/// Helper functions untuk menampilkan alert dengan CustomQuickAlert
class AlertHelper {
  /// Tampilkan alert success
  static void success(String message, {String? title}) {
    CustomQuickAlert.success(
      title: title ?? 'Berhasil!',
      message: message,
      confirmBtnColor: AppColors.primary,
      titleColor: AppColors.textPrimary,
    );
  }

  /// Tampilkan alert error
  static void error(String message, {String? title}) {
    CustomQuickAlert.error(
      title: title ?? 'Oops...',
      message: message,
      confirmBtnColor: AppColors.habis,
    );
  }

  /// Tampilkan alert warning
  static void warning(String message, {String? title}) {
    CustomQuickAlert.warning(
      title: title ?? 'Perhatian',
      message: message,
      confirmBtnColor: Colors.orange,
    );
  }

  /// Tampilkan alert info
  static void info(String message, {String? title}) {
    CustomQuickAlert.info(
      title: title ?? 'Info',
      message: message,
      confirmBtnColor: AppColors.secondary,
    );
  }

  /// Tampilkan confirmation dialog
  static void confirm({
    required String title,
    required String message,
    required VoidCallback onConfirm,
    VoidCallback? onCancel,
    bool isDangerous = false,
  }) {
    CustomQuickAlert.confirm(
      title: title,
      message: message,
      confirmBtnColor: isDangerous ? AppColors.habis : AppColors.primary,
      onConfirm: onConfirm,
      onCancel: onCancel,
    );
  }
}