// ignore_for_file: use_build_context_synchronously

import 'package:ems/pages/login_page.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
      options: const FirebaseOptions(
          apiKey: "AIzaSyDGhDLLbGXIQdaW14ntPavEoWn3vHFSOyg",
          appId: "1:125668523719:web:0aef67325222aa8a6788e2",
          storageBucket: "gs://event-management-system-999d4.appspot.com",
          messagingSenderId: "125668523719",
          projectId: "event-management-system-999d4"));
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Event Management',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: const AuthPage(),
    );
  }
}





