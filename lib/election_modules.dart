import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import './models/poll.dart';
import './models/article.dart';
import './MyInAppBrowser.dart';

import 'dart:io';

/*
This contains formatting for elections tab
 */
class ElectionModules extends StatefulWidget {
  final List<Article> news;
  final List<Poll> polls;

  ElectionModules(this.news, this.polls);

  @override
  _ElectionModulesState createState() => _ElectionModulesState();
}

class _ElectionModulesState extends State<ElectionModules> {
  final String topic = "2020 Presidential Election";

  final List<String> reps = ["Trump", "Weld"];

  final List<String> dems = [
    "Bennet",
    "Biden",
    "Blasio",
    "de Blasio",
    "Booker",
    "Bullock",
    "Buttigieg",
    "Castro",
    "Delaney",
    "Gabbard",
    "Gillibrand",
    "Harris",
    "Klobuchar",
    "Messam",
    "O'Rourke",
    "Ryan",
    "Sanders",
    "Sestak",
    "Steyer",
    "Warren",
    "Williamson",
    "Yang"
  ];

  Map<Article, bool> articleHeartMap;
  Map<Article, bool> articleBrokenHeartMap;

  MyInAppBrowser inAppBrowser = new MyInAppBrowser();

  Future<String> get _localPath async {
    final directory = await getApplicationDocumentsDirectory();
    return directory.path;
  }

  @override
  void initState() {
    List<bool> tempBoolList = List.filled(widget.news.length, false);
    articleHeartMap = Map.fromIterables(widget.news, tempBoolList);
    articleBrokenHeartMap = Map.fromIterables(widget.news, tempBoolList);
    super.initState();
  }

  Future<bool> isLiked(String id) {
    return _localPath.then((path) {
      File f = File('$path/article.txt');
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

  Future<void> unlike(String id) {
    return _localPath.then((path) {
      File f = File('$path/article.txt');
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

  Color getPartyColor(String party) {
    if (party == "dem") {
      return Color.fromARGB(255, 55, 171, 180);
    } else {
      return Color.fromARGB(255, 244, 158, 137);
    }
  }

  Color getPartyColorForCandidate(String candidate) {
    if (candidate == "Trump" || candidate == "Weld") {
      return Color.fromARGB(255, 244, 158, 137);
    } else {
      return Color.fromARGB(255, 55, 171, 180);
    }
  }

  Color getWinningColor(String personResult, String otherResult) {
    var thisInt = int.parse(personResult);
    assert(thisInt is int);
    var otherInt = int.parse(otherResult);
    assert(otherInt is int);
    if (thisInt > otherInt) {
      return Color.fromARGB(255, 212, 158, 74);
    }
    return Colors.white;
  }

  String cleanDate(String longdate) {
    List<String> parts = longdate.split("-");
    return parts[1] + "/" + parts[2].substring(0, 2);
  }

  String getCompositeData(String name, String result) {
    name = name.substring(1, name.length - 1);
    result = result.substring(1, result.length - 1);
    List<String> parts = result.split(", ");
    String person1 = parts[0].split(" ")[0];
    String result1 = parts[0].split(" ")[1];
    String person2 = parts[1].split(" ")[0];
    String result2 = parts[1].split(" ")[1];
    print("Person1: " +
        person1 +
        ", " +
        result1 +
        " Person2: " +
        person2 +
        ", " +
        result2);
    print("Name: " + name);
    //person1 = person1 + " (" + result1 + ")";
    //person2 = person2 + " (" + result2 + ")";
    if (name.indexOf(person1) == -1 || name.indexOf(person2) == -1) {
      return name;
    }
    var lowerIndex = (name.indexOf(person1) < name.indexOf(person2))
        ? name.indexOf(person1)
        : name.indexOf(person2);
    String composite = name.substring(0, lowerIndex) +
        person1 +
        " (" +
        result1 +
        ") vs. " +
        person2 +
        " (" +
        result2 +
        ")";
    return composite;
  }

  String person1(String result) {
    result = result.substring(1, result.length - 1);
    List<String> parts = result.split(", ");
    String person1 = parts[0].split(" ")[0];
    return person1;
  }

  String result1(String result) {
    result = result.substring(1, result.length - 1);
    List<String> parts = result.split(", ");
    String result1 = parts[0].split(" ")[1];
    return result1;
  }

  String person2(String result) {
    result = result.substring(1, result.length - 1);
    List<String> parts = result.split(", ");
    String person2 = parts[1].split(" ")[0];
    return person2;
  }

  String result2(String result) {
    result = result.substring(1, result.length - 1);
    List<String> parts = result.split(", ");
    for (String s in parts) {
      print(result);
      print("Part: " + s);
    }
    String result2 = parts[1].split(" ")[1];
    return result2;
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
                  isLiked(element.id).then((_liked) {
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
                      unlike(element.id).then((_) {
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

    List<Widget> pollsCards = widget.polls
        .map((element) => Card(
              child: Container(
                padding: EdgeInsets.all(2.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        Container(
                          height: 100.0,
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: <Widget>[
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: <Widget>[
                                  Text(
                                    person1(element.data),
                                    textScaleFactor: 1.6,
                                    style: TextStyle(
                                      color: getPartyColorForCandidate(
                                          person1(element.data)),
                                    ),
                                  ),
                                ],
                              ),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: <Widget>[
                                  Text(
                                    result1(element.data),
                                    textScaleFactor: 1.7,
                                    style: TextStyle(
                                        color: getWinningColor(
                                            result1(element.data),
                                            result2(element.data))),
                                  ),
                                ],
                              )
                            ],
                          ),
                        ),
                        Container(
                          height: 80,
                          child: VerticalDivider(
                            color: Color.fromARGB(255, 166, 166, 166),
                          ),
                        ),
                        Container(
                          height: 100.0,
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: <Widget>[
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: <Widget>[
                                  Text(
                                    person2(element.data),
                                    textScaleFactor: 1.6,
                                    style: TextStyle(
                                      color: getPartyColorForCandidate(
                                          person2(element.data)),
                                    ),
                                  ),
                                ],
                              ),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: <Widget>[
                                  Text(
                                    result2(element.data),
                                    textScaleFactor: 1.7,
                                    style: TextStyle(
                                        color: getWinningColor(
                                            result2(element.data),
                                            result1(element.data))),
                                  ),
                                ],
                              )
                            ],
                          ),
                        ),
                      ],
                    ),
                    Container(
                        padding: EdgeInsets.all(2.0),
                        child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                element.name
                                    .substring(1, element.name.length - 1),
                              ),
                            ])),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: <Widget>[
                        Container(
                          padding: EdgeInsets.all(2.0),
                          child: Text(
                            element.source
                                .substring(1, element.source.length - 1),
                            style: TextStyle(
                              color: Color.fromARGB(166, 166, 166, 166),
                            ),
                          ),
                        ),
                        Container(
                          padding: EdgeInsets.all(2.0),
                          child: Text(
                            "Spread: " +
                                element.result
                                    .substring(1, element.result.length - 1),
                            style: TextStyle(
                              color: Color.fromARGB(166, 166, 166, 166),
                            ),
                          ),
                        )
                      ],
                    ),
                  ],
                ),
              ),
            ))
        .toList();

//    List<Widget> pollsCards = polls
//        .map((element) => Card(
//      child: Container(
//        padding: EdgeInsets.all(2.0),
//        child: Column(
//          crossAxisAlignment: CrossAxisAlignment.start,
//          children: <Widget>[
//            Row(
//                mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                children: [
//                  Container(
//                    padding: EdgeInsets.all(5.0),
//                    child: Text(
//                      element.source.substring(1, element.source.length - 1),
//                        style: TextStyle(
//                          color: Color.fromARGB(166, 166, 166, 166),
//                        )
//                    ),
//                  ),
//                  Container(
//                      padding: EdgeInsets.all(5.0),
//                      child: Text(
//                        element.result.substring(1, element.result.length - 1),
//                        style: TextStyle(
//                          color: getPartyColor(element.winnerParty),
//                        ),
//                        //textScaleFactor: 1.2,
//                      ))
//                ]),
//            Container(
//              padding: EdgeInsets.all(5.0),
//              child: Text(getCompositeData(element.name, element.data)),
//            ),
//          ],
//        ),
//      ),
//    ))
//        .toList();

    return Container(
      child: Column(children: [
        Row(mainAxisAlignment: MainAxisAlignment.center, children: [
          Container(
            padding: EdgeInsets.all(10.0),
            child: Text(
              topic,
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
                    "Recent Polls",
                    textScaleFactor: 1.2,
                    style: TextStyle(
                        color: Color.fromARGB(166, 166, 166, 166),
                        fontWeight: FontWeight.bold),
                  )
                ],
              ),
              Column(
                children: pollsCards,
              ),
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
            ],
          ),
        ),
      ]),
    );
  }
}
