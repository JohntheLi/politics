import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';

import './models/tweet.dart';
import './models/bill.dart';
import './models/article.dart';
import './MyInAppBrowser.dart';

import 'dart:io';

/*
This is a big and ugly class containing the formatting of all of the cards for
Tweets, Articles, and Bills appearing on the news feed.
 */
class Modules extends StatefulWidget {
  final List<Article> news;
  final List<Bill> bills;
  final List<Tweet> tweets;
  final String topic;
  Modules(this.news, this.bills, this.tweets, this.topic);

  @override
  _ModulesState createState() => _ModulesState();
}

class _ModulesState extends State<Modules> {
  MyInAppBrowser inAppBrowser = new MyInAppBrowser();
  static const int ARTICLE = 0;
  static const int BILL = 1;
  static const int TWEET = 2;
  Map<Article, bool> articleHeartMap;
  Map<Article, bool> articleBrokenHeartMap;
  Map<Bill, bool> billBrokenHeartMap;
  Map<Bill, bool> billHeartMap;
  Map<Tweet, bool> tweetBrokenHeartMap;
  Map<Tweet, bool> tweetHeartMap;

  @override
  void initState() {
    List<bool> tempBoolList = List.filled(widget.news.length, false);
    articleHeartMap = Map.fromIterables(widget.news, tempBoolList);
    articleBrokenHeartMap = Map.fromIterables(widget.news, tempBoolList);
    tempBoolList = List.filled(widget.bills.length, false);
    billBrokenHeartMap = Map.fromIterables(widget.bills, tempBoolList);
    billHeartMap = Map.fromIterables(widget.bills, tempBoolList);
    tempBoolList = List.filled(widget.tweets.length, false);
    tweetBrokenHeartMap = Map.fromIterables(widget.tweets, tempBoolList);
    tweetHeartMap = Map.fromIterables(widget.tweets, tempBoolList);
    super.initState();
  }

  Map<String, bool> showBrokenHeartMap;
  Color getPartyColor(String party) {
    if (party == "D") {
      return Color.fromARGB(255, 55, 171, 180);
    } else {
      return Color.fromARGB(255, 244, 158, 137);
    }
  }

  Future<String> get _localPath async {
    final directory = await getApplicationDocumentsDirectory();
    return directory.path;
  }

  Future<bool> isLiked(int type, String id) {
    return _localPath.then((path) {
      File f;
      if (type == ARTICLE) {
        f = File('$path/article.txt');
      } else if (type == TWEET) {
        f = File('$path/tweet.txt');
      } else {
        f = File('$path/bill.txt');
      }
      return f.readAsString().then((value) {
        List<String> likedItems = value.split("\n");
        for (String item in likedItems) {
          if (item.split("∇")[0] == id) {
            return true;
          }
        }
        return false;
      });
    });
  }

  Future<void> unlike(int type, String id) {
    return _localPath.then((path) {
      File f;
      if (type == ARTICLE) {
        f = File('$path/article.txt');
      } else if (type == TWEET) {
        f = File('$path/tweet.txt');
      } else {
        f = File('$path/bill.txt');
      }
      return f.readAsString().then((value) {
        List<String> likedItems = value.split("\n");
        String builder = "";
        for (int i = 0; i < likedItems.length; i++) {
          String item = likedItems[i];
          if (item.split("∇")[0] == id) {
            continue;
          }
          builder = builder + item + "\n";
        }
        return f.writeAsString(builder);
      });
    });
  }

  Future<void> likeArticle(Article object) {
    return _localPath.then((path) {
      File f = File('$path/article.txt');
      String val = "\n" +
          object.id +
          "∇" +
          object.provider +
          "∇" +
          object.image +
          "∇" +
          object.date +
          "∇" +
          object.description +
          "∇" +
          object.url;
      return f.writeAsString(val, mode: FileMode.append);
    });
  }

  Future<void> likeBill(Bill object) {
    return _localPath.then((path) {
      File f = File('$path/bill.txt');
      String val = "\n" +
          object.id +
          "∇" +
          object.title +
          "∇" +
          object.date +
          "∇" +
          object.description +
          "∇" +
          object.summary +
          "∇" +
          object.sponsor +
          "∇" +
          object.sponsorState +
          "∇" +
          object.sponsorParty +
          "∇" +
          object.url +
          "∇" +
          object.action;
      return f.writeAsString(val, mode: FileMode.append);
    });
  }

  Future<void> likeTweet(Tweet object) {
    return _localPath.then((path) {
      File f = File('$path/tweet.txt');
      String val = "\n" +
          object.id +
          "∇" +
          object.handle +
          "∇" +
          object.image +
          "∇" +
          object.date +
          "∇" +
          object.name +
          "∇" +
          object.body +
          "∇" ;
      return f.writeAsString(val, mode: FileMode.append);
    });
  }

  String cleanDate(String longdate) {
    List<String> parts = longdate.split("-");
    return parts[1] + "/" + parts[2].substring(0, 2);
  }

  String twitterCleanDate(String longdate) {
    List<String> parts = longdate.split(" ");
    return parts[0] + " " + parts[1] + " " + parts[2];
  }

  String blankIfEmpty() {
    return (widget.tweets.length == 0) ? "" : "twitter";
  }

  @override
  Widget build(BuildContext context) {
    List<Widget> newsCards = widget.news
        .map((element) => Card(
              child: InkWell(
                onTap: () async {
                  await inAppBrowser.open(url: element.url, options: {
                    "useShouldOverrideUrlLoading": true,
                    "useOnLoadResource": true
                  });
                },
                onDoubleTap: () {
                  isLiked(ARTICLE, element.id).then((_liked) {
                    if (!_liked) {
                      print("LIKING--------");
                      likeArticle(element).then((_) {
                        setState(() {
                          articleBrokenHeartMap.update(element, (_) => false);
                          articleHeartMap.update(element, (_) => true);
                        });
                        Future.delayed(Duration(seconds: 2)).then((_) {
                          setState(() {
                            articleHeartMap.update(element, (_) => false);
                          });
                        });
                      });
                    } else {
                      unlike(ARTICLE, element.id).then((_) {
                        print("UNLIKING++++++++++++++");
                        setState(() {
                          articleHeartMap.update(element, (_) => false);
                          articleBrokenHeartMap.update(element, (_) => true);
                        });
                        Future.delayed(Duration(seconds: 2)).then((_) {
                          setState(() {
                            articleBrokenHeartMap.update(element, (_) => false);
                          });
                        });
                      });
                    }
                  });
                },
                child: Stack(alignment: Alignment.center, children: [
                  Column(children: [
                    Image(
                      image: NetworkImage(element.image),
                      fit: BoxFit.cover,
                      width: MediaQuery.of(context).size.width - 4.0,
                      height: (MediaQuery.of(context).size.width - 4.0) * 0.5,
                    ),
                    Container(
                        padding: EdgeInsets.all(5.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: <Widget>[
                            Container(
                              padding: EdgeInsets.all(2.0),
                              child: Text(
                                element.description
                                    .replaceAll("<b>", "")
                                    .replaceAll("</b>", ""),
                                textScaleFactor: 1.4,
                              ),
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: <Widget>[
                                Container(
                                  padding: EdgeInsets.all(2.0),
                                  child: Text(
                                    element.provider.toUpperCase(),
                                    style: TextStyle(
                                      color: Color.fromARGB(166, 166, 166, 166),
                                    ),
                                  ),
                                ),
                                Container(
                                  padding: EdgeInsets.all(2.0),
                                  child: Text(
                                    cleanDate(element.date),
                                    style: TextStyle(
                                      color: Color.fromARGB(166, 166, 166, 166),
                                    ),
                                  ),
                                ),
                              ],
                            )
                          ],
                        )),
                  ]),
                  articleHeartMap[element]
                      ? Positioned(
                          child: Opacity(
                            opacity: 0.85,
                            child: Icon(
                              Icons.favorite,
                              size: 80.0,
                            ),
                          ),
                        )
                      : Container(),
                  articleBrokenHeartMap[element]
                      ? Positioned(
                          child: Opacity(
                            opacity: 0.85,
                            child: Icon(
                              Icons.favorite_border,
                              size: 80.0,
                            ),
                          ),
                        )
                      : Container()
                ]),
              ),
            ))
        .toList();

    //Card formatting for Tweets
    List<Widget> tweetCards = widget.tweets
        .map((element) => Card(
              child: InkWell(
                onDoubleTap: () {
                  isLiked(TWEET, element.id).then((_liked) {
                    if (!_liked) {
                      print("LIKING--------");
                      likeTweet(element).then((_) {
                        setState(() {
                          tweetBrokenHeartMap.update(element, (_) => false);
                          tweetHeartMap.update(element, (_) => true);
                        });
                        Future.delayed(Duration(seconds: 2)).then((_) {
                          setState(() {
                            tweetHeartMap.update(element, (_) => false);
                          });
                        });
                      });
                    } else {
                      unlike(TWEET, element.id).then((_) {
                        print("UNLIKING++++++++++++++");
                        setState(() {
                          tweetHeartMap.update(element, (_) => false);
                          tweetBrokenHeartMap.update(element, (_) => true);
                        });
                        Future.delayed(Duration(seconds: 2)).then((_) {
                          setState(() {
                            //showBrokenHeart = false;
                            tweetBrokenHeartMap.update(element, (_) => false);
                          });
                        });
                      });
                    }
                  });
                },
                child: Stack(alignment: Alignment.center,
                  children: [Container(
                padding: EdgeInsets.all(2.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: <Widget>[
                              Container(
                                padding: EdgeInsets.all(10.0),
                                width: 40.0,
                                height: 40.0,
                                decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    image: DecorationImage(
                                      fit: BoxFit.fill,
                                      image: NetworkImage(element.image),
                                    )),
                              ),
                              Container(padding: EdgeInsets.all(5.0), child: Text(
                                element.name,
                              ),)
                            ],
                          ),
                          Container(
                              padding: EdgeInsets.all(5.0),
                              child: Text(
                                "via " +
                                    element.handle +
                                    " on " +
                                    twitterCleanDate(element.date),
                                textScaleFactor: 0.7,
                              ))
                        ]),
                    Container(
                      padding: EdgeInsets.all(10.0),
                      child: Text(element.body),
                    ),
                  ],
                ),
              ),
                  tweetHeartMap[element]
                      ? Positioned(
                    child: Opacity(
                      opacity: 0.85,
                      child: Icon(
                        Icons.favorite,
                        size: 80.0,
                      ),
                    ),
                  )
                      : Container(),
                  tweetBrokenHeartMap[element]
                      ? Positioned(
                    child: Opacity(
                      opacity: 0.85,
                      child: Icon(
                        Icons.favorite_border,
                        size: 80.0,
                      ),
                    ),
                  )
                      : Container()
                ]),
              ),
            ))
        .toList();

    List<Widget> billCards = widget.bills
        .map((element) => Card(
              child: InkWell(
                onTap: () async {
                  await inAppBrowser.open(url: element.url, options: {
                    "useShouldOverrideUrlLoading": true,
                    "useOnLoadResource": true
                  });
                },
                onDoubleTap: () {
                  isLiked(BILL, element.id).then((_liked) {
                    if (!_liked) {
                      print("LIKING--------");
                      likeBill(element).then((_) {
                        setState(() {
                          billBrokenHeartMap.update(element, (_) => false);
                          billHeartMap.update(element, (_) => true);
                        });
                        Future.delayed(Duration(seconds: 2)).then((_) {
                          setState(() {
                            billHeartMap.update(element, (_) => false);
                          });
                        });
                      });
                    } else {
                      unlike(BILL, element.id).then((_) {
                        print("UNLIKING++++++++++++++");
                        setState(() {
                          billHeartMap.update(element, (_) => false);
                          billBrokenHeartMap.update(element, (_) => true);
                        });
                        Future.delayed(Duration(seconds: 2)).then((_) {
                          setState(() {
                            //showBrokenHeart = false;
                            billBrokenHeartMap.update(element, (_) => false);
                          });
                        });
                      });
                    }
                  });
                },
                child: Stack(alignment: Alignment.center, children: [
                  Container(
                    padding: EdgeInsets.all(2.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Container(
                                padding: EdgeInsets.all(5.0),
                                child: Text(element.title.toUpperCase(),
                                    style: TextStyle(
                                      color: Color.fromARGB(166, 166, 166, 166),
                                    )),
                              ),
                              Container(
                                padding: EdgeInsets.all(5.0),
                                child: Text(
                                  element.sponsor.toUpperCase() +
                                      " " +
                                      element.sponsorParty +
                                      "-" +
                                      element.sponsorState,
                                  style: TextStyle(
                                    color: getPartyColor(element.sponsorParty),
                                  ),
                                ),
                              ),
                            ]),
                        Container(
                          padding: EdgeInsets.all(5.0),
                          child: Text(
                            element.description,
                            maxLines: 4,
                            overflow: TextOverflow.ellipsis,
                            textScaleFactor: 1.1,
                          ),
                        ),
                        Container(
                          padding: EdgeInsets.all(5.0),
                          child: Text(
                            element.action.toUpperCase(),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              color: Color.fromARGB(166, 166, 166, 166),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  billHeartMap[element]
                      ? Positioned(
                    child: Opacity(
                      opacity: 0.85,
                      child: Icon(
                        Icons.favorite,
                        size: 80.0,
                      ),
                    ),
                  )
                      : Container(),
                  billBrokenHeartMap[element]
                      ? Positioned(
                    child: Opacity(
                      opacity: 0.85,
                      child: Icon(
                        Icons.favorite_border,
                        size: 80.0,
                      ),
                    ),
                  )
                      : Container()
                ]),
              ),
            ))
        .toList();

    return Container(
      child: Column(children: [
        Row(mainAxisAlignment: MainAxisAlignment.center, children: [
          Container(
            padding: EdgeInsets.all(10.0),
            child: Text(
              widget.topic,
              textScaleFactor: 1.6,
            ),
          ),
        ]),
        Container(
          width: MediaQuery.of(context).size.width * 0.97,
          //color: Color.fromRGBO(88, 88, 88, 100),
          padding: EdgeInsets.all(2.0),
          child: Column(
            children: <Widget>[
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Text(
                    "Recent News",
                    textScaleFactor: 1.2,
                    style: TextStyle(
                        color: Color.fromARGB(166, 166, 166, 166),
                        fontWeight: FontWeight.bold),
                  )
                ],
              ),
              Column(
                children: newsCards,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Text(
                    "Congress",
                    textScaleFactor: 1.2,
                    style: TextStyle(
                        color: Color.fromARGB(166, 166, 166, 166),
                        fontWeight: FontWeight.bold),
                  )
                ],
              ),
              Column(
                children: billCards,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Text(
                    blankIfEmpty(),
                    textScaleFactor: 1.2,
                    style: TextStyle(
                        color: Color.fromARGB(166, 166, 166, 166),
                        fontWeight: FontWeight.bold),
                  )
                ],
              ),
              Column(
                children: tweetCards,
              )
            ],
          ),
        ),
      ]),
    );
  }
}
//    List<Widget> newsCards = news
//        .map((element) => Card(
//              child: Container(
//                padding: EdgeInsets.all(10.0),
//                child: Row(
//                  mainAxisAlignment: MainAxisAlignment.start,
//                  children: <Widget>[
//                    Container(
//                      padding: EdgeInsets.all(5.0),
//                      child: Column(
//                        crossAxisAlignment: CrossAxisAlignment.start,
//                        mainAxisAlignment: MainAxisAlignment.center,
//                        children: <Widget>[
//                          Row(
//                            mainAxisAlignment: MainAxisAlignment.start,
//                            children: <Widget>[
//                              Text(
//                                  element.provider.toUpperCase() +
//                                      "    " +
//                                      cleanDate(element.date),
//                                  style: TextStyle(
//                                    color: Color.fromARGB(166, 166, 166, 166),
//                                  ))
//                            ],
//                          ),
//                          Text(
//                            "",
//                            textScaleFactor: 0.3,
//                          ),
//                          Container(
//                            width: MediaQuery.of(context).size.width * 0.6,
//                            height:
//                                MediaQuery.of(context).size.width * 0.65 / 4,
//                            child: Text(
//                              element.description.replaceAll("<b>", "").replaceAll("</b>", ""),
//                              textScaleFactor: 1.1,
//                            ),
//                          ),
//                        ],
//                      ),
//                    ),
//                    Image(
//                      image: NetworkImage(element.image),
//                      fit: BoxFit.cover,
//                      width: MediaQuery.of(context).size.width * 0.2,
//                      height: 80,
//                    ),
//                  ],
//                ),
//              ),
//            ))
//        .toList();
