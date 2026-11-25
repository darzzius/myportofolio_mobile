import 'package:material_ui/material_ui.dart';
import 'package:myportofolio_mobile/screens/menu.dart';
import 'package:myportofolio_mobile/services/auth_state.dart';
import 'package:myportofolio_mobile/widgets/auth_guard.dart';
import 'package:provider/provider.dart';

class ItemCard extends StatelessWidget {
  final ItemHomepage item;

  const ItemCard(this.item, {super.key});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: item.color,
      borderRadius: BorderRadius.circular(12),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () async {
          if (item.isAuthAction) {
            final auth = context.read<AuthState>();
            if (auth.isLoggedIn) {
              await logoutWithFeedback(auth, ScaffoldMessenger.of(context));
            } else {
              await ensureLoggedIn(context);
            }
            return;
          }

          final destination = item.destination;
          if (destination == null) return;
          if (item.requiresLogin) {
            final loggedIn = await ensureLoggedIn(context);
            if (!loggedIn || !context.mounted) return;
          }
          Navigator.push(
            context,
            MaterialPageRoute<void>(builder: (_) => destination),
          );
        },
        child: Container(
          padding: const EdgeInsets.all(8),
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(item.icon, color: Colors.white, size: 30.0),
                const Padding(padding: EdgeInsets.all(3)),
                Text(
                  item.name,
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: Colors.white),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
