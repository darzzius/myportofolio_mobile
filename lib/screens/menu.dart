import 'package:material_ui/material_ui.dart';
import 'package:myportofolio_mobile/screens/education_form.dart';
import 'package:myportofolio_mobile/screens/education_list_screen.dart';
import 'package:myportofolio_mobile/screens/project_form.dart';
import 'package:myportofolio_mobile/screens/project_list_screen.dart';
import 'package:myportofolio_mobile/services/auth_state.dart';
import 'package:myportofolio_mobile/widgets/left_drawer.dart';
import 'package:myportofolio_mobile/widgets/project_card.dart';
import 'package:provider/provider.dart';

class MyHomePage extends StatelessWidget {
  const MyHomePage({super.key});

  final String npm = '2506584275';
  final String nama = 'Rafael Darius Sagala';
  final String kelas = 'PBP A';

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final isLoggedIn = context.watch<AuthState>().isLoggedIn;
    final items = [
      const ItemHomepage(
        'Lihat Proyek',
        Icons.folder,
        Color(0xFF1565C0),
        destination: ProjectListScreen(),
      ),
      const ItemHomepage(
        'Tambah Proyek',
        Icons.add_circle,
        Color(0xFF2E7D32),
        destination: ProjectFormPage(),
        requiresLogin: true,
      ),
      const ItemHomepage(
        'Lihat Pendidikan',
        Icons.school_outlined,
        Color(0xFF283593),
        destination: EducationListScreen(),
      ),
      const ItemHomepage(
        'Tambah Pendidikan',
        Icons.school_outlined,
        Color(0xFF4527A0),
        destination: EducationFormPage(),
        requiresLogin: true,
      ),
      ItemHomepage(
        isLoggedIn ? 'Logout' : 'Login',
        isLoggedIn ? Icons.logout : Icons.login,
        isLoggedIn ? const Color(0xFFC62828) : colors.primary,
        isAuthAction: true,
      ),
    ];
    // Scaffold menyediakan struktur visual dasar halaman (AppBar, Body, SnackBar).
    return Scaffold(
      // AppBar menampilkan bar bagian atas halaman aplikasi.
      appBar: AppBar(
        title: const Text(
          'MyPortfolio',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: colors.primary,
        foregroundColor: colors.onPrimary,
      ),
      drawer: const LeftDrawer(),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 960),
              child: LayoutBuilder(
                builder: (context, constraints) {
                  final profileCards = [
                    InfoCard(title: 'NPM', content: npm),
                    InfoCard(title: 'Name', content: nama),
                    InfoCard(title: 'Class', content: kelas),
                  ];

                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // Susun vertikal di ponsel agar nama lengkap tetap terbaca.
                      if (constraints.maxWidth < 600)
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: profileCards,
                        )
                      else
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: profileCards
                              .map((card) => Expanded(child: card))
                              .toList(),
                        ),
                      const SizedBox(height: 32.0),
                      const Text(
                        'Selamat datang di MyPortfolio Mobile!',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 18.0,
                        ),
                      ),
                      const SizedBox(height: 20.0),
                      GridView.count(
                        // Gulir ditangani oleh SingleChildScrollView halaman.
                        primary: false,
                        physics: const NeverScrollableScrollPhysics(),
                        padding: EdgeInsets.zero,
                        crossAxisSpacing: 12,
                        mainAxisSpacing: 12,
                        crossAxisCount: constraints.maxWidth < 600 ? 2 : 5,
                        mainAxisExtent: 136,
                        shrinkWrap: true,
                        children: items.map((item) => ItemCard(item)).toList(),
                      ),
                    ],
                  );
                },
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class InfoCard extends StatelessWidget {
  // Kartu informasi yang menampilkan judul (title) dan isi (content).
  final String title;
  final String content;

  const InfoCard({super.key, required this.title, required this.content});

  @override
  Widget build(BuildContext context) {
    return Card(
      // Memberikan efek bayangan kartu elevasi 2 unit.
      elevation: 2.0,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        // Menyusun teks title dan content secara vertikal.
        child: Column(
          children: [
            Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8.0),
            Text(content, textAlign: TextAlign.center),
          ],
        ),
      ),
    );
  }
}

class ItemHomepage {
  final String name;
  final IconData icon;
  final Color color;
  final Widget? destination;
  final bool requiresLogin;
  final bool isAuthAction;

  const ItemHomepage(
    this.name,
    this.icon,
    this.color, {
    this.destination,
    this.requiresLogin = false,
    this.isAuthAction = false,
  });
}
