import 'package:flutter/material.dart';

const int kSectionCount =11;
final List<GlobalKey>sectionKeys = 
    List.generate(kSectionCount,(_)=> GlobalKey());