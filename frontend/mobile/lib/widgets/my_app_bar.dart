import 'package:flutter/material.dart';

class MyAppBar extends AppBar {
  MyAppBar({super.key, required String appBarTitle})
    : super(
        title: Text(appBarTitle),
        centerTitle: true,
        backgroundColor: Colors.green,
        foregroundColor: Colors.white,
      );
}
