import 'package:material_ui/material_ui.dart';
import 'package:myportofolio_mobile/widgets/left_drawer.dart';

class EducationFormPage extends StatefulWidget {
  const EducationFormPage({super.key});

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

  void _showSummary() {
    if (!_formKey.currentState!.validate()) return;
    FocusManager.instance.primaryFocus?.unfocus();

    final endYear = _isOngoing ? 'Sekarang' : _endYear.text.trim();
    showDialog<void>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        scrollable: true,
        title: const Text('Ringkasan Pendidikan'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Nama institusi: ${_institution.text.trim()}'),
            Text('Jurusan / jenjang: ${_degree.text.trim()}'),
            Text('Tahun mulai: ${_startYear.text.trim()}'),
            Text('Tahun selesai: $endYear'),
            Text('Deskripsi: ${_description.text.trim()}'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Tutup'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Tambah Pendidikan'),
        backgroundColor: colors.primary,
        foregroundColor: colors.onPrimary,
      ),
      drawer: const LeftDrawer(currentPage: DrawerPage.education),
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
                      decoration: const InputDecoration(
                        labelText: 'Tahun Mulai',
                        border: _fieldBorder,
                      ),
                      keyboardType: TextInputType.number,
                      textInputAction: TextInputAction.next,
                      validator: (value) => _validateYear(value, 'Tahun mulai'),
                    ),
                    SwitchListTile(
                      contentPadding: EdgeInsets.zero,
                      title: const Text('Masih menempuh pendidikan'),
                      value: _isOngoing,
                      onChanged: (value) => setState(() => _isOngoing = value),
                    ),
                    if (!_isOngoing) ...[
                      TextFormField(
                        controller: _endYear,
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
                      onPressed: _showSummary,
                      child: const Text('Simpan'),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
