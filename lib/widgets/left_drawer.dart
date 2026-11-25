import 'package:material_ui/material_ui.dart';
import 'package:myportofolio_mobile/screens/education_form.dart';
import 'package:myportofolio_mobile/screens/menu.dart';
import 'package:myportofolio_mobile/screens/project_form.dart';
import 'package:myportofolio_mobile/screens/project_list_screen.dart';
import 'package:myportofolio_mobile/services/auth_state.dart';
import 'package:myportofolio_mobile/widgets/auth_guard.dart';
import 'package:provider/provider.dart';

enum DrawerPage { home, projectList, project, education }

class LeftDrawer extends StatelessWidget {
  const LeftDrawer({super.key, this.currentPage = DrawerPage.home});

  final DrawerPage currentPage;

  Future<void> _navigate(BuildContext context, DrawerPage destination) async {
    final pageContext = Scaffold.of(context).context;
    final navigator = Navigator.of(pageContext);
    navigator.pop();
    if (destination == DrawerPage.project) {
      final loggedIn = await ensureLoggedIn(pageContext);
      if (!loggedIn || !pageContext.mounted) return;
    }
    if (currentPage == destination) return;

    if (destination == DrawerPage.home && navigator.canPop()) {
      navigator.pop();
      return;
    }

    navigator.pushReplacement(
      MaterialPageRoute<void>(
        builder: (context) => switch (destination) {
          DrawerPage.home => const MyHomePage(),
          DrawerPage.projectList => const ProjectListScreen(),
          DrawerPage.project => const ProjectFormPage(),
          DrawerPage.education => const EducationFormPage(),
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isLoggedIn = context.watch<AuthState>().isLoggedIn;
    return Drawer(
      child: ListView(
        children: [
          const DrawerHeader(
            decoration: BoxDecoration(color: Colors.indigo),
            child: SingleChildScrollView(
              primary: false,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'My Portfolio',
                    style: TextStyle(
                      fontSize: 30,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  SizedBox(height: 10),
                  Text(
                    'Explore personal projects and experiences!',
                    style: TextStyle(fontSize: 15, color: Colors.white),
                  ),
                ],
              ),
            ),
          ),
          ListTile(
            leading: const Icon(Icons.home_outlined),
            title: const Text('Home'),
            onTap: () => _navigate(context, DrawerPage.home),
          ),
          ListTile(
            leading: const Icon(Icons.folder_outlined),
            title: const Text('View Projects'),
            onTap: () => _navigate(context, DrawerPage.projectList),
          ),
          ListTile(
            leading: const Icon(Icons.add_circle_outline),
            title: const Text('Add Project'),
            onTap: () => _navigate(context, DrawerPage.project),
          ),
          ListTile(
            leading: const Icon(Icons.school_outlined),
            title: const Text('Add Education'),
            onTap: () => _navigate(context, DrawerPage.education),
          ),
          ListTile(
            leading: Icon(isLoggedIn ? Icons.logout : Icons.login),
            title: Text(isLoggedIn ? 'Logout' : 'Login'),
            onTap: () async {
              final pageContext = Scaffold.of(context).context;
              final auth = pageContext.read<AuthState>();
              final messenger = ScaffoldMessenger.of(pageContext);
              Navigator.pop(pageContext);
              if (auth.isLoggedIn) {
                await logoutWithFeedback(auth, messenger);
              } else {
                await ensureLoggedIn(pageContext);
              }
            },
          ),
        ],
      ),
    );
  }
}
