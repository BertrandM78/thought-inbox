const _months = [
  'janv.',
  'févr.',
  'mars',
  'avr.',
  'mai',
  'juin',
  'juil.',
  'août',
  'sept.',
  'oct.',
  'nov.',
  'déc.',
];

/// Formate une date en français, en heure locale : « 20 oct. 2026, 14:05 ».
String formatThoughtDate(DateTime date) {
  final local = date.toLocal();
  final hour = local.hour.toString().padLeft(2, '0');
  final minute = local.minute.toString().padLeft(2, '0');
  return '${local.day} ${_months[local.month - 1]} ${local.year}, '
      '$hour:$minute';
}

/// Âge relatif en français. Les jours sont comptés en jours calendaires
/// locaux : « hier » désigne la veille, quelle que soit l’heure.
String formatRelativeThoughtDate(DateTime date, {required DateTime now}) {
  final difference = now.difference(date);
  if (difference.inMinutes < 1) return 'à l’instant';
  if (difference.inMinutes < 60) {
    return 'il y a ${difference.inMinutes} min';
  }
  final days = _calendarDaysBetween(date.toLocal(), now.toLocal());
  if (days == 0) return 'il y a ${difference.inHours} h';
  if (days == 1) return 'hier';
  if (days < 7) return 'il y a $days j';
  return formatThoughtDate(date);
}

// Dates UTC pour ignorer les changements d’heure.
int _calendarDaysBetween(DateTime from, DateTime to) => DateTime.utc(
  to.year,
  to.month,
  to.day,
).difference(DateTime.utc(from.year, from.month, from.day)).inDays;
