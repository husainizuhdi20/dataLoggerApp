import 'dart:async';

import 'package:flutter/material.dart';
import './login.dart';
import 'dart:ui';

class SplashScreen extends StatefulWidget {
  const SplashScreen({Key? key}) : super(key: key);

  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    Timer(Duration(seconds: 5), () {
      Navigator.pushReplacement(
          context, MaterialPageRoute(builder: (context) => LoginPage()));
    });
  }

  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        color: Colors.blue,
        width: MediaQuery.of(context).size.width,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Parametrik',
              style: TextStyle(
                  fontSize: 40,
                  color: Color.fromARGB(255, 179, 161, 6),
                  fontWeight: FontWeight.bold,
                  shadows: <Shadow>[
                    Shadow(
                        offset: Offset(2.0, 2.0),
                        blurRadius: 2.0,
                        color: Color.fromARGB(255, 255, 255, 255))
                  ]),
            ),
          ],
        ),
      ),
    );
  }
}
