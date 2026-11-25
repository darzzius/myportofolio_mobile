import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:material_ui/material_ui.dart';
import 'package:myportofolio_mobile/main.dart';
import 'package:myportofolio_mobile/screens/login_screen.dart';
import 'package:myportofolio_mobile/screens/project_form.dart';
import 'package:myportofolio_mobile/services/api_client.dart';

const _projectJson = {
  'id': '8116639d-cf3e-4eba-b47c-4e942a595ef4',
  'title': 'Portofolio Mobile',
  'description': 'Menampilkan proyek, edukasi, dan pengalaman.',
  'tech_stack': 'Flutter dan Django',
  'project_url': 'https://example.com/proyek',
};

http.Response _json(Object value, {int status = 200}) => http.Response(
  jsonEncode(value),
  status,
  headers: {'content-type': 'application/json; charset=utf-8'},
);

Future<void> _start(
  WidgetTester tester,
  Future<http.Response> Function(http.Request) respond,
) async {
  final api = ApiClient(
    baseUrl: 'https://example.com',
    client: MockClient(respond),
  );
  addTearDown(api.close);
  await tester.pumpWidget(MyApp(apiClient: api));
  await tester.pumpAndSettle();
}

Future<void> _tap(WidgetTester tester, Finder target) async {
  await tester.ensureVisible(target);
  await tester.pumpAndSettle();
  await tester.tap(target);
  await tester.pumpAndSettle();
}

Finder _field(String label) => find.byWidgetPredicate(
  (widget) => widget is TextField && widget.decoration?.labelText == label,
);

Future<void> _enter(WidgetTester tester, String label, String value) async {
  final input = _field(label);
  await tester.ensureVisible(input);
  await tester.enterText(input, value);
  await tester.pumpAndSettle();
}

Future<void> _login(WidgetTester tester) async {
  await _enter(tester, 'Username', 'owner');
  await _enter(tester, 'Password', 'test-password');
  await _tap(tester, find.widgetWithText(FilledButton, 'Login'));
}

void main() {
  testWidgets('Guests can open project list and view project details', (
    tester,
  ) async {
    var fetches = 0;
    await _start(tester, (request) async {
      expect(request.method, 'GET');
      expect(request.url.path, '/api/v1/projects/');
      expect(request.headers['authorization'], isNull);
      fetches++;
      return _json([_projectJson]);
    });

    await _tap(tester, find.text('Lihat Proyek'));
    expect(find.text('Portofolio Mobile'), findsOneWidget);
    expect(find.byType(LoginScreen), findsNothing);

    await _tap(tester, find.text('Portofolio Mobile'));
    expect(find.text('Teknologi: Flutter dan Django'), findsOneWidget);
    expect(find.text('https://example.com/proyek'), findsOneWidget);
    expect(find.byType(Image), findsNothing);
    expect(fetches, 1);
  });

  testWidgets('Project list can retry after a failure and show empty results', (
    tester,
  ) async {
    var fetches = 0;
    await _start(tester, (_) async {
      fetches++;
      return fetches == 1 ? _json({}, status: 503) : _json([]);
    });
    await _tap(tester, find.text('Lihat Proyek'));
    expect(find.text('Coba lagi'), findsOneWidget);
    await _tap(tester, find.text('Coba lagi'));
    expect(find.text('Belum ada proyek.'), findsOneWidget);
    expect(find.byType(RefreshIndicator), findsOneWidget);
    expect(fetches, 2);
  });

  testWidgets('The drawer requires login and supports cancelling and logout', (
    tester,
  ) async {
    final paths = <String>[];
    await _start(tester, (request) async {
      paths.add(request.url.path);
      switch (request.url.path) {
        case '/api/v1/auth/token/':
          expect(jsonDecode(request.body), {
            'username': 'owner',
            'password': 'test-password',
          });
          return _json({'token': 'owner-token'});
        case '/api/v1/auth/logout/':
          expect(request.headers['authorization'], 'Token owner-token');
          return http.Response('', 204);
        default:
          fail('Unexpected request: ${request.url}');
      }
    });

    await _tap(tester, find.text('Tambah Proyek'));
    expect(find.byType(LoginScreen), findsOneWidget);
    await tester.pageBack();
    await tester.pumpAndSettle();
    expect(find.byType(ProjectFormPage), findsNothing);
    expect(paths, isEmpty);

    await _tap(tester, find.byType(DrawerButton));
    await _tap(tester, find.text('Add Project'));
    expect(find.byType(LoginScreen), findsOneWidget);
    await _login(tester);
    expect(find.byType(ProjectFormPage), findsOneWidget);

    await _tap(tester, find.byType(DrawerButton));
    await _tap(tester, find.text('Logout'));
    expect(paths, ['/api/v1/auth/token/', '/api/v1/auth/logout/']);
    expect(find.text('Kamu sudah logout.'), findsOneWidget);

    await _tap(tester, find.byType(DrawerButton));
    await _tap(tester, find.text('Add Project'));
    expect(find.byType(LoginScreen), findsOneWidget);
  });

  testWidgets('Project form validates, reauthenticates on 401, and saves', (
    tester,
  ) async {
    tester.view.devicePixelRatio = 1;
    tester.view.physicalSize = const Size(320, 568);
    addTearDown(tester.view.resetDevicePixelRatio);
    addTearDown(tester.view.resetPhysicalSize);

    var logins = 0;
    var submissions = 0;
    await _start(tester, (request) async {
      if (request.url.path == '/api/v1/auth/token/') {
        return _json({'token': 'owner-token-${++logins}'});
      }
      expect(request.method, 'POST');
      expect(request.url.path, '/api/v1/projects/');
      expect(request.headers['authorization'], 'Token owner-token-$logins');
      expect(jsonDecode(request.body), {
        'title': 'Portofolio Mobile',
        'description': 'Menampilkan proyek, edukasi, dan pengalaman.',
        'tech_stack': 'Flutter dan Django',
        'project_url': 'https://example.com/proyek',
        'project_image_url': '',
      });
      submissions++;
      return submissions == 1
          ? _json({'detail': 'Invalid token.'}, status: 401)
          : _json(_projectJson, status: 201);
    });

    await _tap(tester, find.text('Tambah Proyek'));
    await _login(tester);
    final save = find.widgetWithText(FilledButton, 'Simpan');
    await _tap(tester, save);
    expect(find.text('Nama proyek wajib diisi.'), findsOneWidget);
    expect(find.text('Teknologi wajib diisi.'), findsOneWidget);

    await _enter(tester, 'Nama Proyek', 'Portofolio Mobile');
    await _enter(
      tester,
      'Deskripsi Proyek',
      'Menampilkan proyek, edukasi, dan pengalaman.',
    );
    await _enter(tester, 'Teknologi yang Digunakan', 'Flutter dan Django');
    await _enter(tester, 'Tautan Proyek (opsional)', 'bukan URL');
    await _tap(tester, save);
    expect(
      find.text('Masukkan URL lengkap yang diawali http:// atau https://.'),
      findsOneWidget,
    );
    expect(submissions, 0);

    await _enter(
      tester,
      'Tautan Proyek (opsional)',
      'https://example.com/proyek',
    );
    await _tap(tester, save);
    expect(submissions, 1);
    expect(find.byType(LoginScreen), findsOneWidget);
    expect(find.text('Sesi berakhir. Silakan login kembali.'), findsOneWidget);

    await _login(tester);
    expect(find.byType(ProjectFormPage), findsOneWidget);
    await _tap(tester, save);
    expect(submissions, 2);
    expect(find.text('Proyek berhasil ditambahkan!'), findsOneWidget);
    await _tap(tester, find.text('OK'));
    expect(
      tester.widget<TextField>(_field('Nama Proyek')).controller!.text,
      '',
    );
  });

  for (final size in [const Size(320, 568), const Size(640, 360)]) {
    testWidgets('Profile and actions are reachable on a $size screen', (
      tester,
    ) async {
      tester.view.devicePixelRatio = 1;
      tester.view.physicalSize = size;
      addTearDown(tester.view.resetDevicePixelRatio);
      addTearDown(tester.view.resetPhysicalSize);
      await _start(tester, (_) async => fail('Home should not fetch the API'));

      expect(find.text('Rafael Darius Sagala'), findsOneWidget);
      await _tap(tester, find.text('Login'));
      expect(find.byType(LoginScreen), findsOneWidget);
      expect(tester.takeException(), isNull);
    });
  }
}
