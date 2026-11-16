import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:myportofolio_mobile/main.dart';

void main() {
  for (final label in ['Lihat Proyek', 'Tambah Proyek', 'Logout']) {
    testWidgets('$label menampilkan SnackBar sesuai tombol', (tester) async {
      await tester.pumpWidget(const MyApp());

      await tester.tap(find.text(label));
      await tester.pumpAndSettle();

      expect(
        find.widgetWithText(SnackBar, 'Kamu telah menekan tombol $label!'),
        findsOneWidget,
      );
    });
  }

  testWidgets('Ketukan cepat menampilkan pesan tombol terakhir', (
    tester,
  ) async {
    await tester.pumpWidget(const MyApp());

    await tester.tap(find.text('Lihat Proyek'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Tambah Proyek'));
    await tester.pump(const Duration(milliseconds: 50));
    await tester.tap(find.text('Logout'));
    await tester.pumpAndSettle();

    expect(find.text('Kamu telah menekan tombol Logout!'), findsOneWidget);
    expect(find.text('Kamu telah menekan tombol Lihat Proyek!'), findsNothing);
    expect(find.text('Kamu telah menekan tombol Tambah Proyek!'), findsNothing);
  });

  for (final size in [const Size(320, 568), const Size(640, 360)]) {
    testWidgets('Profil dan menu dapat diakses pada layar $size', (
      tester,
    ) async {
      tester.view.devicePixelRatio = 1;
      tester.view.physicalSize = size;
      addTearDown(tester.view.resetDevicePixelRatio);
      addTearDown(tester.view.resetPhysicalSize);

      await tester.pumpWidget(const MyApp());
      await tester.pumpAndSettle();

      expect(find.text('2506584275'), findsOneWidget);
      expect(find.text('Rafael Darius Sagala'), findsOneWidget);
      expect(find.text('PBP A'), findsOneWidget);
      expect(tester.takeException(), isNull);

      // Logout tetap bisa dijangkau ketika konten melebihi tinggi layar.
      await tester.ensureVisible(find.text('Logout'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Logout'));
      await tester.pumpAndSettle();

      expect(find.text('Kamu telah menekan tombol Logout!'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });
  }
}
