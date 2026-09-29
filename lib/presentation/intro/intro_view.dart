import 'package:call_schedular/constants/app_images.dart';
import 'package:call_schedular/presentation/intro/intro_controller.dart';
import 'package:call_schedular/theme/app_colors.dart';
import 'package:call_schedular/theme/app_font.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil_plus/flutter_screenutil_plus.dart';
import 'package:get/get.dart';

class IntroView extends StatelessWidget {
  const IntroView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: EdgeInsets.symmetric(vertical: 40.sp, horizontal: 24.sp),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(height: 48.sp),
            Image.asset(AppImages.call, height: 200.sp),
            SizedBox(height: 24.sp),
            RichText(
              text: TextSpan(
                text: 'Call',
                style: AppFont.style.copyWith(
                  color: AppColors.black,
                  fontSize: 32.sp,
                  fontWeight: FontWeight.bold,
                ),
                children: [
                  TextSpan(
                    text: ' Schedular',
                    style: AppFont.style.copyWith(
                      color: AppColors.primary,
                      fontSize: 32.sp,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
            Text(
              'Never miss an important call again',
              textAlign: TextAlign.center,
              style: AppFont.style.copyWith(fontWeight: FontWeight.w500),
            ),
            SizedBox(height: 32.sp),
            ItemListTile(
              bgColor: AppColors.primaryLight,
              iconColor: AppColors.primary,
              icon: Icons.notifications_rounded,
              title: 'Schedule Calls',
              subtitle: 'Set date and time of your call',
            ),
            SizedBox(height: 16.sp),
            ItemListTile(
              bgColor: AppColors.successLight,
              icon: Icons.phone_rounded,
              iconColor: AppColors.success,
              title: 'Receive Reminders',
              subtitle: 'Never miss an important call again',
            ),
            SizedBox(height: 16.sp),
            ItemListTile(
              bgColor: AppColors.purpleLight,
              icon: Icons.bolt_rounded,
              iconColor: AppColors.purple,
              title: 'Block Numbers',
              subtitle: "Block numbers you don't want to see",
            ),
            SizedBox(height: 48.sp),
            GetBuilder<IntroController>(
              init: IntroController(),
              builder: (controller) {
                return GestureDetector(
                  onTap: () => controller.handelGetStarted(),
                  child: Container(
                    width: double.infinity,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(18.sp),
                      color: AppColors.primary,
                    ),
                    padding: EdgeInsets.symmetric(
                      vertical: 12.sp,
                      horizontal: 32.sp,
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      'Get Started',
                      style: AppFont.style.copyWith(
                        fontSize: 16.sp,
                        color: AppColors.white,
                      ),
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

class ItemListTile extends StatelessWidget {
  final Color iconColor;
  final Color bgColor;
  final IconData icon;
  final String title;
  final String subtitle;

  const ItemListTile({
    required this.iconColor,
    required this.bgColor,
    required this.icon,
    required this.subtitle,
    required this.title,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          height: 48.sp,
          width: 48.sp,
          padding: EdgeInsets.all(12.sp),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(18.sp),
            color: bgColor,
          ),
          alignment: Alignment.center,
          child: Icon(icon, color: iconColor),
        ),
        SizedBox(width: 12.sp),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: AppFont.style.copyWith(
                  fontWeight: FontWeight.w500,
                  fontSize: 16.sp,
                ),
              ),
              Text(
                subtitle,
                style: AppFont.style.copyWith(color: AppColors.textSecondary),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
