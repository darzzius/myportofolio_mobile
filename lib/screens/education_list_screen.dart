import 'package:material_ui/material_ui.dart';
import 'package:myportofolio_mobile/models/education.dart';
import 'package:myportofolio_mobile/screens/education_detail_screen.dart';
import 'package:myportofolio_mobile/screens/education_form.dart';
import 'package:myportofolio_mobile/services/api_client.dart';
import 'package:myportofolio_mobile/widgets/auth_guard.dart';
import 'package:myportofolio_mobile/widgets/left_drawer.dart';
import 'package:provider/provider.dart';

class EducationListScreen extends StatefulWidget {
  const EducationListScreen({super.key});

  @override
  State<EducationListScreen> createState() => _EducationListScreenState();
}

class _EducationListScreenState extends State<EducationListScreen> {
  late Future<List<Education>> _educations;

  @override
  void initState() {
    super.initState();
    _educations = context.read<ApiClient>().getEducations();
  }

  Future<void> _reload() async {
    final request = context.read<ApiClient>().getEducations();
    setState(() {
      _educations = request;
    });
    try {
      await request;
    } on Object {
      // The same future delivers the failure to FutureBuilder.
    }
  }

  Future<void> _addEducation() async {
    if (!await ensureLoggedIn(context) || !mounted) return;
    final saved = await Navigator.push<bool>(
      context,
      MaterialPageRoute<bool>(
        builder: (_) => const EducationFormPage(returnToList: true),
      ),
    );
    if (saved == true && mounted) await _reload();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Daftar Pendidikan'),
        actions: [
          IconButton(
            tooltip: 'Segarkan daftar',
            onPressed: _reload,
            icon: const Icon(Icons.refresh),
          ),
          IconButton(
            tooltip: 'Tambah Pendidikan',
            onPressed: _addEducation,
            icon: const Icon(Icons.add),
          ),
        ],
      ),
      drawer: const LeftDrawer(currentPage: DrawerPage.educationList),
      body: FutureBuilder<List<Education>>(
        future: _educations,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting &&
              !snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text(
                      'Daftar pendidikan gagal dimuat.',
                      textAlign: TextAlign.center,
                    ),
                    TextButton(
                      onPressed: _reload,
                      child: const Text('Coba lagi'),
                    ),
                  ],
                ),
              ),
            );
          }
          final entries = snapshot.data ?? const <Education>[];
          return RefreshIndicator(
            onRefresh: _reload,
            child: CustomScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              slivers: [
                if (entries.isEmpty)
                  const SliverFillRemaining(
                    hasScrollBody: false,
                    child: Center(child: Text('Belum ada riwayat pendidikan.')),
                  )
                else
                  SliverPadding(
                    padding: const EdgeInsets.all(12),
                    sliver: SliverList.builder(
                      itemCount: entries.length,
                      itemBuilder: (context, index) {
                        final education = entries[index];
                        return Card(
                          child: ListTile(
                            title: Text(education.institution),
                            subtitle: Text(
                              '${education.degree}\n${education.startYear} – ${education.displayEndYear}',
                            ),
                            trailing: const Icon(Icons.chevron_right),
                            onTap: () => Navigator.push<void>(
                              context,
                              MaterialPageRoute<void>(
                                builder: (_) =>
                                    EducationDetailScreen(education: education),
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
              ],
            ),
          );
        },
      ),
    );
  }
}
