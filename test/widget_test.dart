import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:myportofolio_mobile/main.dart';
import 'package:myportofolio_mobile/screens/project_form.dart';

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
    await tester.pump(const Duration(milliseconds: 50));
    await tester.tap(find.text('Logout'));
    await tester.pumpAndSettle();

    expect(find.text('Kamu telah menekan tombol Logout!'), findsOneWidget);
    expect(find.text('Kamu telah menekan tombol Lihat Proyek!'), findsNothing);
  });

  testWidgets('Kartu Tambah Proyek membuka form dan Back kembali ke Home', (
    tester,
  ) async {
    await tester.pumpWidget(const MyApp());
    await tester.tap(find.text('Tambah Proyek'));
    await tester.pumpAndSettle();

    expect(find.byType(ProjectFormPage), findsOneWidget);

    await tester.binding.handlePopRoute();
    await tester.pumpAndSettle();

    expect(find.text('MyPortfolio'), findsOneWidget);
    expect(find.byType(ProjectFormPage), findsNothing);
  });

  testWidgets('Drawer mengganti halaman antara Home dan Add Project', (
    tester,
  ) async {
    await tester.pumpWidget(const MyApp());
    await tester.tap(find.byType(DrawerButton));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Add Project'));
    await tester.pumpAndSettle();

    final projectForm = find.byType(ProjectFormPage);
    expect(projectForm, findsOneWidget);
    expect(Navigator.of(tester.element(projectForm)).canPop(), isFalse);

    await tester.tap(find.byType(DrawerButton));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Home'));
    await tester.pumpAndSettle();

    expect(find.text('MyPortfolio'), findsOneWidget);
    expect(projectForm, findsNothing);
  });

  testWidgets('Save memvalidasi dan menampilkan data, lalu OK mereset form', (
    tester,
  ) async {
    tester.view.devicePixelRatio = 1;
    tester.view.physicalSize = const Size(320, 568);
    addTearDown(tester.view.resetDevicePixelRatio);
    addTearDown(tester.view.resetPhysicalSize);

    await tester.pumpWidget(const MaterialApp(home: ProjectFormPage()));
    final save = find.widgetWithText(ElevatedButton, 'Save');
    await tester.ensureVisible(save);
    await tester.pumpAndSettle();
    await tester.tap(save);
    await tester.pumpAndSettle();

    expect(find.text('Nama proyek tidak boleh kosong!'), findsOneWidget);
    expect(find.text('Deskripsi proyek tidak boleh kosong!'), findsOneWidget);
    expect(find.byType(AlertDialog), findsNothing);

    Finder field(String label) => find.byWidgetPredicate(
      (widget) => widget is TextField && widget.decoration?.labelText == label,
    );
    const inputs = {
      'Nama Proyek': 'Portofolio Mobile',
      'Deskripsi Proyek': 'Aplikasi untuk menampilkan proyek.',
      'Teknologi yang Digunakan': 'Flutter dan Dart',
      'Tautan Proyek': 'https://example.com/proyek',
    };
    for (final entry in inputs.entries) {
      final input = field(entry.key);
      await tester.ensureVisible(input);
      await tester.enterText(input, entry.value);
    }

    final category = find.byType(DropdownButtonFormField<String>);
    final categoryButton = find.byType(DropdownButton<String>);
    await tester.ensureVisible(categoryButton);
    await tester.pumpAndSettle();
    await tester.tap(categoryButton);
    await tester.pumpAndSettle();
    await tester.tap(find.text('Mobile Development').last);
    await tester.pumpAndSettle();

    await tester.ensureVisible(save);
    await tester.pumpAndSettle();
    await tester.tap(save);
    await tester.pumpAndSettle();

    expect(find.text('Proyek berhasil ditambahkan!'), findsOneWidget);
    expect(find.text('Nama Proyek: Portofolio Mobile'), findsOneWidget);
    expect(
      find.text('Deskripsi: Aplikasi untuk menampilkan proyek.'),
      findsOneWidget,
    );
    expect(find.text('Kategori: Mobile Development'), findsOneWidget);
    expect(find.text('Teknologi: Flutter dan Dart'), findsOneWidget);
    expect(find.text('Tautan: https://example.com/proyek'), findsOneWidget);

    await tester.tap(find.text('OK'));
    await tester.pumpAndSettle();

    expect(find.byType(AlertDialog), findsNothing);
    for (final label in inputs.keys) {
      expect(tester.widget<TextField>(field(label)).controller!.text, isEmpty);
    }
    expect(
      tester.state<FormFieldState<String>>(category).value,
      'Web Development',
    );
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
