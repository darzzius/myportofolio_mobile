import 'package:material_ui/material_ui.dart';
import 'package:myportofolio_mobile/screens/login_screen.dart';
import 'package:myportofolio_mobile/services/auth_state.dart';
import 'package:provider/provider.dart';

Future<bool> ensureLoggedIn(
  BuildContext context, {
  bool sessionExpired = false,
}) async {
  if (context.read<AuthState>().isLoggedIn) return true;

  return await Navigator.push<bool>(
        context,
        MaterialPageRoute<bool>(
          builder: (_) => LoginScreen(sessionExpired: sessionExpired),
        ),
      ) ??
      false;
}

Future<void> logoutWithFeedback(
  AuthState auth,
  ScaffoldMessengerState messenger,
) async {
  var message = 'Kamu sudah logout.';
  try {
    await auth.logout();
  } on Exception {
    message = 'Logout lokal selesai, tetapi server belum mengonfirmasi pencabutan token.';
  }
  if (messenger.mounted) {
    messenger
      ..clearSnackBars()
      ..showSnackBar(SnackBar(content: Text(message)));
  }
}
