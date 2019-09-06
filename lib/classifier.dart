import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:http/http.dart' as http;
import 'package:naive_bayes/naive_bayes.dart';

import 'dart:convert';
import 'dart:async' show Future;

import './models/tweet.dart';

class Classifier{
  var classifier = NaiveBayes();

  Future<String> loadLabels() async {
    return await rootBundle.loadString('assets/newlabelsheadline.csv');
  }
  Future<String> loadTweets() async {
    return await rootBundle.loadString('assets/cleanedtweets.csv');
  }
  Future<String> loadKeys() async {
    return await rootBundle.loadString('assets/keys.txt');
  }
  Future<void> train2() async{
    print("started training");
    var labels;
    await loadLabels().then((value){
      labels = value.split("\n");
    });
    return await loadTweets().then((value2) {
      var tweets = value2.split("\n");
      print("in training");
      for (var i = 0; i < 2600; i++) {
        classifier.learn(tweets[i].split(" "), labels[i]);
      }
    });
  }
  Future<bool> train(){
    print("started training");
    loadLabels().then((value){
      var labels = value.split("\n");
      loadTweets().then((value2) {
        var tweets = value2.split("\n");
        print("in training");
        for (var i = 0; i < 2600; i++) {
          classifier.learn(tweets[i].split(" "), labels[i]);
        }
        print("Finished training");
      });
    });

    return Future.value(true);
  }
  Future<void> classify(List<Tweet> tweets) async{
    const url = "https://japerk-text-processing.p.rapidapi.com/stem/";
    String query = "";
    for(Tweet t in tweets) {
      query = query + t.body.replaceAll(RegExp("[^a-zA-Z0-9\\s+]"), "").replaceAll("\r\n", " ").replaceAll("\n", " ") + " ∇ ";
    }
    //print(query);
    //print(query.length);
    return loadKeys().then((keys){
      String xAPIKey = keys.split("\r\n")[0];
      return http.post(
        url,
        headers: {
          "X-RapidAPI-Host": "japerk-text-processing.p.rapidapi.com",
          "X-RapidAPI-Key": xAPIKey,
          "Content-Type": "application/x-www-form-urlencoded"
        },
        body: "text=" + query,
      ).then((response){
        final dataEx = json.decode(response.body) as Map<String, dynamic>;
        String result = dataEx['text'];
        //print("RESULT: " + result);
        List<String> stemmedTweets = result.split("∇");
        //print("TWEETS LENGTH: " + tweets.length.toString() + ", STEMMED LENGTH: " + stemmedTweets.length.toString());
        for (var i = 0; i < stemmedTweets.length - 1; i++) {
          //print(stemmedTweets[i] + " " + i.toString());
          //print(classifier.categorize(stemmedTweets[i].split(" ")));
          tweets[i].setTopic(classifier.categorize(stemmedTweets[i].split(" ")));
        }
      });
    });
  }
}