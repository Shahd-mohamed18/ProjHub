import 'package:flutter/material.dart';

class CustomWelcomeWidget extends StatelessWidget {
  CustomWelcomeWidget({
    super.key,
    required this.subtitle1,
    required this.title,
    required this.subtitle2,
    required this.imagePath,
    this.color,
  });
  String title;
  String subtitle1;
  String subtitle2;
  String imagePath;
  Color? color;
  @override
  Widget build(BuildContext context) {
    return Card(
      color: Colors.white,
      margin: EdgeInsets.only(bottom: 50, left: 10, right: 10),
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(6),
        child: ListTile(
          leading: Container(
            padding: EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Image.asset(imagePath, ),
          ),
          title: Text(
            title,
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
          ),
          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.start,
            children: [Text(subtitle1), Text(subtitle2)],
          ),
        ),
      ),
    );
  }
}
