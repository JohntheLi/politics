import 'package:flutter/material.dart';

class Tweet{
  final String handle;
  final String image;
  final String date;
  final String name;
  final String body;
  final String url;
  final String id;
  bool liked = false;
  String topic = "None";
  Tweet(
      {@required this.handle,
        @required this.image,
        @required this.date,
        @required this.name,
        @required this.body,
        @required this.url,
        @required this.id});
  void setTopic(String topic){
    this.topic = topic;
  }
}

