import 'package:call_schedular/constants/app_const.dart';
import 'package:call_schedular/presentation/home/home_controller.dart';
import 'package:call_schedular/theme/app_colors.dart';
import 'package:call_schedular/theme/app_font.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil_plus/flutter_screenutil_plus.dart';
import 'package:get/get.dart';

class HomeView extends StatelessWidget {
  const HomeView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          AppConst.appName,
          style: AppFont.style.copyWith(
            fontSize: 24.sp,
            fontWeight: FontWeight.w500,
          ),
        ),
        actions: [Icon(Icons.settings_outlined, color: AppColors.black)],
        actionsPadding: EdgeInsets.only(right: 16.w),
      ),
      body: GetBuilder<HomeController>(
        init: HomeController(),
        builder: (controller) {
          return Column(
            children: [
              SizedBox(height: 12.sp),
              TabBar(
                onTap: (value) {
                  controller.update();
                },
                splashFactory: NoSplash.splashFactory,
                overlayColor: WidgetStateProperty.all(Colors.transparent),
                tabAlignment: TabAlignment.start,
                isScrollable: true,
                padding: EdgeInsets.zero,
                dividerColor: Colors.transparent,
                indicator: BoxDecoration(),
                controller: controller.tabController,
                tabs: [
                  FilterChip(
                    isSelected: controller.tabController.index == 0,
                    title: 'Today',
                  ),
                  FilterChip(
                    isSelected: controller.tabController.index == 1,
                    title: 'Upcoming',
                  ),
                  FilterChip(
                    isSelected: controller.tabController.index == 2,
                    title: 'Completed',
                  ),
                ],
              ),
              Expanded(
                child: TabBarView(
                  controller: controller.tabController,
                  children: [Text(''), Text('data'), Text("data1")],
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class FilterChip extends StatelessWidget {
  final String title;
  final bool isSelected;

  const FilterChip({required this.isSelected, required this.title, super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 8.sp, horizontal: 12.sp),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12.sp),
        color: isSelected ? AppColors.primary : AppColors.primaryLight,
      ),
      alignment: Alignment.center,
      child: Text(
        title,
        style: AppFont.style.copyWith(
          color: isSelected ? AppColors.white : AppColors.textTertiary,
        ),
      ),
    );
  }
}
