import 'package:flutter/material.dart';

const int kSectionCount =8;
final List<GlobalKey>sectionKeys = 
    List.generate(kSectionCount,(_)=> GlobalKey());