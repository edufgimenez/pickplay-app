import 'package:flutter_test/flutter_test.dart';
import 'package:pickplay/models/raffle_item.dart';
import 'package:pickplay/models/raffle_history.dart';

void main() {
  group('PickPlay Models Test', () {
    test('RaffleItem creation and JSON serialization', () {
      final item = RaffleItem(
        title: 'Interstellar',
        category: 'movies',
        monthKey: '2026-08',
      );

      expect(item.title, 'Interstellar');
      expect(item.category, 'movies');
      expect(item.monthKey, '2026-08');
      expect(item.isDrawn, false);

      final json = item.toJson();
      final restored = RaffleItem.fromJson(json);

      expect(restored.id, item.id);
      expect(restored.title, 'Interstellar');
      expect(restored.category, 'movies');
    });

    test('RaffleHistoryRecord creation and JSON serialization', () {
      final history = RaffleHistoryRecord(
        title: 'Stranger Things',
        category: 'series',
        monthKey: '2026-08',
      );

      expect(history.title, 'Stranger Things');
      expect(history.category, 'series');

      final json = history.toJson();
      final restored = RaffleHistoryRecord.fromJson(json);

      expect(restored.id, history.id);
      expect(restored.title, 'Stranger Things');
    });
  });
}
