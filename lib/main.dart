import 'package:flutter/material.dart';
import 'app/app_container.dart';
import 'app/nmdiet_app.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  final container = AppContainer.production();
  runApp(NmdietApp(container: container));
  container.initialize();
}
