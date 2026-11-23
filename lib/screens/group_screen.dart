import 'package:flutter/material.dart';

import '../models.dart';
import '../state.dart';
import '../widgets.dart';

class GroupScreen extends StatelessWidget {
  final Group group;
  const GroupScreen({super.key, required this.group});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 4,
      child: Scaffold(
        appBar: AppBar(
          title: Text(group.name),
          bottom: const TabBar(
            isScrollable: true,
            tabs: [
              Tab(text: 'Tour en cours'),
              Tab(text: 'Calendrier'),
              Tab(text: 'Garanties'),
              Tab(text: 'Historique'),
            ],
          ),
        ),
        body: ListenableBuilder(
          listenable: appState,
          builder: (context, _) => TabBarView(
            children: [
              _RoundTab(group: group),
              _CalendarTab(group: group),
              _GuaranteeTab(group: group),
              _HistoryTab(group: group),
            ],
          ),
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Tour en cours
// ---------------------------------------------------------------------------

class _RoundTab extends StatelessWidget {
  final Group group;
  const _RoundTab({required this.group});

  @override
  Widget build(BuildContext context) {
    final g = group;
    final theme = Theme.of(context);
    final allConfirmed = g.confirmedCount == g.size;
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Tour ${g.currentRound} sur ${g.size} · ${g.roundLabel(g.currentRound)}',
                  style: theme.textTheme.labelLarge,
                ),
                const SizedBox(height: 8),
                Text(
                  '${g.beneficiary.name} reçoit ${money(g.pot, g.currency)}',
                  style: theme.textTheme.titleLarge,
                ),
                const SizedBox(height: 4),
                Text('Date limite : le ${g.dueDay} · ${g.size} cotisations de ${money(g.contribution, g.currency)}'),
                const SizedBox(height: 12),
                LinearProgressIndicator(value: g.confirmedCount / g.size),
                const SizedBox(height: 6),
                Text('${g.confirmedCount} sur ${g.size} paiements confirmés'),
              ],
            ),
          ),
        ),
        if (allConfirmed)
          Card(
            color: theme.colorScheme.primaryContainer,
            child: ListTile(
              leading: const Icon(Icons.celebration),
              title: const Text('Cagnotte prête'),
              subtitle: Text('À remettre à ${g.beneficiary.name}'),
              trailing: FilledButton(
                onPressed: () => appState.advanceRound(g),
                child: const Text('Remise faite'),
              ),
            ),
          ),
        const SizedBox(height: 4),
        for (final m in g.members) _MemberPaymentCard(group: g, member: m),
      ],
    );
  }
}

class _MemberPaymentCard extends StatelessWidget {
  final Group group;
  final Member member;
  const _MemberPaymentCard({required this.group, required this.member});

  @override
  Widget build(BuildContext context) {
    final m = member;
    final g = group;
    final theme = Theme.of(context);
    final isMe = m.name == appState.currentUser;
    final isBeneficiary = m.rank == g.currentRound;

    Widget? action;
    if (isMe && (m.status == PayStatus.pending || m.status == PayStatus.late)) {
      action = FilledButton(
        onPressed: () => showModalBottomSheet<void>(
          context: context,
          isScrollControlled: true,
          builder: (_) => _DeclareSheet(group: g, member: m),
        ),
        child: const Text("J'ai payé"),
      );
    } else if (!isMe && m.status == PayStatus.declared && appState.isTreasurer(g)) {
      action = OutlinedButton(
        onPressed: () => appState.confirm(g, m),
        child: const Text('Confirmer la réception'),
      );
    }

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(radius: 16, child: Text('${m.rank}')),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        isBeneficiary ? '${m.name} · bénéficiaire' : m.name,
                        style: theme.textTheme.titleSmall,
                      ),
                      Text('${m.city} · ${m.role}', style: theme.textTheme.bodySmall),
                      if (m.reference != null)
                        Text('Réf. ${m.reference}', style: theme.textTheme.bodySmall),
                    ],
                  ),
                ),
                StatusChip(status: m.status),
              ],
            ),
            if (action != null)
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Align(alignment: Alignment.centerRight, child: action),
              ),
          ],
        ),
      ),
    );
  }
}

class _DeclareSheet extends StatefulWidget {
  final Group group;
  final Member member;
  const _DeclareSheet({required this.group, required this.member});

  @override
  State<_DeclareSheet> createState() => _DeclareSheetState();
}

class _DeclareSheetState extends State<_DeclareSheet> {
  final _ref = TextEditingController();

  @override
  void dispose() {
    _ref.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final g = widget.group;
    return Padding(
      padding: EdgeInsets.fromLTRB(16, 16, 16, 16 + MediaQuery.of(context).viewInsets.bottom),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Déclarer mon paiement', style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 8),
          Text(
            'Payez ${money(g.contribution, g.currency)} par Mobile Money, banque ou en espèces, '
            "puis indiquez ici la référence de la transaction. Le trésorier confirmera la réception.",
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _ref,
            decoration: const InputDecoration(
              labelText: 'Référence de la transaction',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: FilledButton(
              onPressed: () {
                final ref = _ref.text.trim();
                appState.declare(g, widget.member, ref.isEmpty ? 'sans référence' : ref);
                Navigator.pop(context);
              },
              child: const Text("J'ai payé"),
            ),
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Calendrier
// ---------------------------------------------------------------------------

class _CalendarTab extends StatelessWidget {
  final Group group;
  const _CalendarTab({required this.group});

  @override
  Widget build(BuildContext context) {
    final g = group;
    final sorted = [...g.members]..sort((a, b) => a.rank.compareTo(b.rank));
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        for (final m in sorted)
          Card(
            child: ListTile(
              leading: CircleAvatar(child: Text('${m.rank}')),
              title: Text(m.name),
              subtitle: Text('${g.roundLabel(m.rank)} · ${m.city}'),
              trailing: m.rank < g.currentRound
                  ? const Icon(Icons.check_circle, color: Color(0xFF0B6B3A))
                  : m.rank == g.currentRound
                      ? const Text('En cours')
                      : null,
            ),
          ),
      ],
    );
  }
}

// ---------------------------------------------------------------------------
// Garanties
// ---------------------------------------------------------------------------

class _GuaranteeTab extends StatelessWidget {
  final Group group;
  const _GuaranteeTab({required this.group});

  @override
  Widget build(BuildContext context) {
    final g = group;
    final theme = Theme.of(context);
    final n = g.size;
    final c = g.contribution;
    final sorted = [...g.members]..sort((a, b) => a.rank.compareTo(b.rank));
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Comment ça protège le groupe', style: theme.textTheme.titleMedium),
                const SizedBox(height: 8),
                const Text(
                  'La garantie est égale à la moitié de la perte possible de chaque rang, '
                  "avec un minimum d'une cotisation. Elle est rendue en fin de cycle si tout est payé.",
                ),
                const SizedBox(height: 8),
                Text(
                  'Fonds de solidarité : 2 % de chaque cotisation, soit ${money(c * 0.02, g.currency)} par membre et par tour.',
                ),
              ],
            ),
          ),
        ),
        for (final m in sorted)
          Card(
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      CircleAvatar(radius: 14, child: Text('${m.rank}')),
                      const SizedBox(width: 10),
                      Expanded(child: Text(m.name, style: theme.textTheme.titleSmall)),
                      Text(m.guaranteePaid ? 'Garantie versée' : 'Garantie à verser'),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text('Perte maximale : ${money(maxLoss(n, m.rank, c), g.currency)}'),
                  Text('Garantie en espèces : ${money(requiredGuarantee(n, m.rank, c), g.currency)}'),
                  Text(_guarantorLine(n, m, c, g.currency)),
                ],
              ),
            ),
          ),
      ],
    );
  }

  String _guarantorLine(int n, Member m, double c, String cur) {
    if (guarantorRequired(n, m.rank)) {
      final share = money(guarantorShare(n, m.rank, c), cur);
      return m.guarantor != null
          ? 'Garant : ${m.guarantor} s\'engage pour $share'
          : 'Garant à désigner : $share';
    }
    return 'Garant : ${guarantorNote(n, m.rank, c)}';
  }
}

// ---------------------------------------------------------------------------
// Historique
// ---------------------------------------------------------------------------

class _HistoryTab extends StatelessWidget {
  final Group group;
  const _HistoryTab({required this.group});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        for (final e in group.log)
          Card(
            child: ListTile(
              leading: const Icon(Icons.history),
              title: Text(e.text),
              subtitle: Text(e.when),
            ),
          ),
      ],
    );
  }
}
