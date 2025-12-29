import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:pharma_now/core/utils/color_manger.dart';
import 'package:pharma_now/core/utils/text_styles.dart';

class PermissionService {
  static Future<bool> handleCameraPermission(
    BuildContext context, {
    String? title,
    String? content,
  }) async {
    PermissionStatus status = await Permission.camera.status;

    if (status.isGranted) {
      return true;
    }

    if (status.isDenied) {
      // Request permission
      status = await Permission.camera.request();
      if (status.isGranted) {
        return true;
      }
    }

    if (status.isPermanentlyDenied || status.isDenied) {
      if (context.mounted) {
        _showPermissionDialog(
          context,
          title: title ?? 'Camera Permission Required',
          content: content ??
              'This app needs camera access to take pictures. Please enable it in your device settings.',
          isPermanentlyDenied: status.isPermanentlyDenied,
        );
      }
      return false;
    }

    return false;
  }

  static Future<bool> handleGalleryPermission(
    BuildContext context, {
    String? title,
    String? content,
  }) async {
    // For Android 13+ (API 33+), we use photoLibrary. On older or iOS, it's storage/photos.
    // permission_handler handles this mapping mostly, but let's be safe.
    PermissionStatus status = await Permission.photos.status;

    if (status.isGranted || status.isLimited) {
      return true;
    }

    if (status.isDenied) {
      status = await Permission.photos.request();
      if (status.isGranted || status.isLimited) {
        return true;
      }
    }

    // Fallback for some android versions where photos might not be the one
    if (status.isDenied) {
      status = await Permission.storage.request();
      if (status.isGranted) return true;
    }

    if (status.isPermanentlyDenied || status.isDenied) {
      if (context.mounted) {
        _showPermissionDialog(
          context,
          title: title ?? 'Gallery Permission Required',
          content: content ??
              'This app needs access to your gallery to choose pictures. Please enable it in your device settings.',
          isPermanentlyDenied: status.isPermanentlyDenied,
        );
      }
      return false;
    }

    return false;
  }

  static void _showPermissionDialog(
    BuildContext context, {
    required String title,
    required String content,
    required bool isPermanentlyDenied,
  }) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: ColorManager.primaryColor,
        title: Text(
          title,
          style: TextStyles.settingItemTitle.copyWith(color: Colors.red),
        ),
        content: Text(
          content,
          style: TextStyles.skip.copyWith(color: Colors.black87),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel', style: TextStyle(color: Colors.grey)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: ColorManager.secondaryColor,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            onPressed: () async {
              Navigator.pop(context);
              if (isPermanentlyDenied) {
                await openAppSettings();
              } else {
                // If it was just denied, we already requested it.
                // This button could just say "Settings" anyway for consistency.
                await openAppSettings();
              }
            },
            child: Text(
              'Open Settings',
              style: TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }
}
