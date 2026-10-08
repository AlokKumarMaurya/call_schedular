import 'package:call_schedular/domain/entity/call_list_entity.dart';
import 'package:call_schedular/domain/usecase/call_use_case.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../services/notification_service.dart';
import '../../services/home_widget_service.dart';

enum CallDateFilter {
  all,
  today,
  tomorrow,
  thisWeek,
  custom,
}

enum CallRecurrenceFilter {
  all,
  recurring,
  nonRecurring,
}

class HomeController extends GetxController
    with GetSingleTickerProviderStateMixin {
  late TabController tabController;

  List<CallListEntity> callListModel = [];

  bool isLoading = false;

  final searchController = TextEditingController();

  String searchQuery = '';

  CallDateFilter dateFilter = CallDateFilter.all;

  CallRecurrenceFilter recurrenceFilter = CallRecurrenceFilter.all;

  DateTime? customFilterDate;

  bool get hasSearchFilters {
    return searchQuery.isNotEmpty ||
        dateFilter != CallDateFilter.all ||
        recurrenceFilter != CallRecurrenceFilter.all;
  }

  @override
  void onInit() {
    super.onInit();

    // We now have:
    // 0 = Today
    // 1 = Upcoming
    // 2 = Completed
    // 3 = Missed
    tabController = TabController(length: 4, vsync: this);

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

      callListModel = await useCase.processOverdueCalls(calls);

      await NotificationService.instance.syncUpcomingCallReminders(
        callListModel,
      );

      await HomeWidgetService.instance.updateUpcomingCalls(
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

    return _filterCalls(
      callListModel.where((call) {
        final date = call.scheduledAt;

        return date.year == now.year &&
            date.month == now.month &&
            date.day == now.day &&
            call.status == CallStatusEntity.upcoming;
      }).toList(),
    )..sort(
        (a, b) => a.scheduledAt.compareTo(b.scheduledAt),
      );
  }

  List<CallListEntity> get upcomingCalls {
    final now = DateTime.now();

    return _filterCalls(
      callListModel.where((call) {
        return call.scheduledAt.isAfter(now) &&
            !_isSameDay(call.scheduledAt, now) &&
            call.status == CallStatusEntity.upcoming;
      }).toList(),
    )..sort(
        (a, b) => a.scheduledAt.compareTo(b.scheduledAt),
      );
  }

  List<CallListEntity> get completedCalls {
    return _filterCalls(
      callListModel.where((call) {
        return call.status == CallStatusEntity.completed;
      }).toList(),
    )..sort(
        (a, b) => b.scheduledAt.compareTo(a.scheduledAt),
      );
  }

  List<CallListEntity> get missedCalls {
    return _filterCalls(
      callListModel.where((call) {
        return call.status == CallStatusEntity.missed;
      }).toList(),
    )..sort(
        (a, b) => b.scheduledAt.compareTo(a.scheduledAt),
      );
  }

  bool _isSameDay(DateTime first, DateTime second) {
    return first.year == second.year &&
        first.month == second.month &&
        first.day == second.day;
  }

  void setSearchQuery(String value) {
    searchQuery = value.trim().toLowerCase();
    update();
  }

  void clearSearch() {
    searchController.clear();
    searchQuery = '';
    update();
  }

  void setDateFilter(
    CallDateFilter filter, {
    DateTime? customDate,
  }) {
    dateFilter = filter;
    customFilterDate = filter == CallDateFilter.custom
        ? customDate
        : null;
    update();
  }

  void setRecurrenceFilter(CallRecurrenceFilter filter) {
    recurrenceFilter = filter;
    update();
  }

  void clearSearchFilters() {
    searchController.clear();
    searchQuery = '';
    dateFilter = CallDateFilter.all;
    recurrenceFilter = CallRecurrenceFilter.all;
    customFilterDate = null;
    update();
  }

  String get dateFilterLabel {
    switch (dateFilter) {
      case CallDateFilter.all:
        return 'Any date';
      case CallDateFilter.today:
        return 'Today';
      case CallDateFilter.tomorrow:
        return 'Tomorrow';
      case CallDateFilter.thisWeek:
        return 'This week';
      case CallDateFilter.custom:
        if (customFilterDate == null) {
          return 'Custom date';
        }
        return customFilterDate!.day.toString() +
            '/' +
            customFilterDate!.month.toString() +
            '/' +
            customFilterDate!.year.toString();
    }
  }

  String get recurrenceFilterLabel {
    switch (recurrenceFilter) {
      case CallRecurrenceFilter.all:
        return 'All calls';
      case CallRecurrenceFilter.recurring:
        return 'Recurring';
      case CallRecurrenceFilter.nonRecurring:
        return 'One-time';
    }
  }

  List<CallListEntity> _filterCalls(List<CallListEntity> calls) {
    return calls.where((call) {
      final matchesSearch = _matchesSearch(call);
      final matchesDate = _matchesDateFilter(call.scheduledAt);
      final matchesRecurrence =
          recurrenceFilter == CallRecurrenceFilter.all ||
          (recurrenceFilter == CallRecurrenceFilter.recurring &&
              call.isRecurring) ||
          (recurrenceFilter == CallRecurrenceFilter.nonRecurring &&
              !call.isRecurring);

      return matchesSearch && matchesDate && matchesRecurrence;
    }).toList();
  }

  bool _matchesSearch(CallListEntity call) {
    if (searchQuery.isEmpty) {
      return true;
    }

    final contactName = call.contactName.toLowerCase();
    final phoneNumber = call.phoneNumber.toLowerCase();
    final notes = call.notes?.toLowerCase() ?? '';

    return contactName.contains(searchQuery) ||
        phoneNumber.contains(searchQuery) ||
        notes.contains(searchQuery);
  }

  bool _matchesDateFilter(DateTime date) {
    switch (dateFilter) {
      case CallDateFilter.all:
        return true;
      case CallDateFilter.today:
        return _isSameDay(date, DateTime.now());
      case CallDateFilter.tomorrow:
        return _isSameDay(
          date,
          DateTime.now().add(const Duration(days: 1)),
        );
      case CallDateFilter.thisWeek:
        final now = DateTime.now();
        final today = DateTime(now.year, now.month, now.day);
        final startOfWeek = today.subtract(
          Duration(days: today.weekday - DateTime.monday),
        );
        final endOfWeek = startOfWeek.add(const Duration(days: 7));

        return !date.isBefore(startOfWeek) && date.isBefore(endOfWeek);
      case CallDateFilter.custom:
        return customFilterDate != null &&
            _isSameDay(date, customFilterDate!);
    }
  }

  @override
  void onClose() {
    searchController.dispose();
    tabController.dispose();
    super.onClose();
  }
}
