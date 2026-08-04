import 'package:flutter/material.dart';

void main() => runApp(const MarioApp());

class MarioApp extends StatelessWidget {
  const MarioApp({super.key});
  @override
  Widget build(BuildContext context) => MaterialApp(
    debugShowCheckedModeBanner: false,
    theme: ThemeData(useMaterial3: true),
    home: const MarioGamePage(),
  );
}
