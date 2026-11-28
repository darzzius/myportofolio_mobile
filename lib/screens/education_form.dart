import 'package:material_ui/material_ui.dart';
import 'package:myportofolio_mobile/models/education.dart';
import 'package:myportofolio_mobile/screens/education_list_screen.dart';
import 'package:myportofolio_mobile/services/api_client.dart';
import 'package:myportofolio_mobile/services/auth_state.dart';
import 'package:myportofolio_mobile/widgets/auth_guard.dart';
import 'package:myportofolio_mobile/widgets/left_drawer.dart';
import 'package:provider/provider.dart';

class EducationFormPage extends StatefulWidget {
  const EducationFormPage({super.key, this.returnToList = false});

  final bool returnToList;

  @override
  State<EducationFormPage> createState() => _EducationFormPageState();
}

class _EducationFormPageState extends State<EducationFormPage> {
  static final _yearPattern = RegExp(r'^[0-9]{4}$');
  static const _fieldBorder = OutlineInputBorder();

  final _formKey = GlobalKey<FormState>();
  final _institution = TextEditingController();
  final _degree = TextEditingController();
  final _startYear = TextEditingController();
  final _endYear = TextEditingController();
  final _description = TextEditingController();
  bool _isOngoing = true;
  bool _isSubmitting = false;

  @override
  void dispose() {
    _institution.dispose();
    _degree.dispose();
    _startYear.dispose();
    _endYear.dispose();
    _description.dispose();
    super.dispose();
  }

  static String? _validateText(String? value, String label, {int? maxLength}) {
    final text = value?.trim() ?? '';
    if (text.isEmpty) return '$label wajib diisi.';
    if (maxLength != null && text.runes.length > maxLength) {
      return '$label maksimal $maxLength karakter.';
    }
    return null;
  }

  static int? _parseYear(String text) {
    if (!_yearPattern.hasMatch(text)) return null;
    final year = int.parse(text);
    return year > 0 ? year : null;
  }

  static String? _validateYear(String? value, String label, {int? earliest}) {
    final text = value?.trim() ?? '';
    if (text.isEmpty) return '$label wajib diisi.';
    final year = _parseYear(text);
    if (year == null) {
      return '$label harus berupa tahun 4 digit, misalnya 2026.';
    }
    if (earliest != null && year < earliest) {
      return 'Tahun selesai tidak boleh sebelum tahun mulai.';
    }
    return null;
  }

  Future<void> _submit() async {
    if (_isSubmitting || !_formKey.currentState!.validate()) return;
    final auth = context.read<AuthState>();
    final api = context.read<ApiClient>();
    final education = Education(
      institution: _institution.text.trim(),
      degree: _degree.text.trim(),
      startYear: _startYear.text.trim(),
      endYear: _isOngoing ? 'Present' : _endYear.text.trim(),
      description: _description.text.trim(),
    );
    setState(() => _isSubmitting = true);
    FocusManager.instance.primaryFocus?.unfocus();

    try {
      if (!await ensureLoggedIn(context) || !mounted) return;
      final token = auth.token;
      if (token == null) return;
      final saved = await api.createEducation(education, token: token);
      if (!mounted) return;
      await _confirmSaved(saved);
    } on ApiException catch (error) {
      if (!mounted) return;
      if (error.statusCode == 401) {
        auth.clearSession();
        await ensureLoggedIn(context, sessionExpired: true);
      } else {
        _showError(switch (error.statusCode) {
          400 => 'Server menolak isian pendidikan. Periksa kembali isianmu.',
          403 => 'Hanya pemilik portofolio yang bisa menambah pendidikan.',
          _ => 'Pendidikan gagal disimpan (HTTP ${error.statusCode}).',
        });
      }
    } on Exception {
      if (mounted) _showError('Pendidikan gagal disimpan. Periksa koneksi.');
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context)
      ..clearSnackBars()
      ..showSnackBar(SnackBar(content: Text(message)));
  }

  Future<void> _confirmSaved(Education saved) async {
    await showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) => AlertDialog(
        scrollable: true,
        title: const Text('Pendidikan berhasil disimpan'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Nama institusi: ${saved.institution}'),
            Text('Jurusan / jenjang: ${saved.degree}'),
            Text('Tahun mulai: ${saved.startYear}'),
            Text('Tahun selesai: ${saved.displayEndYear}'),
            Text('Deskripsi: ${saved.description}'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Lihat Daftar'),
          ),
        ],
      ),
    );
    if (!mounted) return;
    if (widget.returnToList) {
      Navigator.pop(context, true);
    } else {
      Navigator.pushReplacement<void, void>(
        context,
        MaterialPageRoute<void>(builder: (_) => const EducationListScreen()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return PopScope(
      canPop: !_isSubmitting,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Tambah Pendidikan'),
          backgroundColor: colors.primary,
          foregroundColor: colors.onPrimary,
        ),
        drawer: _isSubmitting || widget.returnToList
            ? null
            : const LeftDrawer(currentPage: DrawerPage.education),
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
                      TextFormField(
                        controller: _institution,
                        enabled: !_isSubmitting,
                        decoration: const InputDecoration(
                          labelText: 'Nama Institusi',
                          border: _fieldBorder,
                        ),
                        textInputAction: TextInputAction.next,
                        validator: (value) => _validateText(
                          value,
                          'Nama institusi',
                          maxLength: 255,
                        ),
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: _degree,
                        enabled: !_isSubmitting,
                        decoration: const InputDecoration(
                          labelText: 'Jurusan / Jenjang',
                          border: _fieldBorder,
                        ),
                        textInputAction: TextInputAction.next,
                        validator: (value) => _validateText(
                          value,
                          'Jurusan / jenjang',
                          maxLength: 255,
                        ),
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: _startYear,
                        enabled: !_isSubmitting,
                        decoration: const InputDecoration(
                          labelText: 'Tahun Mulai',
                          border: _fieldBorder,
                        ),
                        keyboardType: TextInputType.number,
                        textInputAction: TextInputAction.next,
                        validator: (value) =>
                            _validateYear(value, 'Tahun mulai'),
                      ),
                      SwitchListTile(
                        contentPadding: EdgeInsets.zero,
                        title: const Text('Masih menempuh pendidikan'),
                        value: _isOngoing,
                        onChanged: _isSubmitting
                            ? null
                            : (value) => setState(() => _isOngoing = value),
                      ),
                      if (!_isOngoing) ...[
                        TextFormField(
                          controller: _endYear,
                          enabled: !_isSubmitting,
                          decoration: const InputDecoration(
                            labelText: 'Tahun Selesai',
                            border: _fieldBorder,
                          ),
                          keyboardType: TextInputType.number,
                          textInputAction: TextInputAction.next,
                          validator: (value) => _validateYear(
                            value,
                            'Tahun selesai',
                            earliest: _parseYear(_startYear.text.trim()),
                          ),
                        ),
                        const SizedBox(height: 12),
                      ],
                      TextFormField(
                        controller: _description,
                        enabled: !_isSubmitting,
                        decoration: const InputDecoration(
                          labelText: 'Deskripsi',
                          alignLabelWithHint: true,
                          border: _fieldBorder,
                        ),
                        maxLines: 3,
                        validator: (value) => _validateText(value, 'Deskripsi'),
                      ),
                      const SizedBox(height: 16),
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
}
