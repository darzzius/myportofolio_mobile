import 'package:material_ui/material_ui.dart';
import 'package:myportofolio_mobile/models/education.dart';

class EducationDetailScreen extends StatelessWidget {
  const EducationDetailScreen({super.key, required this.education});

  final Education education;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context).textTheme;
    return Scaffold(
      appBar: AppBar(title: const Text('Detail Pendidikan')),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Text(education.institution, style: theme.headlineSmall),
            Text(education.degree, style: theme.titleMedium),
            const SizedBox(height: 16),
            Text('Tahun mulai: ${education.startYear}'),
            Text('Tahun selesai: ${education.displayEndYear}'),
            const SizedBox(height: 16),
            Text(education.description),
            const SizedBox(height: 16),
            Text('Bintang: ${education.starCount}'),
            Text(
              'Ditandai oleh sesi ini: ${education.isStarred ? 'Ya' : 'Tidak'}',
            ),
            Text(
              education.starredByNames.isEmpty
                  ? 'Pemberi bintang: —'
                  : 'Pemberi bintang: ${education.starredByNames}',
            ),
            if (education.id case final id?) SelectableText('ID: $id'),
          ],
        ),
      ),
    );
  }
}
