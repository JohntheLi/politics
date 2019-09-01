import 'package:flutter/material.dart';

class Bill{
  final String title;
  final String date;
  final String description;
  final String summary;
  final String sponsor;
  final String sponsorState;
  final String sponsorParty;
  final String url;
  final String action;
  final String id;
  bool liked = false;
  Bill(
      {@required this.title,
        @required this.date,
        @required this.description,
        @required this.summary,
        @required this.sponsor,
        @required this.sponsorState,
        @required this.sponsorParty,
        @required this.url,
        @required this.action,
        @required this.id});
}