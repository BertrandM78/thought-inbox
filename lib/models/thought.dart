/// Une pensée déposée dans l’inbox.
class Thought {
  const Thought({
    required this.id,
    required this.text,
    required this.createdAt,
    this.archived = false,
  });

  /// Lit une pensée sérialisée. Lève [FormatException] si la donnée est
  /// incomplète ou mal typée.
  factory Thought.fromJson(Object? json) {
    if (json is! Map<String, Object?>) {
      throw const FormatException('Pensée : objet JSON attendu.');
    }
    final id = json['id'];
    final text = json['text'];
    final createdAt = json['createdAt'];
    final archived = json['archived'];
    if (id is! String || id.isEmpty) {
      throw const FormatException('Pensée : identifiant invalide.');
    }
    if (text is! String) {
      throw const FormatException('Pensée : texte invalide.');
    }
    if (createdAt is! String) {
      throw const FormatException('Pensée : date invalide.');
    }
    if (archived is! bool) {
      throw const FormatException('Pensée : état archivé invalide.');
    }
    return Thought(
      id: id,
      text: text,
      createdAt: DateTime.parse(createdAt),
      archived: archived,
    );
  }

  final String id;
  final String text;
  final DateTime createdAt;
  final bool archived;

  Thought copyWith({bool? archived}) => Thought(
    id: id,
    text: text,
    createdAt: createdAt,
    archived: archived ?? this.archived,
  );

  Map<String, Object?> toJson() => {
    'id': id,
    'text': text,
    'createdAt': createdAt.toUtc().toIso8601String(),
    'archived': archived,
  };

  @override
  bool operator ==(Object other) =>
      other is Thought &&
      other.id == id &&
      other.text == text &&
      other.createdAt.isAtSameMomentAs(createdAt) &&
      other.archived == archived;

  @override
  int get hashCode =>
      Object.hash(id, text, createdAt.microsecondsSinceEpoch, archived);
}
