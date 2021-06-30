import 'package:flutter/material.dart';

import 'another_screen.dart';

class HomeScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: TextButton(
          onPressed: () {
            Navigator.push(context, MaterialPageRoute(builder: (context)=>AnotherScreen()));
          },
          child: Text("Another Screen"),
        ),
      ),
    );
  }
}
