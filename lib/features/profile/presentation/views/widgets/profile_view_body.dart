import 'package:flutter/material.dart';
import 'package:pharma_now/features/profile/presentation/views/widgets/profile_tab/CustomRowWidget.dart';
import 'package:pharma_now/features/profile/presentation/views/widgets/profile_tab/edit_profile_view.dart';
import 'package:pharma_now/features/profile/presentation/views/widgets/profile_tab/notification_view.dart';

import '../../../../../core/helper_functions/get_user.dart';

class ProfileViewBody extends StatelessWidget {
  const ProfileViewBody({super.key});

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final width = size.width;
    final height = size.height;
    // Reduce avatar size by multiplying by a smaller factor
    final avatarRadius = width * 0.15; // Reduced from 0.2
    final outerCircleSize = avatarRadius * 2.2;
    return SafeArea(
      child: SingleChildScrollView(
        child: Center(
          child: Column(
            children: [
              SizedBox(height: 0.03 * height),
              Stack(
                alignment: Alignment.center,
                children: [
                  SizedBox(
                    width: outerCircleSize,
                    height: outerCircleSize,
                    child: CustomPaint(painter: ArcPainter()),
                  ),
                  CircleAvatar(
                    radius: avatarRadius,
                    backgroundImage: const NetworkImage(
                      'https://randomuser.me/api/portraits/men/32.jpg',
                    ),
                  ),
                  Positioned(
                    // Adjust positioning of camera icon for smaller avatar
                    left: width * 0.25, // Adjusted from 0.32
                    right: width * 0.19, // Adjusted from 0.12
                    bottom: width * 0.01,
                    child: Container(
                      // Make camera icon smaller
                      padding: const EdgeInsets.all(5), // Reduced from 7
                      decoration: BoxDecoration(
                        color: Colors.blue,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.camera_alt,
                        size: 20, // Reduced from 30
                        color: Colors.blue,
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 0.01 * height),
              Text(
                '${getUser().name}',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 0.01 * height),
              Text(
                '${getUser().email}',
                style: TextStyle(fontSize: 16, color: Color(0xff718096)),
              ),
              SizedBox(height: 0.04 * height),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 0.05 * width),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    'Account Settings',
                    style: TextStyle(fontSize: 18, color: Color(0xFF4F5159)),
                  ),
                ),
              ),
              SettingItem(
                icon: Icons.person,
                title: "Edit Profile",
                onTap: () {
                  Navigator.pushNamed(context, EditProfile.routeName);
                },
              ),
              SizedBox(height: 0.01 * height),
              SettingItem(
                icon: Icons.notifications,
                title: "Notifications",
                onTap: () {
                  Navigator.pushNamed(context, Notifications.routeName);
                },
              ),
              SizedBox(height: 0.01 * height),
              SettingItem(
                icon: Icons.security,
                title: "Term Of Service",
                onTap: () {},
              ),
              SizedBox(height: 0.01 * height),
              SettingItem(icon: Icons.lock, title: "Change Password"),
              SizedBox(height: 0.01 * height),
              SettingItem(icon: Icons.help_outlined, title: "Help and Support"),
              SizedBox(height: 0.01 * height),
              SettingItem(icon: Icons.logout, title: "Logout"),
              SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}

class ArcPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final strokeWidth = 5.0;
    final rect = Offset.zero & size;

    final paint = Paint()
      ..color = Colors.blue
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    canvas.drawArc(
      rect.deflate(strokeWidth / 2),
      1.45,
      5.2,
      false,
      paint,
    );
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}
