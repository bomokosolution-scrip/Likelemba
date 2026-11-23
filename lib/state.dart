import 'package:flutter/foundation.dart';

import 'models.dart';

/// État de l'application. Pour ce prototype, tout reste en mémoire :
/// rien n'est envoyé nulle part et tout est perdu à la fermeture.
class AppState extends ChangeNotifier {
  final String currentUser = 'Mama Grace';
  final List<Group> groups = [demoGroup()];

  bool isTreasurer(Group g) => g.members.any((m) =>
      m.name == currentUser && m.role.toLowerCase().contains('trésori'));

  void addGroup(Group g) {
    groups.insert(0, g);
    notifyListeners();
  }

  void declare(Group g, Member m, String reference) {
    m.status = PayStatus.declared;
    m.reference = reference;
    g.log.insert(
        0, LogEntry("À l'instant", '${m.name} a déclaré son paiement (réf. $reference)'));
    notifyListeners();
  }

  void confirm(Group g, Member m) {
    m.status = PayStatus.confirmed;
    g.log.insert(0, LogEntry("À l'instant", 'Paiement de ${m.name} confirmé par $currentUser'));
    notifyListeners();
  }

  void advanceRound(Group g) {
    final receiver = g.beneficiary;
    g.log.insert(0,
        LogEntry("À l'instant", '${receiver.name} a reçu la cagnotte de ${money(g.pot, g.currency)}'));
    if (g.currentRound < g.size) {
      g.currentRound++;
      for (final m in g.members) {
        m.status = PayStatus.pending;
        m.reference = null;
      }
    } else {
      g.log.insert(0, LogEntry("À l'instant", 'Cycle terminé : garanties et fonds de solidarité à rembourser'));
    }
    notifyListeners();
  }
}

final appState = AppState();

Group demoGroup() {
  return Group(
    name: 'Famille Mukendi',
    contribution: 50,
    currency: 'USD',
    frequency: 'Mensuelle',
    dueDay: 5,
    currentRound: 2,
    start: DateTime(2026, 10),
    members: [
      Member(name: 'Jeanne', city: 'Goma', rank: 1, status: PayStatus.confirmed, guarantor: 'Papa Jean', guaranteePaid: true),
      Member(name: 'Olivier', city: 'Kinshasa', rank: 2, role: 'Co-trésorier', status: PayStatus.confirmed, guarantor: 'Tante Rose', guaranteePaid: true),
      Member(name: 'Patrick', city: 'Lubumbashi', rank: 3, status: PayStatus.declared, reference: 'AM-83421', guarantor: 'Mama Grace', guaranteePaid: true),
      Member(name: 'Mama Grace', city: 'Kinshasa', rank: 4, role: 'Organisatrice et trésorière', guaranteePaid: true),
      Member(name: 'Daniel', city: 'Brazzaville', rank: 5, status: PayStatus.late, guaranteePaid: true),
      Member(name: 'Christelle', city: 'Paris', rank: 6, guaranteePaid: true),
    ],
    log: [
      LogEntry('Hier', 'Patrick a déclaré son paiement (réf. AM-83421)'),
      LogEntry('Il y a 3 jours', 'Paiement d\'Olivier confirmé par Mama Grace'),
      LogEntry('Il y a 4 jours', 'Rappel envoyé à Daniel : date limite dépassée'),
      LogEntry('Il y a 1 mois', 'Jeanne a reçu la cagnotte de 300 \$'),
      LogEntry('Il y a 1 mois', 'Groupe créé, ordre de passage fixé'),
    ],
  );
}
