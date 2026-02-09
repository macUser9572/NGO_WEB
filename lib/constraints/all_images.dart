import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class AllImages {
  // PNG
  static Widget companyPng() {
    return Image.asset('assets/image/companylogo.png', fit: BoxFit.contain);
  }

  static Widget greenlogo() {
    return Image.asset('assets/image/green_logo.png', fit: BoxFit.contain);
  }
}
