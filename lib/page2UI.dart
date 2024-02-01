import 'package:flutter/material.dart';

class Page2UI extends StatefulWidget {
  const Page2UI({super.key});

  @override
  State<Page2UI> createState() => _Page2UIState();
}

class _Page2UIState extends State<Page2UI> {
  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: Text("This is page 2"),
      ),
    );
  }
}
