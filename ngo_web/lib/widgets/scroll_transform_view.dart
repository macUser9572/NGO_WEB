import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class ScrollTransformView extends StatelessWidget {
  final List<Widget> children;
  final ScrollController controller;

  const ScrollTransformView({
    super.key,
    required this.children,
    required this.controller,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      controller: controller,
      physics: const BouncingScrollPhysics(),
      child: Column(children: children),
    );
  }
}
