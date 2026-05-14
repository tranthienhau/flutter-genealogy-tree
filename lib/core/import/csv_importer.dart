import 'package:csv/csv.dart';
import 'package:uuid/uuid.dart';

import '../tree/relationship_graph.dart';

class CsvColumnMap {
  CsvColumnMap({
    required this.id,
    required this.name,
    this.birth,
    this.death,
    this.gender,
    this.parent1,
    this.parent2,
    this.spouse,
  });

  final int id;
  final int name;
  final int? birth;
  final int? death;
  final int? gender;
  final int? parent1;
  final int? parent2;
  final int? spouse;
}

class CsvImporter {
  CsvImporter({CsvColumnMap? map}) : map = map ?? const _DefaultMap();

  final CsvColumnMap map;
  final _uuid = const Uuid();

  RelationshipGraph parse(String csvText) {
    final rows = const CsvToListConverter(eol: '\n').convert(csvText);
    final g = RelationshipGraph();
    if (rows.isEmpty) return g;

    final idMap = <String, String>{};
    final dataRows = rows.skip(1).toList();

    for (final row in dataRows) {
      final extId = row[map.id]?.toString() ?? _uuid.v4();
      final internalId = idMap.putIfAbsent(extId, () => _uuid.v4());
      g.upsert(Person(
        id: internalId,
        name: row[map.name]?.toString() ?? 'Unknown',
        birth: _date(row, map.birth),
        death: _date(row, map.death),
        gender: row[map.gender ?? -1]?.toString(),
      ));
    }

    for (final row in dataRows) {
      final extId = row[map.id]?.toString() ?? '';
      final me = idMap[extId];
      if (me == null) continue;
      for (final col in [map.parent1, map.parent2]) {
        if (col == null) continue;
        final pid = row[col]?.toString();
        if (pid == null || pid.isEmpty) continue;
        final mapped = idMap[pid];
        if (mapped != null) g.addParent(childId: me, parentId: mapped);
      }
      final sp = map.spouse;
      if (sp != null) {
        final spId = row[sp]?.toString();
        if (spId != null && spId.isNotEmpty) {
          final mapped = idMap[spId];
          if (mapped != null) g.addSpouse(me, mapped);
        }
      }
    }
    return g;
  }

  DateTime? _date(List<dynamic> row, int? col) {
    if (col == null) return null;
    final v = row[col]?.toString();
    if (v == null || v.isEmpty) return null;
    return DateTime.tryParse(v);
  }
}

class _DefaultMap extends CsvColumnMap {
  const _DefaultMap()
      : super(
          id: 0,
          name: 1,
          birth: 2,
          death: 3,
          gender: 4,
          parent1: 5,
          parent2: 6,
          spouse: 7,
        );
}
