import 'package:flutter/material.dart';

class StoryView extends StatelessWidget {
  final String imagePath;

  const StoryView({super.key, required this.imagePath});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Hellow")),
      body: GestureDetector(
        onTap: () {
          Navigator.pushReplacementNamed(context, "/story");
        },
        child: Image.network(
          imagePath,
          width: double.infinity,
          height: double.infinity,
          fit: BoxFit.cover,
        ),
      ),
    );
  }
}
