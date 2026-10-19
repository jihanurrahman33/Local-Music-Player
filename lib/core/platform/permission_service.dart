import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:permission_handler/permission_handler.dart';

class PermissionService {
  static Future<bool> hasMediaPermission() async {
    if (kIsWeb) return true;
    try {
      if (Platform.isAndroid) {
        // Android 13+ (API 33+) uses audio permission; older uses storage
        final audioStatus = await Permission.audio.status;
        if (audioStatus.isGranted) return true;

        final storageStatus = await Permission.storage.status;
        return storageStatus.isGranted;
      }
      if (Platform.isIOS) {
        // iOS doesn't require runtime storage permission for document picker
        return true;
      }
      return true;
    } catch (e) {
      debugPrint('Error checking media permissions: $e');
      return false;
    }
  }

  static Future<bool> requestMediaPermission() async {
    if (kIsWeb) return true;
    try {
      if (Platform.isAndroid) {
        // Request notification permission for playback notification on Android 13+
        await Permission.notification.request();

        // Request audio permission
        final audioStatus = await Permission.audio.request();
        if (audioStatus.isGranted) return true;

        // Fallback to legacy storage for Android 12 and below
        final storageStatus = await Permission.storage.request();
        return storageStatus.isGranted;
      }
      return true;
    } catch (e) {
      debugPrint('Error requesting media permissions: $e');
      return false;
    }
  }

  static Future<void> openSettings() async {
    if (!kIsWeb) {
      await openAppSettings();
    }
  }
}
