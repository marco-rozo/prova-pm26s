import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter/src/widgets/placeholder.dart';

class CustomListTile extends StatelessWidget {
  final String title;
  final String date;
  final String? subtitle;

  const CustomListTile({
    super.key,
    required this.title,
    required this.date,
    this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text("$title"),
          Text(
            "$date",
            style: const TextStyle(
              color: Colors.grey,
              fontSize: 12,
            ),
          ),
        ],
      ),
      subtitle: Text("${subtitle ?? ''}"),
    );
  }
}
