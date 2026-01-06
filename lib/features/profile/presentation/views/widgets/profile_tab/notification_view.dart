import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:pharma_now/core/utils/color_manger.dart';
import 'package:pharma_now/core/services/user_settings_service.dart';
import 'package:pharma_now/core/services/get_it_service.dart';
import 'package:pharma_now/features/notifications/presentation/models/user_notification_settings.dart';
import 'package:permission_handler/permission_handler.dart';
import '../../../../../../core/widgets/custom_app_bar.dart';

class Notifications extends StatefulWidget {
  static const String routeName = "Notification";

  const Notifications({super.key});

  @override
  State<Notifications> createState() => _NotificationsState();
}

class _NotificationsState extends State<Notifications>
    with WidgetsBindingObserver {
  final UserSettingsService _settingsService = getIt<UserSettingsService>();
  UserNotificationSettings? _settings;
  bool _isLoading = true;
  bool _isPermissionAllowed = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _initData();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _checkPermission();
    }
  }

  Future<void> _initData() async {
    await _checkPermission();
    await _loadSettings();
  }

  Future<void> _checkPermission() async {
    final status = await Permission.notification.status;
    setState(() {
      _isPermissionAllowed = status.isGranted;
    });
  }

  Future<void> _loadSettings() async {
    setState(() => _isLoading = true);
    final settings = await _settingsService.getSettings();
    setState(() {
      _settings = settings;
      _isLoading = false;
    });
  }

  Future<void> _updateSettings(UserNotificationSettings newSettings) async {
    if (!_isPermissionAllowed) {
      _showPermissionDialog();
      return;
    }
    setState(() => _settings = newSettings);
    await _settingsService.updateSettings(newSettings);
  }

  void _showPermissionDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Row(
          children: [
            Icon(Icons.notifications_off_outlined,
                color: ColorManager.secondaryColor),
            SizedBox(width: 8),
            Text('Notifications Disabled'),
          ],
        ),
        content: const Text(
          'To receive updates about your orders and special offers, please enable notifications in your device settings.',
          style: TextStyle(height: 1.4),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Later',
              style: TextStyle(color: Colors.grey[600]),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              openAppSettings();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: ColorManager.secondaryColor,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8)),
            ),
            child: const Text('Go to Settings'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final width = size.width;

    return Scaffold(
      backgroundColor: ColorManager.primaryColor,
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(48.sp),
        child: PharmaAppBar(
          title: 'Notification Settings',
          isBack: true,
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: EdgeInsets.all(width * 0.05),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Preferences',
                    style: TextStyle(
                      fontSize: width * 0.05,
                      fontWeight: FontWeight.bold,
                      color: Colors.grey[700],
                    ),
                  ),
                  const SizedBox(height: 16),
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      children: [
                        ToggleRow(
                          title: 'System Notifications',
                          value: _isPermissionAllowed &&
                              _settings!.systemNotifications,
                          onChanged: (val) => _updateSettings(
                            UserNotificationSettings(
                              systemNotifications: val,
                              offers: _settings!.offers,
                              orders: _settings!.orders,
                            ),
                          ),
                        ),
                        const Divider(height: 1, color: Color(0xffC6CCD5)),
                        ToggleRow(
                          title: 'New Offers & Promos',
                          value: _isPermissionAllowed && _settings!.offers,
                          onChanged: (val) => _updateSettings(
                            UserNotificationSettings(
                              systemNotifications:
                                  _settings!.systemNotifications,
                              offers: val,
                              orders: _settings!.orders,
                            ),
                          ),
                        ),
                        const Divider(height: 1, color: Color(0xffC6CCD5)),
                        ToggleRow(
                          title: 'Order Status Updates',
                          value: _isPermissionAllowed && _settings!.orders,
                          onChanged: (val) => _updateSettings(
                            UserNotificationSettings(
                              systemNotifications:
                                  _settings!.systemNotifications,
                              offers: _settings!.offers,
                              orders: val,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}

class ToggleRow extends StatelessWidget {
  final String title;
  final bool value;
  final ValueChanged<bool> onChanged;

  const ToggleRow({
    super.key,
    required this.title,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: width * 0.04, vertical: 14),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: width * 0.045,
              fontWeight: FontWeight.w500,
              color: const Color(0xff667387),
            ),
          ),
          Switch(
            value: value,
            onChanged: onChanged,
            activeThumbColor: Colors.white,
            activeTrackColor: ColorManager.secondaryColor,
            inactiveTrackColor: const Color(0xFFA9ABD5),
            inactiveThumbColor: Colors.white,
          ),
        ],
      ),
    );
  }
}
