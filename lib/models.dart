import 'dart:math' as math;

enum PayStatus { pending, declared, confirmed, late }

class Member {
  final String name;
  final String city;
  final int rank;
  final String role;
  PayStatus status;
  String? reference;
  String? guarantor;
  bool guaranteePaid;

  Member({
    required this.name,
    required this.city,
    required this.rank,
    this.role = 'Membre',
    this.status = PayStatus.pending,
    this.reference,
    this.guarantor,
    this.guaranteePaid = false,
  });
}

class LogEntry {
  final String when;
  final String text;
  LogEntry(this.when, this.text);
}

class Group {
  String name;
  double contribution;
  String currency;
  String frequency;
  int dueDay;
  int currentRound;
  DateTime start;
  final List<Member> members;
  final List<LogEntry> log;

  Group({
    required this.name,
    required this.contribution,
    required this.currency,
    required this.frequency,
    required this.dueDay,
    required this.currentRound,
    required this.start,
    required this.members,
    required this.log,
  });

  int get size => members.length;
  double get pot => contribution * size;

  Member get beneficiary =>
      members.firstWhere((m) => m.rank == currentRound, orElse: () => members.first);

  int get confirmedCount =>
      members.where((m) => m.status == PayStatus.confirmed).length;

  String roundLabel(int rank) => frequency == 'Mensuelle'
      ? monthName(DateTime(start.year, start.month + rank - 1))
      : 'tour $rank';
}

// ---------------------------------------------------------------------------
// Règles de garantie (voir le document « Likelemba - Concept, garanties »).
// ---------------------------------------------------------------------------

/// Perte maximale du groupe si le membre de ce rang arrête juste après son tour.
double maxLoss(int n, int rank, double c) => (n - rank) * c;

/// Garantie en espèces : 50 % de la perte possible, minimum une cotisation.
double requiredGuarantee(int n, int rank, double c) =>
    math.max(c, 0.5 * maxLoss(n, rank, c));

/// Un garant personnel est obligatoire pour la première moitié des rangs.
bool guarantorRequired(int n, int rank) => rank <= n ~/ 2;

/// Part de la perte possible couverte par le garant (l'autre moitié).
double guarantorShare(int n, int rank, double c) =>
    guarantorRequired(n, rank) ? 0.5 * maxLoss(n, rank, c) : 0;

String guarantorNote(int n, int rank, double c) {
  if (guarantorRequired(n, rank)) return 'obligatoire';
  if (requiredGuarantee(n, rank, c) < maxLoss(n, rank, c)) return 'facultatif';
  return 'non requis';
}

// ---------------------------------------------------------------------------
// Formats
// ---------------------------------------------------------------------------

const _months = [
  'janvier', 'février', 'mars', 'avril', 'mai', 'juin',
  'juillet', 'août', 'septembre', 'octobre', 'novembre', 'décembre',
];

String monthName(DateTime d) => '${_months[d.month - 1]} ${d.year}';

String money(double v, String cur) {
  const symbols = {'USD': r'$', 'EUR': '€', 'CDF': 'FC', 'XAF': 'FCFA'};
  final sym = symbols[cur] ?? cur;
  final isInt = v == v.roundToDouble();
  final text = isInt ? v.round().toString() : v.toStringAsFixed(2);
  final parts = text.split('.');
  final digits = parts[0];
  final buf = StringBuffer();
  for (var i = 0; i < digits.length; i++) {
    if (i > 0 && (digits.length - i) % 3 == 0) buf.write(' ');
    buf.write(digits[i]);
  }
  final number = parts.length > 1 ? '$buf,${parts[1]}' : buf.toString();
  return '$number $sym';
}
