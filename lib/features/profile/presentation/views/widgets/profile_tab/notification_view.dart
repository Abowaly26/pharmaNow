import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:pharma_now/core/utils/color_manger.dart';

import '../../../../../../core/widgets/custom_app_bar.dart';

class Notifications extends StatelessWidget {
  static const String routeName = "Notification";

  const Notifications({super.key});

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final width = size.width;
    final height = size.height;
    final avatarRadius = width * 0.2;
    final outerCircleSize = avatarRadius * 2.2;
    return Scaffold(
      backgroundColor: ColorManager.primaryColor,
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(48.sp),
        child: PharmaAppBar(
          title: 'Notifications',
          isBack: true,
          onPressed: () {
            Navigator.pop(
              context,
            );
          },
        ),
      ),
      body: Padding(
        padding: EdgeInsets.all(width * 0.05),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Section title
            Text(
              'General',
              style: TextStyle(
                fontSize: width * 0.05,
                fontWeight: FontWeight.bold,
                color: Colors.grey[700],
              ),
            ),
            const SizedBox(height: 16),

            // Box containing switches
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                children: const [
                  ToggleRow(title: 'Promotion', value: true),
                  Divider(
                    height: 1,
                    color: Color(0xffC6CCD5),
                  ),
                  ToggleRow(title: 'New Offer', value: false),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class ToggleRow extends StatefulWidget {
  final String title;
  final bool value;

  const ToggleRow({super.key, required this.title, required this.value});

  @override
  State<ToggleRow> createState() => _ToggleRowState();
}

class _ToggleRowState extends State<ToggleRow> {
  late bool _isOn;

  @override
  void initState() {
    _isOn = widget.value;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: width * 0.04, vertical: 14),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            widget.title,
            style: TextStyle(
              fontSize: width * 0.045,
              fontWeight: FontWeight.w500,
              color: Color(0xff667387),
            ),
          ),
          Switch(
            value: _isOn,
            onChanged: (val) {
              setState(() {
                _isOn = val;
              });
            },
            activeThumbColor: Colors.white,
            activeTrackColor: ColorManager.secondaryColor,
            inactiveTrackColor: Color(0xFFA9ABD5),
            inactiveThumbColor: Colors.white,
          ),
        ],
      ),
    );
  }
}
