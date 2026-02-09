import 'package:flutter/material.dart';
import 'package:ngo_web/widgets/section_key.dart';
import 'package:provider/provider.dart';

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
  final keyContext = sectionKeys[index].currentContext;
  if (keyContext != null) {
    Scrollable.ensureVisible(
      keyContext,
      duration: const Duration(milliseconds: 700),
      curve: Curves.easeInOut,
    );
  }
}
