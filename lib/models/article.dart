import 'package:flutter/material.dart';

class Article{
  final String provider;
  final String image;
  final String date;
  final String description;
  final String url;
  final String id;
  bool liked = false;
  Article(
      {@required this.provider,
        @required this.image,
        @required this.date,
        @required this.description,
        @required this.url,
        @required this.id});
}