import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter/src/widgets/placeholder.dart';
import 'package:cached_network_image/cached_network_image.dart';

class CustomImageCard extends StatelessWidget {
  final String title;
  final String date;
  final String? subtitle;
  final String? urlImage;

  const CustomImageCard({
    super.key,
    required this.title,
    required this.date,
    this.subtitle,
    this.urlImage,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: CachedNetworkImage(
        imageUrl: urlImage ?? 'http://via.placeholder.com/350x150',
        placeholder: (context, url) => Center(
          child: CircularProgressIndicator(),
        ),
        errorWidget: (context, url, error) => Center(
          child: Icon(Icons.error),
        ),
        fit: BoxFit.fill,
        width: 100,
      ),
      //  Image.network(
      //   // 'https://images.unsplash.com/photo-1641789674112-0848c5df964e?ixlib=rb-4.0.3&ixid=MnwxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8&auto=format&fit=crop&w=774&q=80',
      //   urlImage ?? 'http://via.placeholder.com/350x150',
      //   fit: BoxFit.fill,
      //   width: 100,
      // ),
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
