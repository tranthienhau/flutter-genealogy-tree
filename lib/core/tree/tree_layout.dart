import 'dart:ui';

import 'relationship_graph.dart';

class TreeNode {
  TreeNode({required this.person, required this.offset});
  final Person person;
  Offset offset;
}

class TreeLayout {
  TreeLayout({this.nodeWidth = 160, this.nodeHeight = 80, this.gap = 24});

  final double nodeWidth;
  final double nodeHeight;
  final double gap;

  List<TreeNode> layout(RelationshipGraph g) {
    final byGen = <int, List<Person>>{};
    for (final p in g.people) {
      final gen = g.generationOf(p.id);
      byGen.putIfAbsent(gen, () => []).add(p);
    }

    final nodes = <TreeNode>[];
    final sorted = byGen.keys.toList()..sort();
    for (final gen in sorted) {
      final row = byGen[gen]!;
      for (var i = 0; i < row.length; i++) {
        nodes.add(TreeNode(
          person: row[i],
          offset: Offset(i * (nodeWidth + gap), gen * (nodeHeight + gap * 2)),
        ));
      }
    }
    return nodes;
  }
}
