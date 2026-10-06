import 'package:call_schedular/domain/entity/call_list_entity.dart';
import 'package:call_schedular/domain/usecase/call_use_case.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../services/notification_service.dart';

class HomeController extends GetxController
    with GetSingleTickerProviderStateMixin {
  late TabController tabController;

  List<CallListEntity> callListModel = [];

  bool isLoading = false;

  @override
  void onInit() {
    super.onInit();

    // We now have:
    // 0 = Today
    // 1 = Upcoming
    // 2 = Completed
    // 3 = Missed
    tabController = TabController(
      length: 4,
      vsync: this,
    );

    tabController.addListener(() {
      if (!tabController.indexIsChanging) {
        update();
      }
    });

    getCallList();
  }

  Future<void> getCallList() async {
    try {
      isLoading = true;
      update();

      final useCase = Get.find<CallUseCase>();

      final calls = await useCase.getCallList();

      callListModel = await useCase.processOverdueCalls(
        calls,
      );

      await NotificationService.instance.syncUpcomingCallReminders(
        callListModel,
      );
    } catch (e) {
      debugPrint('Error fetching calls: $e');
    } finally {
      isLoading = false;
      update();
    }
  }

  List<CallListEntity> get todayCalls {
    final now = DateTime.now();

    return callListModel.where((call) {
      final date = call.scheduledAt;

      return date.year == now.year &&
          date.month == now.month &&
          date.day == now.day &&
          call.status == CallStatusEntity.upcoming;
    }).toList()
      ..sort(
            (a, b) => a.scheduledAt.compareTo(b.scheduledAt),
      );
  }

  List<CallListEntity> get upcomingCalls {
    final now = DateTime.now();

    return callListModel.where((call) {
      return call.scheduledAt.isAfter(now) &&
          !_isSameDay(call.scheduledAt, now) &&
          call.status == CallStatusEntity.upcoming;
    }).toList()
      ..sort(
            (a, b) => a.scheduledAt.compareTo(b.scheduledAt),
      );
  }

  List<CallListEntity> get completedCalls {
    return callListModel.where((call) {
      return call.status == CallStatusEntity.completed;
    }).toList()
      ..sort(
            (a, b) => b.scheduledAt.compareTo(a.scheduledAt),
      );
  }

  List<CallListEntity> get missedCalls {
    return callListModel.where((call) {
      return call.status == CallStatusEntity.missed;
    }).toList()
      ..sort(
            (a, b) => b.scheduledAt.compareTo(a.scheduledAt),
      );
  }

  bool _isSameDay(
      DateTime first,
      DateTime second,
      ) {
    return first.year == second.year &&
        first.month == second.month &&
        first.day == second.day;
  }

  @override
  void onClose() {
    tabController.dispose();
    super.onClose();
  }
}