import 'package:flutter/material.dart';

import 'models.dart';

/// Pastille de statut d'un paiement.
class StatusChip extends StatelessWidget {
  final PayStatus status;
  const StatusChip({super.key, required this.status});

  @override
  Widget build(BuildContext context) {
    late final String label;
    late final Color bg;
    late final Color fg;
    switch (status) {
      case PayStatus.confirmed:
        label = 'Confirmé';
        bg = const Color(0xFFD7F2E3);
        fg = const Color(0xFF0B6B3A);
      case PayStatus.declared:
        label = 'À confirmer';
        bg = const Color(0xFFFFF0CC);
        fg = const Color(0xFF8A5A00);
      case PayStatus.pending:
        label = 'En attente';
        bg = const Color(0xFFE6E8EE);
        fg = const Color(0xFF454B5C);
      case PayStatus.late:
        label = 'En retard';
        bg = const Color(0xFFFAD9D9);
        fg = const Color(0xFF9B1C1C);
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(12)),
      child: Text(
        label,
        style: TextStyle(color: fg, fontSize: 12, fontWeight: FontWeight.w600),
      ),
    );
  }
}
