import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:myportofolio_mobile/main.dart';
import 'package:myportofolio_mobile/screens/education_form.dart';

Finder _field(String label) => find.byWidgetPredicate(
  (widget) => widget is TextField && widget.decoration?.labelText == label,
);

Future<void> _enter(WidgetTester tester, String label, String value) async {
  final field = _field(label);
  await tester.ensureVisible(field);
  await tester.enterText(field, value);
  await tester.pumpAndSettle();
}

Future<void> _tap(WidgetTester tester, Finder finder) async {
  await tester.ensureVisible(finder);
  await tester.pumpAndSettle();
  await tester.tap(finder);
  await tester.pumpAndSettle();
}

void main() {
  testWidgets('Kartu pendidikan membuka form dan Back kembali ke Home', (
    tester,
  ) async {
    await tester.pumpWidget(const MyApp());
    await _tap(tester, find.text('Tambah Pendidikan'));
    expect(find.byType(EducationFormPage), findsOneWidget);

    await tester.binding.handlePopRoute();
    await tester.pumpAndSettle();
    expect(find.text('MyPortfolio'), findsOneWidget);
    expect(find.byType(EducationFormPage), findsNothing);
  });

  testWidgets('Drawer membuka form pendidikan dan Home kembali ke menu', (
    tester,
  ) async {
    await tester.pumpWidget(const MyApp());
    await _tap(tester, find.byType(DrawerButton));
    await _tap(tester, find.text('Add Education'));
    final educationForm = find.byType(EducationFormPage);
    expect(educationForm, findsOneWidget);
    expect(Navigator.of(tester.element(educationForm)).canPop(), isFalse);

    await _tap(tester, find.byType(DrawerButton));
    expect(find.text('Add Project'), findsOneWidget);
    await _tap(tester, find.text('Home'));
    expect(find.text('MyPortfolio'), findsOneWidget);
    expect(educationForm, findsNothing);
  });

  testWidgets('Simpan menolak spasi, teks terlalu panjang, dan tahun salah', (
    tester,
  ) async {
    await tester.pumpWidget(const MaterialApp(home: EducationFormPage()));
    await _enter(tester, 'Nama Institusi', '   ');
    await _enter(tester, 'Jurusan / Jenjang', 'a' * 256);
    await _enter(tester, 'Tahun Mulai', '20ab');
    await _tap(tester, find.byType(SwitchListTile));
    await _tap(tester, find.text('Simpan'));

    expect(find.byType(AlertDialog), findsNothing);
    expect(find.text('Nama institusi wajib diisi.'), findsOneWidget);
    expect(
      find.text('Jurusan / jenjang maksimal 255 karakter.'),
      findsOneWidget,
    );
    expect(
      find.text('Tahun mulai harus berupa tahun 4 digit, misalnya 2026.'),
      findsOneWidget,
    );
    expect(find.text('Tahun selesai wajib diisi.'), findsOneWidget);
    expect(find.text('Deskripsi wajib diisi.'), findsOneWidget);
  });

  testWidgets(
    'Simpan memeriksa urutan tahun dan merangkum isian di layar kecil',
    (tester) async {
      tester.view.devicePixelRatio = 1;
      tester.view.physicalSize = const Size(320, 568);
      addTearDown(tester.view.resetDevicePixelRatio);
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetViewInsets);

      await tester.pumpWidget(const MaterialApp(home: EducationFormPage()));
      await _enter(tester, 'Nama Institusi', 'Universitas Indonesia');
      await _enter(tester, 'Jurusan / Jenjang', 'S1 Ilmu Komputer');
      await _enter(tester, 'Tahun Mulai', '2024');
      await _tap(tester, find.byType(SwitchListTile));
      await _enter(tester, 'Tahun Selesai', '2023');
      await _enter(tester, 'Deskripsi', 'Mempelajari pengembangan aplikasi.');

      tester.view.viewInsets = const FakeViewPadding(bottom: 260);
      await tester.pumpAndSettle();
      await _tap(tester, find.text('Simpan'));
      expect(
        find.text('Tahun selesai tidak boleh sebelum tahun mulai.'),
        findsOneWidget,
      );
      expect(find.byType(AlertDialog), findsNothing);

      await _enter(tester, 'Tahun Selesai', '2028');
      await _tap(tester, find.text('Simpan'));
      expect(find.byType(AlertDialog), findsOneWidget);
      tester.view.resetViewInsets();
      await tester.pumpAndSettle();

      expect(
        find.text('Nama institusi: Universitas Indonesia'),
        findsOneWidget,
      );
      expect(find.text('Jurusan / jenjang: S1 Ilmu Komputer'), findsOneWidget);
      expect(find.text('Tahun mulai: 2024'), findsOneWidget);
      expect(find.text('Tahun selesai: 2028'), findsOneWidget);
      expect(
        find.text('Deskripsi: Mempelajari pengembangan aplikasi.'),
        findsOneWidget,
      );
      await _tap(tester, find.text('Tutup'));
      expect(find.byType(AlertDialog), findsNothing);
      expect(
        tester.widget<TextField>(_field('Tahun Selesai')).controller!.text,
        '2028',
      );

      await _tap(tester, find.byType(SwitchListTile));
      await _tap(tester, find.text('Simpan'));
      expect(find.text('Tahun selesai: Sekarang'), findsOneWidget);
    },
  );
}
