import 'package:flutter/material.dart';
import 'package:go_to_home/joystick.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key, required this.title}) : super(key: key);

  final String title;

  @override
  State<HomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<HomePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.title)),
      body: const Center(child: Text('Games')),
      floatingActionButton: Joystick(
        onChanged: (speed, angle) {
          //print('Speed $speed - Angle $angle')
        },
      ),
    );
  }
}
