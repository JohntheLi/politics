import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import './models/poll.dart';
import './models/article.dart';
import './MyInAppBrowser.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:percent_indicator/percent_indicator.dart';

import 'dart:io';

class ProfilePage extends StatelessWidget {
  final double y;
  final double x;
  final List<String> allTopics = [
    "Immigration",
    "Healthcare",
    "Climate",
    "Economy",
    "Education",
    "Guns",
    "Justice",
    "Military",
    "Race Relations",
    "Sex Relations",
    "Technology",
    "Voting Rights"
  ];
  final List<double> percentages = [
    0.6,
    0.43,
    0.73,
    0.435,
    0.344,
    0.674,
    0.2342,
    0.787,
    0.67567,
    0.5675,
    0.8546,
    0.4563
  ];
  ProfilePage(this.y, this.x);

  Future<String> get _localPath async {
    final directory = await getApplicationDocumentsDirectory();
    return directory.path;
  }

  Future<String> getVals() {
    return _localPath.then((path) {
      File f = File('$path/userPoliticalSides.txt');
      return f.readAsStringSync();
    });
  }

  @override
  Widget build(BuildContext context) {
    return ListView(
      children: <Widget>[
        Container(
          padding: EdgeInsets.all(10.0),
          width: MediaQuery.of(context).size.width * 0.95,
          child: Text(
            "Your Political Snapshot",
            textAlign: TextAlign.center,
            textScaleFactor: 1.6,
          ),
        ),
        Stack(children: [
          Container(
            width: MediaQuery.of(context).size.width * 0.98,
            child: Image.asset('assets/political_snapshot.png'),
          ),
          Positioned(
              child: Icon(
                Icons.star,
                color: Colors.amberAccent,
              ),
              left: (MediaQuery.of(context).size.width * 0.98 * 0.083) +
                  (MediaQuery.of(context).size.width * 0.98 * 0.83 * (x / 10)),
              top: (MediaQuery.of(context).size.width *
                  0.7 *
                  ((10 - y) /
                      10)) //(MediaQuery.of(context).size.width * 0.98 * 0.78 * ((1 - y) / 10)) + 50,
              ),
        ]),
        Container(
          height: 30,
        ),
        CircularPercentIndicator(
          radius: 160,
          lineWidth: 5.0,
          percent: 0.8,
          animation: true,
          animationDuration: 1200,
          center: Container(
              width: 220,
              child: Text(
                "80% of your liked items are Democratic",
                textAlign: TextAlign.center,
              )),
          progressColor: Color.fromARGB(255, 55, 171, 180),
          backgroundColor: Color.fromARGB(255, 244, 158, 137),
        ),
        Container(
          padding: EdgeInsets.all(10.0),
          width: MediaQuery.of(context).size.width * 0.9,
          child: Text(
            "Your stances",
            textAlign: TextAlign.center,
            textScaleFactor: 1.6,
          ),
        ),
        Container(
          width: MediaQuery.of(context).size.width * 0.9,
          child: ListView.builder(
            scrollDirection: Axis.vertical,
            shrinkWrap: true,
            itemCount: 12,
            itemBuilder: (context, index) {
              return Column(
                children: <Widget>[
                  Container(
                    padding: EdgeInsets.all(5.0),
                    child: Text(allTopics[index]),
                  ),
                  Row(
                    children: [
                      LinearPercentIndicator(
                        width: MediaQuery.of(context).size.width * 0.8,
                        lineHeight: 14.0,
                        percent: percentages[index],
                        animation: true,
                        animationDuration: 1200,
                        backgroundColor: Color.fromARGB(255, 244, 158, 137),
                        progressColor: Color.fromARGB(255, 55, 171, 180),
                      ),
                    ],
                    mainAxisAlignment: MainAxisAlignment.center,
                  ),
                ],
              );
            },
          ),
        )
      ],
    );
  }
}
