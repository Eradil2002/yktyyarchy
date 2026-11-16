import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';

/// Helper class for managing app permissions
class PermissionHelper {
  /// Request camera permission
  /// Returns true if granted, false otherwise
  static Future<bool> requestCamera(BuildContext context) async {
    final status = await Permission.camera.status;

    if (status.isGranted) {
      return true;
    }

    if (status.isDenied) {
      final result = await Permission.camera.request();
      if (result.isGranted) {
        return true;
      }
      if (result.isPermanentlyDenied) {
        _showSettingsDialog(
          context,
          'Доступ к камере',
          'Для создания фотографий "До/После" необходим доступ к камере. '
          'Пожалуйста, разрешите доступ в настройках приложения.',
        );
      }
      return false;
    }

    if (status.isPermanentlyDenied) {
      _showSettingsDialog(
        context,
        'Доступ к камере',
        'Для создания фотографий "До/После" необходим доступ к камере. '
        'Пожалуйста, разрешите доступ в настройках приложения.',
      );
      return false;
    }

    return false;
  }

  /// Request photo library permission
  /// Returns true if granted, false otherwise
  static Future<bool> requestPhotos(BuildContext context) async {
    final status = await Permission.photos.status;

    if (status.isGranted || status.isLimited) {
      return true;
    }

    if (status.isDenied) {
      final result = await Permission.photos.request();
      if (result.isGranted || result.isLimited) {
        return true;
      }
      if (result.isPermanentlyDenied) {
        _showSettingsDialog(
          context,
          'Доступ к фотографиям',
          'Для загрузки фотографий необходим доступ к галерее. '
          'Пожалуйста, разрешите доступ в настройках приложения.',
        );
      }
      return false;
    }

    if (status.isPermanentlyDenied) {
      _showSettingsDialog(
        context,
        'Доступ к фотографиям',
        'Для загрузки фотографий необходим доступ к галерее. '
        'Пожалуйста, разрешите доступ в настройках приложения.',
      );
      return false;
    }

    return false;
  }

  /// Request location permission
  /// Returns true if granted, false otherwise
  static Future<bool> requestLocation(BuildContext context) async {
    final status = await Permission.locationWhenInUse.status;

    if (status.isGranted) {
      return true;
    }

    if (status.isDenied) {
      final result = await Permission.locationWhenInUse.request();
      if (result.isGranted) {
        return true;
      }
      if (result.isPermanentlyDenied) {
        _showSettingsDialog(
          context,
          'Доступ к геолокации',
          'Для отображения мероприятий рядом с вами необходим доступ к геолокации. '
          'Пожалуйста, разрешите доступ в настройках приложения.',
        );
      }
      return false;
    }

    if (status.isPermanentlyDenied) {
      _showSettingsDialog(
        context,
        'Доступ к геолокации',
        'Для отображения мероприятий рядом с вами необходим доступ к геолокации. '
        'Пожалуйста, разрешите доступ в настройках приложения.',
      );
      return false;
    }

    return false;
  }

  /// Request notification permission
  /// Returns true if granted, false otherwise
  static Future<bool> requestNotifications(BuildContext context) async {
    final status = await Permission.notification.status;

    if (status.isGranted) {
      return true;
    }

    if (status.isDenied) {
      final result = await Permission.notification.request();
      if (result.isGranted) {
        return true;
      }
      if (result.isPermanentlyDenied) {
        _showSettingsDialog(
          context,
          'Доступ к уведомлениям',
          'Для получения уведомлений о новых мероприятиях необходимо разрешить уведомления. '
          'Пожалуйста, разрешите доступ в настройках приложения.',
        );
      }
      return false;
    }

    if (status.isPermanentlyDenied) {
      _showSettingsDialog(
        context,
        'Доступ к уведомлениям',
        'Для получения уведомлений о новых мероприятиях необходимо разрешить уведомления. '
        'Пожалуйста, разрешите доступ в настройках приложения.',
      );
      return false;
    }

    return false;
  }

  /// Check if camera permission is granted
  static Future<bool> isCameraGranted() async {
    return await Permission.camera.isGranted;
  }

  /// Check if photos permission is granted
  static Future<bool> isPhotosGranted() async {
    final status = await Permission.photos.status;
    return status.isGranted || status.isLimited;
  }

  /// Check if location permission is granted
  static Future<bool> isLocationGranted() async {
    return await Permission.locationWhenInUse.isGranted;
  }

  /// Check if notification permission is granted
  static Future<bool> isNotificationGranted() async {
    return await Permission.notification.isGranted;
  }

  /// Show dialog to open app settings
  static void _showSettingsDialog(
    BuildContext context,
    String title,
    String message,
  ) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Отмена'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              openAppSettings();
            },
            child: const Text('Настройки'),
          ),
        ],
      ),
    );
  }

  /// Request multiple permissions at once
  static Future<Map<Permission, PermissionStatus>> requestMultiple(
    List<Permission> permissions,
  ) async {
    return await permissions.request();
  }
}
