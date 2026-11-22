import 'package:material_ui/material_ui.dart';
import 'package:myportofolio_mobile/screens/education_form.dart';
import 'package:myportofolio_mobile/screens/menu.dart';
import 'package:myportofolio_mobile/screens/project_form.dart';

enum DrawerPage { home, project, education }

class LeftDrawer extends StatelessWidget {
  const LeftDrawer({super.key, this.currentPage = DrawerPage.home});

  final DrawerPage currentPage;

  void _navigate(BuildContext context, DrawerPage destination) {
    final navigator = Navigator.of(context);
    navigator.pop();
    if (currentPage == destination) return;

    if (destination == DrawerPage.home && navigator.canPop()) {
      navigator.pop();
      return;
    }

    navigator.pushReplacement(
      MaterialPageRoute<void>(
        builder: (context) => switch (destination) {
          DrawerPage.home => const MyHomePage(),
          DrawerPage.project => const ProjectFormPage(),
          DrawerPage.education => const EducationFormPage(),
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
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
            leading: const Icon(Icons.add_circle_outline),
            title: const Text('Add Project'),
            onTap: () => _navigate(context, DrawerPage.project),
          ),
          ListTile(
            leading: const Icon(Icons.school_outlined),
            title: const Text('Add Education'),
            onTap: () => _navigate(context, DrawerPage.education),
          ),
        ],
      ),
    );
  }
}
