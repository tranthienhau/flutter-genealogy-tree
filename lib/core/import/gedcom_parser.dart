import 'package:uuid/uuid.dart';

import '../tree/relationship_graph.dart';

class GedcomParser {
  final _uuid = const Uuid();

  RelationshipGraph parse(String text) {
    final lines = text.split(RegExp(r'\r?\n'));
    final records = <String, _Record>{};
    _Record? current;

    for (final raw in lines) {
      if (raw.isEmpty) continue;
      final parts = raw.split(' ');
      final level = int.tryParse(parts.first);
      if (level == null) continue;

      if (level == 0) {
        if (parts.length >= 3 && parts[1].startsWith('@')) {
          final id = parts[1];
          final type = parts[2];
          current = _Record(id: id, type: type);
          records[id] = current;
        } else {
          current = null;
        }
        continue;
      }
      if (current == null) continue;
      final tag = parts[1];
      final value = parts.length > 2 ? parts.sublist(2).join(' ') : '';
      current.fields.add(_Field(level: level, tag: tag, value: value));
    }

    final g = RelationshipGraph();
    final idMap = <String, String>{};

    for (final r in records.values.where((r) => r.type == 'INDI')) {
      final id = idMap.putIfAbsent(r.id, () => _uuid.v4());
      final nameField = r.fields.firstWhere(
        (f) => f.tag == 'NAME',
        orElse: () => const _Field(level: 1, tag: 'NAME', value: 'Unknown'),
      );
      final name = nameField.value.replaceAll('/', '').trim();
      g.upsert(Person(id: id, name: name.isEmpty ? 'Unknown' : name));
    }

    for (final r in records.values.where((r) => r.type == 'FAM')) {
      final husbField = r.fields.firstWhere(
        (f) => f.tag == 'HUSB',
        orElse: () => const _Field(level: 1, tag: 'HUSB', value: ''),
      );
      final wifeField = r.fields.firstWhere(
        (f) => f.tag == 'WIFE',
        orElse: () => const _Field(level: 1, tag: 'WIFE', value: ''),
      );
      final husb = idMap[husbField.value];
      final wife = idMap[wifeField.value];
      if (husb != null && wife != null) g.addSpouse(husb, wife);
      for (final f in r.fields.where((f) => f.tag == 'CHIL')) {
        final child = idMap[f.value];
        if (child == null) continue;
        if (husb != null) g.addParent(childId: child, parentId: husb);
        if (wife != null) g.addParent(childId: child, parentId: wife);
      }
    }
    return g;
  }
}

class _Record {
  _Record({required this.id, required this.type});
  final String id;
  final String type;
  final List<_Field> fields = [];
}

class _Field {
  const _Field({required this.level, required this.tag, required this.value});
  final int level;
  final String tag;
  final String value;
}
