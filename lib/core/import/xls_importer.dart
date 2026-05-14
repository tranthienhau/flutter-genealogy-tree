import 'dart:typed_data';

import 'package:csv/csv.dart';
import 'package:excel/excel.dart';

import 'csv_importer.dart';
import '../tree/relationship_graph.dart';

class XlsImporter {
  RelationshipGraph parse(Uint8List bytes, {CsvColumnMap? map, String? sheet}) {
    final wb = Excel.decodeBytes(bytes);
    final sheetName = sheet ?? wb.tables.keys.first;
    final table = wb.tables[sheetName];
    if (table == null) return RelationshipGraph();

    final rows = <List<String>>[];
    for (final row in table.rows) {
      rows.add(row.map((c) => c?.value?.toString() ?? '').toList());
    }
    final csvText = const ListToCsvConverter().convert(rows);
    return CsvImporter(map: map).parse(csvText);
  }
}
