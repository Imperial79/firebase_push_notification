import 'package:flutter/material.dart';

class Page2UI extends StatefulWidget {
  final String payload;
  const Page2UI({super.key, required this.payload});

  @override
  State<Page2UI> createState() => _Page2UIState();
}

class _Page2UIState extends State<Page2UI> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Text("This is page 2 ${widget.payload}"),
      ),
    );
  }
}
