import 'package:flutter_test/flutter_test.dart';
import 'package:thought_inbox/models/thought.dart';

void main() {
  test('sérialise puis relit une pensée à l’identique', () {
    final thought = Thought(
      id: 'abc',
      text: 'Explorer cette idée samedi',
      createdAt: DateTime.utc(2026, 10, 20, 14, 5),
      archived: true,
    );

    expect(Thought.fromJson(thought.toJson()), thought);
  });

  test('refuse une pensée incomplète ou mal typée', () {
    final valid = {
      'id': 'abc',
      'text': 'x',
      'createdAt': '2026-10-20T14:05:00.000Z',
      'archived': false,
    };

    expect(() => Thought.fromJson('pas un objet'), throwsFormatException);
    for (final key in valid.keys) {
      expect(
        () => Thought.fromJson({...valid}..remove(key)),
        throwsFormatException,
        reason: 'clé manquante : $key',
      );
    }
    expect(
      () => Thought.fromJson({...valid, 'archived': 'non'}),
      throwsFormatException,
    );
    expect(
      () => Thought.fromJson({...valid, 'createdAt': 'hier'}),
      throwsFormatException,
    );
  });
}
