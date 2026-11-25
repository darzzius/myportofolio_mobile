import 'package:material_ui/material_ui.dart';
import 'package:myportofolio_mobile/models/project.dart';
import 'package:myportofolio_mobile/services/api_client.dart';
import 'package:myportofolio_mobile/services/auth_state.dart';
import 'package:myportofolio_mobile/widgets/auth_guard.dart';
import 'package:myportofolio_mobile/widgets/left_drawer.dart';
import 'package:provider/provider.dart';

class ProjectFormPage extends StatefulWidget {
  const ProjectFormPage({super.key});

  @override
  State<ProjectFormPage> createState() => _ProjectFormPageState();
}

class _ProjectFormPageState extends State<ProjectFormPage> {
  final _formKey = GlobalKey<FormState>();
  String _title = '';
  String _description = '';
  String _techStack = '';
  String _projectUrl = '';
  String _projectImageUrl = '';
  bool _isSubmitting = false;

  String? _required(String? value, String label, {int? limit}) {
    final text = (value ?? '').trim();
    if (text.isEmpty) return '$label wajib diisi.';
    if (limit != null && text.runes.length > limit) {
      return '$label maksimal $limit karakter.';
    }
    return null;
  }

  String? _validateUrl(String? value, int limit) {
    final text = (value ?? '').trim();
    if (text.isEmpty) return null;
    if (text.length > limit) return 'URL maksimal $limit karakter.';
    final uri = Uri.tryParse(text);
    if (uri == null ||
        (uri.scheme != 'https' && uri.scheme != 'http') ||
        uri.host.isEmpty ||
        RegExp(r'\s').hasMatch(text)) {
      return 'Masukkan URL lengkap yang diawali http:// atau https://.';
    }
    return null;
  }

  Future<void> _submit() async {
    final form = _formKey.currentState!;
    if (_isSubmitting || !form.validate()) return;

    final auth = context.read<AuthState>();
    final api = context.read<ApiClient>();
    final project = Project(
      title: _title.trim(),
      description: _description.trim(),
      techStack: _techStack.trim(),
      projectUrl: _projectUrl.trim(),
      projectImageUrl: _projectImageUrl.trim(),
    );
    setState(() => _isSubmitting = true);
    FocusScope.of(context).unfocus();

    try {
      if (!await ensureLoggedIn(context) || !mounted) return;
      final token = auth.token;
      if (token == null) return;

      final saved = await api.createProject(project, token: token);
      if (!mounted) return;
      form.reset();
      await showDialog<void>(
        context: context,
        builder: (dialogContext) => AlertDialog(
          title: const Text('Proyek berhasil ditambahkan!'),
          content: Text(saved.title),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text('OK'),
            ),
          ],
        ),
      );
    } on ApiException catch (error) {
      if (!mounted) return;
      switch (error.statusCode) {
        case 401:
          auth.clearSession();
          await ensureLoggedIn(context, sessionExpired: true);
        case 403:
          _showMessage('Hanya pemilik portofolio yang bisa menambah proyek.');
        case 400:
          _showMessage('Server menolak isian proyek. Periksa kembali isianmu.');
        default:
          _showMessage('Proyek gagal disimpan (HTTP ${error.statusCode}).');
      }
    } on Exception {
      if (mounted) _showMessage('Proyek gagal disimpan. Periksa koneksi.');
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context)
      ..clearSnackBars()
      ..showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: !_isSubmitting,
      child: Scaffold(
        appBar: AppBar(title: const Text('Tambah Proyek')),
        drawer: _isSubmitting
            ? null
            : const LeftDrawer(currentPage: DrawerPage.project),
        body: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 560),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      _field(
                        'Nama Proyek',
                        (value) => _title = value,
                        (value) => _required(value, 'Nama proyek', limit: 255),
                      ),
                      _field(
                        'Deskripsi Proyek',
                        (value) => _description = value,
                        (value) => _required(value, 'Deskripsi proyek'),
                        maxLines: 4,
                      ),
                      _field(
                        'Teknologi yang Digunakan',
                        (value) => _techStack = value,
                        (value) => _required(value, 'Teknologi', limit: 255),
                      ),
                      _field(
                        'Tautan Proyek (opsional)',
                        (value) => _projectUrl = value,
                        (value) => _validateUrl(value, 200),
                        keyboardType: TextInputType.url,
                      ),
                      _field(
                        'URL Gambar (opsional)',
                        (value) => _projectImageUrl = value,
                        (value) => _validateUrl(value, 500),
                        keyboardType: TextInputType.url,
                      ),
                      FilledButton(
                        onPressed: _isSubmitting ? null : _submit,
                        child: Text(_isSubmitting ? 'Menyimpan…' : 'Simpan'),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _field(
    String label,
    ValueChanged<String> onChanged,
    FormFieldValidator<String> validator, {
    int maxLines = 1,
    TextInputType? keyboardType,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: TextFormField(
        decoration: InputDecoration(
          labelText: label,
          border: const OutlineInputBorder(),
        ),
        enabled: !_isSubmitting,
        maxLines: maxLines,
        keyboardType: keyboardType,
        onChanged: onChanged,
        validator: validator,
      ),
    );
  }
}
