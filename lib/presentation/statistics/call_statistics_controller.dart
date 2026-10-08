import 'package:call_schedular/domain/entity/call_list_entity.dart';
import 'package:call_schedular/domain/usecase/call_use_case.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class CallStatisticsController extends GetxController {
  bool isLoading = true;
  String? errorMessage;
  List<CallListEntity> calls = [];

  int get totalCalls => calls.length;
  int get completedCalls => calls.where((call) => call.status == CallStatusEntity.completed).length;
  int get missedCalls => calls.where((call) => call.status == CallStatusEntity.missed).length;
  int get upcomingCalls => calls.where((call) => call.status == CallStatusEntity.upcoming).length;
  int get recurringCalls => calls.where((call) => call.isRecurring).length;

  double get completionRate {
    final finishedCalls = completedCalls + missedCalls;
    return finishedCalls == 0 ? 0 : completedCalls / finishedCalls;
  }

  List<int> get lastSevenDaysCompleted => List.generate(7, (index) {
    final day = DateUtils.dateOnly(DateTime.now().subtract(Duration(days: 6 - index)));
    return calls.where((call) => call.status == CallStatusEntity.completed && _isSameDay(call.scheduledAt, day)).length;
  });

  List<int> get lastSevenDaysMissed => List.generate(7, (index) {
    final day = DateUtils.dateOnly(DateTime.now().subtract(Duration(days: 6 - index)));
    return calls.where((call) => call.status == CallStatusEntity.missed && _isSameDay(call.scheduledAt, day)).length;
  });

  int get busiestDayCount {
    final values = [...lastSevenDaysCompleted, ...lastSevenDaysMissed];
    return values.isEmpty ? 0 : values.reduce((a, b) => a > b ? a : b);
  }

  String dayLabel(int index) {
    final day = DateTime.now().subtract(Duration(days: 6 - index));
    const labels = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    return labels[day.weekday - 1];
  }

  Future<void> loadStatistics() async {
    try {
      isLoading = true;
      errorMessage = null;
      update();

      final useCase = Get.find<CallUseCase>();
      final loadedCalls = await useCase.getCallList();
      calls = await useCase.processOverdueCalls(loadedCalls);
    } catch (e) {
      errorMessage = 'Unable to load call statistics.';
      debugPrint('Error loading call statistics: $e');
    } finally {
      isLoading = false;
      update();
    }
  }

  bool _isSameDay(DateTime first, DateTime second) {
    return first.year == second.year && first.month == second.month && first.day == second.day;
  }

  @override
  void onInit() {
    super.onInit();
    loadStatistics();
  }
}
