import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'section_key.dart';

class ScrollState extends ChangeNotifier {
  int _currentSection = 0;
  int get currentSection => _currentSection;

  void updateSection(int index) {
    if (_currentSection != index) {
      _currentSection = index;
      notifyListeners();
    }
  }
}

void scrollToSection(BuildContext context, int index) {
  Provider.of<ScrollState>(context, listen: false).updateSection(index);

  final size = MediaQuery.of(context).size;
  final bool useKeyBasedScroll = size.width < 1000;

  if (useKeyBasedScroll) {
    if (index < 0 || index >= sectionKeys.length) return;
    final ctx = sectionKeys[index].currentContext;
    if (ctx == null) return;
    Scrollable.ensureVisible(
      ctx,
      duration: const Duration(milliseconds: 800),
      curve: Curves.easeInOut,
      alignment: 0.0,
    );
    return;
  }
  if (index < 0 || index >= sectionKeys.length) return;
  final ctx = sectionKeys[index].currentContext;
  if (ctx == null) return;
  Scrollable.ensureVisible(
    ctx,
    duration: const Duration(milliseconds: 800),
    curve: Curves.easeInOut,
    alignment: 0.0,
  );
}
