import 'package:call_schedular/data/data_source/local/call_local_datasource.dart';
import 'package:call_schedular/domain/entity/call_list_entity.dart';
import 'package:home_widget/home_widget.dart';

class HomeWidgetService {
  HomeWidgetService(this._localDataSource);

  static const String widgetProviderName = 'CallmateWidgetProvider';
  static const String upcomingCountKey = 'widget_upcoming_count';
  static const String nextNameKey = 'widget_next_name';
  static const String nextTimeKey = 'widget_next_time';
  static const String nextPhoneKey = 'widget_next_phone';

  final CallLocalDataSource _localDataSource;

  Future<void> refresh() async {
    try {
      final calls = await _localDataSource.getCallList();
      await refreshWithCalls(calls);
    } catch (_) {}
  }

  Future<void> refreshWithCalls(List<CallListEntity> calls) async {
    try {
      final upcoming = calls.where((call) =>
          call.status == CallStatusEntity.upcoming &&
          call.scheduledAt.isAfter(DateTime.now())).toList()
        ..sort((a, b) => a.scheduledAt.compareTo(b.scheduledAt));

      await HomeWidget.saveWidgetData<int>(upcomingCountKey, upcoming.length);

      if (upcoming.isEmpty) {
        await HomeWidget.saveWidgetData<String>(nextNameKey, 'No upcoming calls');
        await HomeWidget.saveWidgetData<String>(nextTimeKey, 'Schedule a call from Callmate');
        await HomeWidget.saveWidgetData<String>(nextPhoneKey, '');
      } else {
        final nextCall = upcoming.first;
        await HomeWidget.saveWidgetData<String>(
          nextNameKey,
          nextCall.contactName.trim().isEmpty ? 'Unknown Contact' : nextCall.contactName.trim(),
        );
        await HomeWidget.saveWidgetData<String>(nextTimeKey, _formatDateTime(nextCall.scheduledAt));
        await HomeWidget.saveWidgetData<String>(nextPhoneKey, nextCall.phoneNumber.trim());
      }

      await HomeWidget.updateWidget(androidName: widgetProviderName);
    } catch (_) {}
  }

  String _formatDateTime(DateTime dateTime) {
    final hour = dateTime.hour;
    final minute = dateTime.minute.toString().padLeft(2, '0');
    final formattedHour = hour % 12 == 0 ? 12 : hour % 12;
    final period = hour >= 12 ? 'PM' : 'AM';
    const months = ['Jan','Feb','Mar','Apr','May','Jun','Jul','Aug','Sep','Oct','Nov','Dec'];
    return dateTime.day.toString() + ' ' + months[dateTime.month - 1] +
        ' ' + formattedHour.toString() + ':' + minute + ' ' + period;
  }
}