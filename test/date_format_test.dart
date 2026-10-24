import 'package:flutter_test/flutter_test.dart';
import 'package:thought_inbox/ui/date_format.dart';

void main() {
  final now = DateTime(2026, 10, 20, 14, 5);

  String relative(Duration age) =>
      formatRelativeThoughtDate(now.subtract(age), now: now);

  test('minutes et heures du jour', () {
    expect(relative(const Duration(seconds: 30)), 'à l’instant');
    expect(relative(const Duration(minutes: 25)), 'il y a 25 min');
    expect(relative(const Duration(hours: 3)), 'il y a 3 h');
  });

  test('« hier » désigne la veille calendaire locale', () {
    final morning = DateTime(2026, 10, 20, 0, 30);
    expect(
      formatRelativeThoughtDate(DateTime(2026, 10, 19, 23, 0), now: morning),
      'hier',
    );
    expect(
      formatRelativeThoughtDate(DateTime(2026, 10, 19, 8, 0), now: now),
      'hier',
    );
    expect(
      formatRelativeThoughtDate(DateTime(2026, 10, 18, 22, 0), now: now),
      'il y a 2 j',
    );
  });

  test('date absolue au-delà d’une semaine', () {
    expect(
      formatRelativeThoughtDate(DateTime(2026, 10, 1, 9, 7), now: now),
      '1 oct. 2026, 09:07',
    );
  });
}
