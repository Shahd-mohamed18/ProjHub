import 'package:flutter/material.dart';
import 'package:onboard/widgets/project_section_widget.dart';

class ProjectScreen extends StatelessWidget {
  const ProjectScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          height: 100,
          color: Colors.white,
          padding: EdgeInsets.only(top: 40, left: 20, right: 20, bottom: 5),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Explore Projects', style: TextStyle(fontSize: 25)),
              // SizedBox(width: 100),
              Row(
                children: [
                  Icon(Icons.notification_add_outlined, size: 25),
                  SizedBox(width: 15),
                  Icon(Icons.add_circle_outline, size: 25),
                ],
              ),
            ],
          ),
        ),
        SizedBox(height: 20),
        SizedBox(
          height: 40,
          child: ListView(
            scrollDirection: Axis.horizontal,
            children: [
              ProjectSectionWidget(projectCategory: 'All'),
              ProjectSectionWidget(projectCategory: 'E-Commerce'),
              ProjectSectionWidget(projectCategory: 'Education'),
              ProjectSectionWidget(projectCategory: 'Sport'),
              ProjectSectionWidget(projectCategory: 'Tourism'),
              ProjectSectionWidget(projectCategory: 'Disability'),
              ProjectSectionWidget(projectCategory: 'Agriculture'),
              ProjectSectionWidget(projectCategory: 'medical'),
            ],
          ),
        ),
        SizedBox(height: 10),
        Expanded(
          child: ListView.builder(
            itemCount: 10,
            itemBuilder: (context, index) {
              return Card(
                elevation: 3,
                margin: EdgeInsets.all(10),
                color: Colors.white,
                child: ListTile(
                  leading: SizedBox(
                    height: 300,
                    width: 100,
                    child: Image.asset(
                      'assets/images/test.jpg',
                      fit: BoxFit.fill,
                    ),
                  ),
                  title: Text(
                    'ProjHub',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  subtitle: Text(
                    ' Build a full-featured e-commerce  websitewith product listings,a shopping cart, and a payment gateway',
                    style: TextStyle(fontWeight: FontWeight.w400),
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}
