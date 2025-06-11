import 'package:flutter/material.dart';
import 'package:flutter_nps/app/app.dart';
import 'package:flutter_nps/bootstrap.dart';

void main() {
  bootstrap(() => const SampleApp());
}

@pragma("vm:entry-point")
void loadFromNative() async {
  WidgetsFlutterBinding.ensureInitialized();
  bootstrap(() => const SampleApp());
}
