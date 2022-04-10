import 'package:flutter/material.dart';

import '../widgets/drawer.dart';

class Diary extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Naplóm'),
        centerTitle: true,
      ),
      drawer: const Drawer(
        child: BuildDrawer(),
      ),
    );
  }
}
