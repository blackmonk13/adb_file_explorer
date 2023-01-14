import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter/material.dart';

class ApkInstall extends StatelessWidget {
  const ApkInstall({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ScaffoldPage(
      header: AppBar(
        title: const Text("ApkInstall"),
      ),
    );
  }
}
