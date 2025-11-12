import 'package:flutter/material.dart';
import 'snackbar_utils.dart';

/// Utility class for handling errors consistently across the app
class ErrorHandlingUtils {
  /// Handle Firebase errors and show appropriate snackbar
  static void handleFirebaseError(BuildContext context, dynamic error) {
    String message = 'An error occurred. Please try again.';

    if (error.toString().contains('network')) {
      message = 'Network error. Please check your connection.';
    } else if (error.toString().contains('permission')) {
      message = 'Permission denied. Please check your access rights.';
    } else if (error.toString().contains('not-found')) {
      message = 'The requested data was not found.';
    } else if (error.toString().contains('already-exists')) {
      message = 'This item already exists.';
    }

    SnackbarUtils.showError(context, message);
  }

  /// Handle form validation errors
  static void handleValidationError(BuildContext context, String message) {
    SnackbarUtils.showWarning(context, message);
  }

  /// Handle success operations
  static void handleSuccess(BuildContext context, String message) {
    SnackbarUtils.showSuccess(context, message);
  }

  /// Show loading indicator
  static ScaffoldFeatureController<SnackBar, SnackBarClosedReason> showLoading(
    BuildContext context,
    String message,
  ) {
    return SnackbarUtils.showLoading(context, message);
  }

  /// Hide loading indicator
  static void hideLoading(BuildContext context) {
    SnackbarUtils.hide(context);
  }

  /// Check if error is network related
  static bool isNetworkError(dynamic error) {
    return error.toString().contains('network') ||
        error.toString().contains('connection') ||
        error.toString().contains('timeout');
  }

  /// Check if error is permission related
  static bool isPermissionError(dynamic error) {
    return error.toString().contains('permission') ||
        error.toString().contains('denied') ||
        error.toString().contains('unauthorized');
  }

  /// Get user-friendly error message
  static String getUserFriendlyMessage(dynamic error) {
    final errorString = error.toString().toLowerCase();

    if (errorString.contains('network') || errorString.contains('connection')) {
      return 'Unable to connect. Please check your internet connection.';
    } else if (errorString.contains('timeout')) {
      return 'Request timed out. Please try again.';
    } else if (errorString.contains('permission') || errorString.contains('denied')) {
      return 'You don\'t have permission to perform this action.';
    } else if (errorString.contains('not-found')) {
      return 'The requested item was not found.';
    } else if (errorString.contains('already-exists')) {
      return 'This item already exists.';
    } else if (errorString.contains('invalid')) {
      return 'Invalid data provided. Please check your input.';
    } else {
      return 'Something went wrong. Please try again.';
    }
  }
}
