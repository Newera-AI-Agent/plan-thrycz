import 'package:flutter/material.dart';
import 'package:flame/game.dart';

class MarioGamePage extends StatelessWidget {
  const MarioGamePage({super.key});
  @override
  Widget build(BuildContext context) => Scaffold(
    body: Center(child: Text('Mario Game')),
  );
}

void main() => runApp(const MarioApp());

class MarioApp extends StatelessWidget {
  const MarioApp({super.key});
  @override
  Widget build(BuildContext context) => MaterialApp(
    debugShowCheckedModeBanner: false,
    home: MarioGamePage(),
  );
}
