import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'app/app_container.dart';
import 'app/nmdiet_app.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  LicenseRegistry.addLicense(() async* {
    yield LicenseEntryWithLineBreaks([
      'TildaSans',
    ], await rootBundle.loadString('assets/fonts/OFL.txt'));
  });
  final container = AppContainer.production();
  runApp(NmdietApp(container: container));
  container.initialize();
}
