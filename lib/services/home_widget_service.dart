import 'package:call_schedular/domain/entity/call_list_entity.dart';
import 'package:home_widget/home_widget.dart';

class HomeWidgetService {
  HomeWidgetService._();
  static final HomeWidgetService instance = HomeWidgetService._();
  static const String _widgetProviderName = 'CallmateWidgetProvider';

  Future<void> updateUpcomingCalls(List<CallListEntity> calls) async {
    try {
      final upcoming = calls.where((call) =>
          call.status == CallStatusEntity.upcoming &&
          call.scheduledAt.isAfter(DateTime.now())).toList()
        ..sort((a, b) => a.scheduledAt.compareTo(b.scheduledAt));

      await HomeWidget.saveWidgetData<int>('widget_upcoming_count', upcoming.length);
      if (upcoming.isEmpty) {
        await HomeWidget.saveWidgetData<String>('widget_next_name', 'No upcoming calls');
        await HomeWidget.saveWidgetData<String>('widget_next_time', 'Schedule a call from Callmate');
        await HomeWidget.saveWidgetData<String>('widget_next_phone', '');
      } else {
        final nextCall = upcoming.first;
        await HomeWidget.saveWidgetData<String>('widget_next_name', nextCall.contactName.trim().isEmpty ? 'Unknown Contact' : nextCall.contactName.trim());
        await HomeWidget.saveWidgetData<String>('widget_next_time', _formatDateTime(nextCall.scheduledAt));
        await HomeWidget.saveWidgetData<String>('widget_next_phone', nextCall.phoneNumber.trim());
      }
      await HomeWidget.updateWidget(name: _widgetProviderName);
    } catch (_) {
      // Widget failures must never affect the main app.
    }
  }

  String _formatDateTime(DateTime dateTime) {
    final hour = dateTime.hour;
    final minute = dateTime.minute.toString().padLeft(2, '0');
    final formattedHour = hour % 12 == 0 ? 12 : hour % 12;
    final period = hour >= 12 ? 'PM' : 'AM';
    const months = ['Jan','Feb','Mar','Apr','May','Jun','Jul','Aug','Sep','Oct','Nov','Dec'];
    return dateTime.day.toString() + ' ' + months[dateTime.month - 1] + ' ' + formattedHour.toString() + ':' + minute + ' ' + period;
  }
}