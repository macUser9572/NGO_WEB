import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:ngo_web/widgets/scroll_helper.dart';

import 'package:provider/provider.dart';
import 'Page/homeview.dart';
import 'firebase_options.dart'; // 🔥 ADD THIS

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  runApp(
    ChangeNotifierProvider(create: (_) => ScrollState(), child: const MyApp()),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: HomeView(),
    );
  }
}
