import 'package:flutter/material.dart';

//========== APP BAR ===================//
Widget bar(String title) {
  return ( AppBar(
    title: Row(
      children: [
        Image(
          image: (AssetImage('images/logo.png') ),
          fit: BoxFit.cover,
          width: 50,
        ),
        Container(
          alignment: Alignment.centerLeft,
          padding: EdgeInsets.only(left:100),
          child: Text(title),
        ),
      ],
    ),
  ));
}





