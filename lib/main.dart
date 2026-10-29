import 'package:flutter/material.dart';

import 'viewmodels/library_view_model.dart';
import 'views/library_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final viewModel = LibraryViewModel();
  await viewModel.init();
  runApp(LibraryApp(viewModel: viewModel));
}

class LibraryApp extends StatefulWidget {
  const LibraryApp({super.key, required this.viewModel});
  final LibraryViewModel viewModel;

  @override
  State<LibraryApp> createState() => _LibraryAppState();
}

class _LibraryAppState extends State<LibraryApp> {
  @override
  void dispose() {
    widget.viewModel.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Perpustakaan',
      theme: ThemeData(colorSchemeSeed: Colors.indigo, useMaterial3: true),
      home: LibraryScreen(viewModel: widget.viewModel),
    );
  }
}