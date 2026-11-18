import 'package:material_ui/material_ui.dart';
import 'package:myportofolio_mobile/widgets/left_drawer.dart';

class ProjectFormPage extends StatefulWidget {
  const ProjectFormPage({super.key});

  @override
  State<ProjectFormPage> createState() => _ProjectFormPageState();
}

class _ProjectFormPageState extends State<ProjectFormPage> {
  static const _defaultCategory = 'Web Development';
  static const _categories = [
    _defaultCategory,
    'Mobile Development',
    'Machine Learning',
    'Data Science',
    'Other',
  ];
  static const _fieldBorder = OutlineInputBorder(
    borderRadius: BorderRadius.all(Radius.circular(5.0)),
  );

  final _formKey = GlobalKey<FormState>();
  String _projectName = '';
  String _description = '';
  String _category = _defaultCategory;
  String _technologies = '';
  String _projectLink = '';

  void _showProject() {
    final form = _formKey.currentState!;
    if (!form.validate()) return;

    showDialog<void>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Proyek berhasil ditambahkan!'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Nama Proyek: $_projectName'),
              Text('Deskripsi: $_description'),
              Text('Kategori: $_category'),
              Text('Teknologi: $_technologies'),
              Text('Tautan: $_projectLink'),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(dialogContext);
              form.reset();
            },
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add Project Form'),
        centerTitle: true,
        backgroundColor: Colors.indigo,
        foregroundColor: Colors.white,
      ),
      drawer: const LeftDrawer(isProjectForm: true),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: TextFormField(
                  decoration: const InputDecoration(
                    hintText: 'Nama Proyek',
                    labelText: 'Nama Proyek',
                    border: _fieldBorder,
                  ),
                  onChanged: (value) => _projectName = value,
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Nama proyek tidak boleh kosong!';
                    }
                    return null;
                  },
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: TextFormField(
                  maxLines: 5,
                  decoration: const InputDecoration(
                    hintText: 'Deskripsi Proyek',
                    labelText: 'Deskripsi Proyek',
                    border: _fieldBorder,
                  ),
                  onChanged: (value) => _description = value,
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Deskripsi proyek tidak boleh kosong!';
                    }
                    return null;
                  },
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: DropdownButtonFormField<String>(
                  decoration: const InputDecoration(
                    labelText: 'Kategori Proyek',
                    border: _fieldBorder,
                  ),
                  initialValue: _defaultCategory,
                  isExpanded: true,
                  items: _categories
                      .map(
                        (category) => DropdownMenuItem<String>(
                          value: category,
                          child: Text(category),
                        ),
                      )
                      .toList(),
                  onChanged: (value) => _category = value ?? _defaultCategory,
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: TextFormField(
                  decoration: const InputDecoration(
                    hintText: 'Contoh: Flutter, Django, Figma',
                    labelText: 'Teknologi yang Digunakan',
                    border: _fieldBorder,
                  ),
                  onChanged: (value) => _technologies = value,
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: TextFormField(
                  decoration: const InputDecoration(
                    hintText: 'URL Proyek (opsional)',
                    labelText: 'Tautan Proyek',
                    border: _fieldBorder,
                  ),
                  keyboardType: TextInputType.url,
                  onChanged: (value) => _projectLink = value,
                ),
              ),
              Align(
                alignment: Alignment.bottomCenter,
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.indigo,
                      foregroundColor: Colors.white,
                    ),
                    onPressed: _showProject,
                    child: const Text('Save'),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
