import 'package:flutter/material.dart';

import '../models.dart';
import '../state.dart';

class CreateGroupScreen extends StatefulWidget {
  const CreateGroupScreen({super.key});

  @override
  State<CreateGroupScreen> createState() => _CreateGroupScreenState();
}

class _CreateGroupScreenState extends State<CreateGroupScreen> {
  final _name = TextEditingController();
  final _amount = TextEditingController(text: '50');
  double _size = 6;
  String _currency = 'USD';
  String _frequency = 'Mensuelle';
  double _dueDay = 5;

  static const _currencies = ['USD', 'CDF', 'EUR', 'XAF'];
  static const _frequencies = ['Mensuelle', 'Quinzaine', 'Hebdomadaire'];

  @override
  void dispose() {
    _name.dispose();
    _amount.dispose();
    super.dispose();
  }

  double get _contribution =>
      double.tryParse(_amount.text.trim().replaceAll(',', '.')) ?? 0;

  void _create() {
    final c = _contribution;
    if (_name.text.trim().isEmpty || c <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Indiquez un nom et une cotisation.')),
      );
      return;
    }
    final n = _size.round();
    final now = DateTime.now();
    final members = <Member>[
      Member(
        name: appState.currentUser,
        city: '—',
        rank: 1,
        role: 'Organisatrice et trésorière',
        guaranteePaid: true,
      ),
      for (var i = 2; i <= n; i++)
        Member(name: 'Membre $i (à inviter)', city: '—', rank: i),
    ];
    appState.addGroup(
      Group(
        name: _name.text.trim(),
        contribution: c,
        currency: _currency,
        frequency: _frequency,
        dueDay: _dueDay.round(),
        currentRound: 1,
        start: DateTime(now.year, now.month + 1),
        members: members,
        log: [LogEntry("À l'instant", 'Groupe créé par ${appState.currentUser}')],
      ),
    );
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final n = _size.round();
    final c = _contribution;
    return Scaffold(
      appBar: AppBar(title: const Text('Créer un groupe')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          TextField(
            controller: _name,
            decoration: const InputDecoration(
              labelText: 'Nom du groupe',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 16),
          Text('Nombre de membres : $n', style: theme.textTheme.titleSmall),
          Slider(
            value: _size,
            min: 4,
            max: 12,
            divisions: 8,
            label: '$n',
            onChanged: (v) => setState(() => _size = v),
          ),
          TextField(
            controller: _amount,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            decoration: const InputDecoration(
              labelText: 'Cotisation par tour',
              border: OutlineInputBorder(),
            ),
            onChanged: (_) => setState(() {}),
          ),
          const SizedBox(height: 16),
          Text('Monnaie de référence', style: theme.textTheme.titleSmall),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            children: [
              for (final cur in _currencies)
                ChoiceChip(
                  label: Text(cur),
                  selected: _currency == cur,
                  onSelected: (_) => setState(() => _currency = cur),
                ),
            ],
          ),
          const SizedBox(height: 16),
          Text('Fréquence', style: theme.textTheme.titleSmall),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            children: [
              for (final f in _frequencies)
                ChoiceChip(
                  label: Text(f),
                  selected: _frequency == f,
                  onSelected: (_) => setState(() => _frequency = f),
                ),
            ],
          ),
          const SizedBox(height: 16),
          Text('Date limite de paiement : le ${_dueDay.round()}', style: theme.textTheme.titleSmall),
          Slider(
            value: _dueDay,
            min: 1,
            max: 28,
            divisions: 27,
            label: '${_dueDay.round()}',
            onChanged: (v) => setState(() => _dueDay = v),
          ),
          const SizedBox(height: 8),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Garanties calculées', style: theme.textTheme.titleMedium),
                  const SizedBox(height: 4),
                  Text('Cagnotte par tour : ${money(c * n, _currency)}'),
                  const SizedBox(height: 8),
                  for (var rank = 1; rank <= n; rank++)
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 2),
                      child: Text(
                        'Rang $rank : garantie ${money(requiredGuarantee(n, rank, c), _currency)}'
                        ' · garant ${guarantorNote(n, rank, c)}',
                      ),
                    ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          FilledButton(onPressed: _create, child: const Text('Créer le groupe')),
        ],
      ),
    );
  }
}
