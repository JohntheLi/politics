import 'package:flutter/material.dart';

class Poll{
  final String name;
  final String source;
  final String data;
  final String result;
  final String winnerParty;
  Poll(
      {@required this.name,
        @required this.source,
        @required this.data,
        @required this.result,
        @required this.winnerParty,
      });
}