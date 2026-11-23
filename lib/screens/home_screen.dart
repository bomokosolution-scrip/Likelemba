import 'package:flutter/material.dart';

import '../models.dart';
import '../state.dart';
import 'create_group_screen.dart';
import 'group_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: appState,
      builder: (context, _) {
        return Scaffold(
          appBar: AppBar(title: const Text('Likelemba')),
          body: ListView(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 96),
            children: [
              Text('Mes groupes', style: Theme.of(context).textTheme.titleLarge),
              const SizedBox(height: 4),
              Text(
                'Prototype : les données sont fictives et restent sur ce téléphone.',
                style: Theme.of(context).textTheme.bodySmall,
              ),
              const SizedBox(height: 12),
              for (final g in appState.groups) _GroupCard(group: g),
            ],
          ),
          floatingActionButton: FloatingActionButton.extended(
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const CreateGroupScreen()),
            ),
            icon: const Icon(Icons.add),
            label: const Text('Créer un groupe'),
          ),
        );
      },
    );
  }
}

class _GroupCard extends StatelessWidget {
  final Group group;
  const _GroupCard({required this.group});

  @override
  Widget build(BuildContext context) {
    final g = group;
    return Card(
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => GroupScreen(group: g)),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(g.name, style: Theme.of(context).textTheme.titleMedium),
              const SizedBox(height: 4),
              Text('${g.size} membres · ${money(g.contribution, g.currency)} · ${g.frequency.toLowerCase()}'),
              const SizedBox(height: 12),
              Text('Tour ${g.currentRound} sur ${g.size} : ${g.beneficiary.name} reçoit ${money(g.pot, g.currency)}'),
              const SizedBox(height: 8),
              LinearProgressIndicator(value: g.confirmedCount / g.size),
              const SizedBox(height: 4),
              Text(
                '${g.confirmedCount} sur ${g.size} paiements confirmés',
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
