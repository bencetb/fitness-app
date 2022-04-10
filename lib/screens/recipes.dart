import 'package:flutter/material.dart';

import '../widgets/drawer.dart';

class Recipes extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Receptjeim'),
        centerTitle: true,
      ),
      drawer: const Drawer(
        child: BuildDrawer(),
      ),
    );
  }
}
