import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

import 'package:flutter_genealogy_tree/features/tree/tree_screen.dart';

void main() {
  final binding = IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  Future<void> shoot(WidgetTester tester, String name) async {
    await binding.convertFlutterSurfaceToImage();
    await tester.pumpAndSettle();
    await binding.takeScreenshot(name);
  }

  testWidgets('capture family tree flow', (tester) async {
    await tester.pumpWidget(
      const ProviderScope(
        child: MaterialApp(home: TreeScreen()),
      ),
    );
    await tester.pumpAndSettle();
    await shoot(tester, '01-family-tree');

    // Pan the interactive canvas to reveal lower generations.
    await tester.drag(find.byType(InteractiveViewer), const Offset(-120, -160));
    await tester.pumpAndSettle();
    await shoot(tester, '02-tree-panned');

    // Zoom-ish: drag to focus the descendants row.
    await tester.drag(find.byType(InteractiveViewer), const Offset(60, -80));
    await tester.pumpAndSettle();
    await shoot(tester, '03-descendants');
  });
}
