// Main App
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_nps/root/view/index.dart';

import 'root/bloc/data_bloc.dart';
import 'root/bloc/data_event.dart';

class App extends StatelessWidget {
  const App({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Module',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
        useMaterial3: true,
      ),
      home: BlocProvider(
        create: (context) => DataBloc()..add(DataInitialized()),
        child: const IndexPage(),
      ),
    );
  }
}
