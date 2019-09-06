import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:flutter/services.dart' show rootBundle;

import './modules.dart';
import './election_modules.dart';
import './models/article.dart';
import './dummyhttp.dart';
import './classifier.dart';
import './models/bill.dart';
import './models/tweet.dart';
import './models/poll.dart';
import './profile_page.dart';

import 'dart:io';

class ModuleManager extends StatefulWidget{
  @override
  ModuleManagerState createState() => ModuleManagerState();
}

class ModuleManagerState extends State<ModuleManager>{
  List<String> allTopics = ["All", "Immigration", "Healthcare", "Climate", "Economy", "Education", "Guns", "Justice",
  "Military", "Race Relations", "Sex Relations", "Technology", "Voting Rights"];
  List<String> allItems = ["Immigration", "Healthcare", "Climate", "Economy", "Education", "Guns", "Justice",
  "Military", "Race Relations", "Sex Relations", "Technology", "Voting Rights"];
  List<String> items = ["Immigration", "Healthcare", "Climate"];
  List<String> standardLoadingItems = ["Immigration", "Healthcare", "Climate"];
  //TODO: Find a better way to make empty lists
  List<List<Tweet>> tweets = [[],[],[],[],[],[],[],[],[],[],[],[]];
  List<List<Bill>> bills = [[],[],[],[],[],[],[],[],[],[],[],[]];
  List<List<Article>> articles = [[],[],[],[],[],[],[],[],[],[],[],[]];
  List<Poll> polls = [];
  List<Article> electionArticles = [];

  //placeholders for values when searching modifies original lists
  List<Article> articleHolder = [];
  List<Tweet> tweetHolder = [];
  List<Bill> billHolder = [];
  String itemHolder = "memes";
  double y = 5.0;
  double x = 5.0;

  var classifier = Classifier();
  var httpManager = Dummy();
  var _isLoadingBill = false;
  var _isLoadingTweets = false;
  var _isLoadingElection = false;
  var _isLoadingSearch = false;
  var perPage = 3;
  var present = 0;
  var manualItemsLength = 3;
  ScrollController _controller;
  String selectedTopic = "All";
  List<bool> topicSelected = List.filled(13, false);

  _scrollListener() {
    if (_controller.offset >= _controller.position.maxScrollExtent &&
        !_controller.position.outOfRange) {
      setState(() {
        print("ScrollListener reached the bottom!!!!!");
        if(present < allItems.length) {
          loadMore();
        }
      });
    }
  }

  Future<String> get _localPath async {
    final directory = await getApplicationDocumentsDirectory();
    return directory.path;
  }

  @mustCallSuper
  void initState() {
    _controller = ScrollController();
    _controller.addListener(_scrollListener);
    _isLoadingBill = true;
    _isLoadingTweets = true;
    _isLoadingElection = true;
    topicSelected[0] = true;
    classifier.train().then((value){loadTweets();});
    loadBillAndArticleForTopic().then((_){
      _isLoadingBill = false;
      present = present + perPage;
    });
    httpManager.fetchPollingData().then((result){
      polls = result;
      httpManager.updateNews("2020%20Presidential%20Election").then((value){
        electionArticles = value;
        _isLoadingElection = false;
      });
    });
    _localPath.then((path){
      File f = File('$path/article.txt');
      f.writeAsString(" ").then((_){
        f = File('$path/tweet.txt');
        f.writeAsString(" ").then((_){
          f = File('$path/bill.txt');
          f.writeAsString(" ");
        });
      });
    });
    loadStance().then((stance){
      y = double.parse(stance.split(", ")[0]);
      x = double.parse(stance.split(", ")[1]);
    });
    super.initState();
  }
  Future<String> loadStance() async{
    return _localPath.then((path){
      File f = File('$path/userPoliticalSides.txt');
      return f.readAsStringSync();
    });
  }
  Future<void> loadBillAndArticleForTopic() async{
    int min = (allItems.length < present + perPage) ? allItems.length : present + perPage;
    for(int i = present; i < min; i++){
      String topic = allItems[i];
      await httpManager.updateNews(topic).then((value){
        setState(() {
          articles[i] = value;
        });
      });
      await httpManager.updateBills(topic).then((value){
        setState(() {
          bills[i] = value;
        });
      });
    }
  }
  
  Future<void> loadTweets() async{
    List<Tweet> loadedTweets;
    await httpManager.updateTweets().then((value){
      loadedTweets = value;
      classifier.classify(loadedTweets).then((_){
        List<List<Tweet>> temp = [];
        for(String topic in allItems){
          List<Tweet> tempListForTopic = [];
          for(Tweet t in loadedTweets){
            if(t.topic.replaceAll(RegExp("[^a-zA-Z0-9]"), "") == topic.replaceAll(RegExp("[^a-zA-Z0-9]"), "")) {
              tempListForTopic.add(t);
            }
            print(t.body + "; " + t.topic);
          }
          temp.add(tempListForTopic);
        }
        setState(() {
          tweets = temp;
          _isLoadingTweets = false;
        });
      });
    });
  }

  void loadMore() {
    print("LOADING MORE -------------------------------------------------");
    //_isUpdatingBill = true;
    setState(() {
      if((present + perPage) > allItems.length) {
        items.addAll(
            allItems.getRange(present, allItems.length));
      } else {
        items.addAll(
            allItems.getRange(present, present + perPage));
      }
    });
    loadBillAndArticleForTopic().then((_){
      setState(() {
        manualItemsLength = (allItems.length < present + perPage) ? allItems.length : present + perPage;
        present = present + perPage;
        //_isUpdatingBill = false;
      });
    });

  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color.fromRGBO(64, 64, 64, 100),
      body: DefaultTabController(
        length: 3,
        child:
              NestedScrollView(
              headerSliverBuilder:
                (BuildContext context, bool innerBoxIsScrolled) {
                return <Widget> [
                SliverOverlapAbsorber(
                  handle: NestedScrollView.sliverOverlapAbsorberHandleFor(context),
                  child: SliverSafeArea(
                    top: false,
                    sliver:
                  SliverAppBar(
                    title: Text ("Politic.us: U.S. Political News Tracker", textScaleFactor: 0.8,),
                    floating: true,
                    pinned: true,
                    snap: true,
                    primary: true,
                    forceElevated: innerBoxIsScrolled,
                    //expandedHeight: 20,
                    backgroundColor: Theme.of(context).accentColor,
                    bottom: TabBar(tabs: [
                      Tab(text: "Topics",),
                      Tab(text: "Elections",),
                      Tab(text: "You"),
                    ]),
                  ),
                  ),
                )
              ];
            },
            body:
            _isLoadingTweets | _isLoadingBill | _isLoadingElection ? Center(child: CircularProgressIndicator(),) :
            TabBarView(
              children: [
                SafeArea(
                    top: false,
                    bottom: false,
                    child: Builder(
                      builder: (BuildContext context) {
                        return CustomScrollView(
                            controller: _controller,
                            slivers: <Widget> [
                              SliverOverlapInjector(
                                handle: NestedScrollView.sliverOverlapAbsorberHandleFor(context),
                              ),
                              SliverList(
                                delegate: SliverChildBuilderDelegate(
                                  _buildCard,
                                  childCount: (present < allItems.length) ? manualItemsLength + 2 : manualItemsLength + 1,
                                  //childCount: items.length,
                                ),
                              ),
                            ]
                        );
                      },
                    )
                ),
                SafeArea(
                    top: false,
                    bottom: false,
                    child: Builder(
                      builder: (BuildContext context) {
                        return CustomScrollView(
                            controller: _controller,
                            slivers: <Widget> [
                              SliverOverlapInjector(
                                handle: NestedScrollView.sliverOverlapAbsorberHandleFor(context),
                              ),
                              SliverList(
                                delegate: SliverChildBuilderDelegate(
                                  _buildElectionCard,
                                  childCount: 1,
                                ),
                              ),
                            ]
                        );
                      },
                    )
                ),
                ProfilePage(0.78, 0.83),
              ],
            ),)
      ),
    );
  }
//  Widget _buildCard(BuildContext context, int index) {
//    print("no. tweets: " + tweets.length.toString() + " index: " + index.toString());
//    return Modules(articles[index], bills[index], tweets[index], items[index]);
//  }
  Widget _buildCard(BuildContext context, int index) {
    if (index == manualItemsLength + 1) {
      return Container(child: Center(child: CircularProgressIndicator(),),);
    } else if (index == 0) {
      return Wrap(
        children: List<Widget>.generate(13, (int indexer){
          return ChoiceChip(
            label: Text(allTopics[indexer]),
            selected: topicSelected[indexer],
            onSelected: (bool selected){
              if (selected) {
                print("Selected " + allTopics[indexer]);
                setState(() {
                  allItems = new List<String>.from(allTopics);
                  allItems.removeAt(0);
                  if (articleHolder.isNotEmpty) {
                    articles[0] = articleHolder;
                    articleHolder.clear();
                  }
                  if (billHolder.isNotEmpty) {
                    bills[0] = billHolder;
                    billHolder.clear();
                  }
                  if (tweetHolder.isNotEmpty) {
                    tweets[0] = tweetHolder;
                    tweetHolder.clear();
                  }
                  if (itemHolder != "memes") {
                    items[0] = itemHolder;
                    itemHolder = "memes";
                  }
                  List<bool> temp = List.filled(13, false);
                  temp[indexer] = true;
                  topicSelected = temp;
                  if(indexer == 0) {
                    perPage = 3;
                    present = 0;
                    items = standardLoadingItems;
                    manualItemsLength = 3;
                    _isLoadingSearch = true;
                    loadBillAndArticleForTopic().then((_){
                      _isLoadingSearch = false;
                      present = present + perPage;
                    });
                  } else {
                    perPage = 1;
                    present = indexer - 1;
                    _isLoadingSearch = true;
                    loadBillAndArticleForTopic().then((_){
                      //articlePlaceholder = articles;
                      List<Article> a = articles[indexer - 1];
                      List<Bill> b = bills[indexer - 1];
                      List<Tweet> t = tweets[indexer - 1];
                      for(int i = 0; i < articles.length; i++) {
                        if(articles[i].isNotEmpty) {
                          print(i.toString() + "th article: " +
                              articles[i][0].id);
                        }
                      }
                      billHolder = bills[0];
                      articleHolder = articles[0];
                      itemHolder = items[0];
                      tweetHolder = tweets[0];
                      articles[0] = a;
                      items[0] = allTopics[indexer];
                      bills[0] = b;
                      tweets[0] = t;
                      _isLoadingSearch = false;
                    });
                    manualItemsLength = 1;
                    allItems.clear();
                    allItems.add(allTopics[indexer]);

//                    perPage = 0;
//                    manualItemsLength = 0;
//                    items.clear();
//                    allItems.clear();
//                    allItems.add(allTopics[indexer]);
//                    items.add(allTopics[indexer]);
//                    present = indexer - 1;
//                    perPage = 1;
//                    manualItemsLength = 1;
//                    _isLoadingSearch = true;
//                    loadBillAndArticleForTopic().then((_){
//                      articlePlaceholder = articles;
//                      articles.clear();
//                      articles.add(articlePlaceholder[indexer - 1]);
//                      _isLoadingSearch = false;
//                    });
                  }
                });
              } else {
                print("Nothing new selected!!!!!!!!!");
              }
            },
          );
      }).toList(),
      );
    } else if (_isLoadingSearch){
      return Container(child: Center(child: CircularProgressIndicator(),),);
    }
    else {
      return Modules(articles[index - 1], bills[index - 1], tweets[index - 1], items[index - 1]);
    }
  }
  Widget _buildElectionCard(BuildContext context, int index) {
    return ElectionModules(electionArticles, polls);
  }
}