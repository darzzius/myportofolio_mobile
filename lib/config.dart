import 'package:flutter/foundation.dart';

const apiBaseUrl = String.fromEnvironment(
  'API_BASE_URL',
  defaultValue: kIsWeb
      ? 'https://rafael-darius-myportofolio.pws.cs.ui.ac.id'
      : 'http://10.0.2.2:8000',
);
