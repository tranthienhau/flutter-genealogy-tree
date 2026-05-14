import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/tree/relationship_graph.dart';
import '../../core/tree/tree_layout.dart';

final graphProvider = StateProvider<RelationshipGraph>((_) {
  final g = RelationshipGraph();
  final grandpa = Person(id: 'gp', name: 'Henry Tran');
  final grandma = Person(id: 'gm', name: 'Mary Tran');
  final dad = Person(id: 'd', name: 'David Tran');
  final mum = Person(id: 'm', name: 'Lisa Tran');
  final me = Person(id: 'me', name: 'Hau Tran');
  final sis = Person(id: 'sis', name: 'Anna Tran');
  for (final p in [grandpa, grandma, dad, mum, me, sis]) {
    g.upsert(p);
  }
  g.addSpouse('gp', 'gm');
  g.addParent(childId: 'd', parentId: 'gp');
  g.addParent(childId: 'd', parentId: 'gm');
  g.addSpouse('d', 'm');
  g.addParent(childId: 'me', parentId: 'd');
  g.addParent(childId: 'me', parentId: 'm');
  g.addParent(childId: 'sis', parentId: 'd');
  g.addParent(childId: 'sis', parentId: 'm');
  return g;
});

class TreeScreen extends ConsumerWidget {
  const TreeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final graph = ref.watch(graphProvider);
    final layout = TreeLayout().layout(graph);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Family Tree'),
        actions: [
          IconButton(icon: const Icon(Icons.upload_file), onPressed: () {}),
          IconButton(icon: const Icon(Icons.share), onPressed: () {}),
        ],
      ),
      body: InteractiveViewer(
        boundaryMargin: const EdgeInsets.all(200),
        minScale: 0.5,
        maxScale: 4,
        child: SizedBox(
          width: 2000,
          height: 1200,
          child: Stack(
            children: [
              for (final n in layout)
                Positioned(
                  left: n.offset.dx + 200,
                  top: n.offset.dy + 100,
                  child: _PersonCard(person: n.person),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _PersonCard extends StatelessWidget {
  const _PersonCard({required this.person});
  final Person person;

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      child: SizedBox(
        width: 160,
        height: 80,
        child: Padding(
          padding: const EdgeInsets.all(8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(person.name, style: const TextStyle(fontWeight: FontWeight.bold)),
              const Spacer(),
              Text(
                [
                  if (person.birth != null) 'b. ${person.birth!.year}',
                  if (person.death != null) 'd. ${person.death!.year}',
                ].join(' - '),
                style: const TextStyle(fontSize: 12, color: Colors.grey),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
