import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter/material.dart';

class FsPush extends StatelessWidget {
  const FsPush({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ScaffoldPage(
      header: AppBar(
        title: const Text("FsPush"),
      ),
    );
  }
}
