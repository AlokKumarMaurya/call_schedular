import 'package:call_schedular/domain/entity/call_list_entity.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('CallListEntity.nextOccurrenceDate', () {
    final friday = DateTime(2026, 10, 9, 14, 30);

    CallListEntity recurring(String repeat) => CallListEntity(
          id: 'call-1',
          contactName: 'Alex',
          phoneNumber: '1234567890',
          scheduledAt: friday,
          repeat: repeat,
        );

    test('supports custom day and week intervals', () {
      expect(
        recurring('Every 2 days').nextOccurrenceDate,
        DateTime(2026, 10, 11, 14, 30),
      );
      expect(
        recurring('Every 2 weeks').nextOccurrenceDate,
        DateTime(2026, 10, 23, 14, 30),
      );
    });

    test('moves weekday recurrence to the next weekday', () {
      expect(
        recurring('Every weekday').nextOccurrenceDate,
        DateTime(2026, 10, 12, 14, 30),
      );
    });

    test('moves weekend recurrence to the next weekend day', () {
      expect(
        recurring('Every weekend').nextOccurrenceDate,
        DateTime(2026, 10, 10, 14, 30),
      );
    });

    test('moves a named weekday to its next occurrence', () {
      expect(
        recurring('Every Friday').nextOccurrenceDate,
        DateTime(2026, 10, 16, 14, 30),
      );
      expect(
        recurring('Every Monday').nextOccurrenceDate,
        DateTime(2026, 10, 12, 14, 30),
      );
    });

    test('clamps bi-monthly recurrence to the last day of the month', () {
      final monthEnd = recurring('Every 2 months').copyWith(
        scheduledAt: DateTime(2026, 1, 31, 14, 30),
      );

      expect(
        monthEnd.nextOccurrenceDate,
        DateTime(2026, 3, 31, 14, 30),
      );
    });

    test('does not advance one-time calls', () {
      expect(
        recurring('Does not repeat').nextOccurrenceDate,
        friday,
      );
    });
  });
}
