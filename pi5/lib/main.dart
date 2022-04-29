import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:pi5/Home.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(MaterialApp(
      home: const homePageState(), debugShowCheckedModeBanner: false));
}
