import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class ScrollTransformView extends StatefulWidget {
  final List<Widget> children;
  final ScrollController? controller;

  const ScrollTransformView({
    super.key,
    required this.children,
    this.controller,
  });

  @override
  State<ScrollTransformView> createState() => _ScrollTransformViewState();
}

class _ScrollTransformViewState extends State<ScrollTransformView> {
  late ScrollController scrollController;

  @override
  void initState() {
    super.initState();
    scrollController = widget.controller ?? ScrollController();
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      controller: scrollController,
      physics: const BouncingScrollPhysics(),
      child: ChangeNotifierProvider.value(
        value: scrollController,
        child: Column(children: widget.children),
      ),
    );
  }
}