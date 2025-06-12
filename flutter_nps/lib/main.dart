import 'package:flutter/material.dart';
import 'package:flutter_nps/utils/bootstrap.dart';

import 'app.dart';

void main() {
  bootstrap(() => const App());
}

@pragma("vm:entry-point")
void loadFromNative() async {
  WidgetsFlutterBinding.ensureInitialized();
  bootstrap(() => const App());
}
