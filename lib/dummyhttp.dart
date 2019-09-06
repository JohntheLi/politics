import 'package:http/http.dart' as http;
import 'package:html/parser.dart';
import 'dart:convert';
import 'dart:math' show Random;
import 'package:flutter/services.dart' show rootBundle;
import 'package:random_string/random_string.dart';

import './models/article.dart';
import './models/bill.dart';
import './models/tweet.dart';
import './models/poll.dart';

class Dummy {
  static const q = "healthcare";
  static const pageno = "1";
  static const pagesize = "2";
  static const auto = "true";
  static const safe = "false";

  static const billsubj = "healthcare";

  Future<String> loadKeys() async {
    return await rootBundle.loadString('assets/keys.txt');
  }

  Future<List<Poll>> fetchPollingData() async {
    final url = "https://www.realclearpolitics.com/epolls/latest_polls/general_election/";
    return http.get(url).then((response){
      final document = parse(response.body);
      var nameElements = document.getElementsByClassName("lp-race");
      var sourceElements = document.getElementsByClassName("lp-poll");
      var resultElements = document.getElementsByClassName("lp-results");
      var spreadElements = document.getElementsByClassName("lp-spread");

      List<Poll> polls = [];
      for(int i = 1; i < 4; i++) {
        String name = "N/A";
        String source = "N/A";
        String spread = "N/A";
        String party = "N/A";
        String result = "N/A";
        try {
          name = nameElements[i].nodes[0].nodes[0].toString();
        }catch(e){
          name = "N/A";
        }
        try {
          source = sourceElements[i].nodes[0].nodes[0].toString();
        }catch(e){
          source = "N/A";
        }
        try {
          spread = spreadElements[i].nodes[0].nodes[0].nodes[0].toString();
        }catch(e){
          spread = "N/A";
        }
        try {
          party = spreadElements[i].nodes[0].nodes[0].attributes.toString().substring(8, 11);
        }catch(e){
          party = "N/A";
        }
        try {
          result = resultElements[i - 1].nodes[0].nodes[0].toString();
        }catch(e){
          result = "N/A";
        }
        polls.add(Poll(name: name, source: source, data: result, result: spread, winnerParty: party));
      }
      return polls;
    });
  }

  Future<List<Article>> updateNews(String topic) async {
    var url = "https://contextualwebsearch-websearch-v1.p.rapidapi.com/api/Search/NewsSearchAPI?autoCorrect=true&pageNumber=" + pageno + "&pageSize=" + pagesize +
        "&q=" + topic + "&safeSearch=false";
    return loadKeys().then((keys){
      String xAPIkey = keys.split("\r\n")[0];
      return http.get(
        url,
        headers: {
          "X-RapidAPI-Key": xAPIkey,
          "X-RapidAPI-Host" : "contextualwebsearch-websearch-v1.p.rapidapi.com"
        },
      ).then((response){
        print(json.decode(response.body));
        final dataEx = json.decode(response.body) as Map<String, dynamic>;
        final values = dataEx['value'];
        final List<Article> loadedArticles = [];
        for (var val in values) {
          loadedArticles.add(Article(provider: val['provider']['name'], image: val['image']['url'], date: val['datePublished'],
              description: val['title'], url: val['url'], id: randomAlphaNumeric(10)));
        }
        print("articles loaded: " + loadedArticles.length.toString());
        return loadedArticles;
      });
    });
  }
  Future<List<Bill>> updateBills(String topic) async{
    var url = "https://api.propublica.org/congress/v1/bills/search.json?query=" + topic;
    return loadKeys().then((keys) {
      String xAPIkey = keys.split("\r\n")[1];
      return http.get(
        url,
        headers: {
          "X-API-Key": xAPIkey,
        },
      ).then((response){
        print(json.decode(response.body));
        var data = json.decode(response.body);
        data = data['results'][0]['bills'];
        List<Bill> loadedBills = [];
        for (var i = 0; i < 2; i++) {
          loadedBills.add(
              Bill(title: data[i]['number'],
                  date: data[i]['latest_major_action_date'],
                  description: data[i]['title'],
                  summary: data[i]['summary_short'],
                  sponsor: data[i]['sponsor_name'],
                  sponsorState: data[i]['sponsor_state'],
                  sponsorParty: data[i]['sponsor_party'],
                  url: data[i]['congressdotgov_url'],
                  action: data[i]['latest_major_action'],
                  id: randomAlphaNumeric(10)));
        }
        return loadedBills;
      });
    });
  }

  Future<List<Tweet>> updateTweets() async{
    var count = 20;
    const url = "https://api.twitter.com/1.1/lists/statuses.json?list_id=34179516&count=20";
    return loadKeys().then((keys){
      String twitterKey = keys.split("\r\n")[2];
      return http.get(
        url,
        headers: {
          "Authorization": twitterKey,
        },
      ).then((response){
        print(json.decode(response.body));
        var extractedData = json.decode(response.body);
        List<Tweet> loadedTweets = [];
        for(var i = 0; i < extractedData.length; i ++) {
          loadedTweets.add(Tweet(
            handle: extractedData[i]['user']['screen_name'],
            image: extractedData[i]['user']['profile_image_url_https'],
            date: extractedData[i]['created_at'],
            name: extractedData[i]['user']['name'],
            body: extractedData[i]['text'],
            url: null,
            id: randomAlphaNumeric(10),));
        }
        return loadedTweets;
      });
    });
  }


}