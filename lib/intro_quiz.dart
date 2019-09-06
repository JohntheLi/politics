import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';

import './module_manager.dart';
import 'package:flutter_swiper/flutter_swiper.dart';

import 'dart:io';

class IntroQuiz extends StatefulWidget {
  @override
  IntroQuizState createState() => IntroQuizState();
}

class IntroQuizState extends State<IntroQuiz> {
  List<String> topics = [
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
  List<String> questions = [
    "Improving immigrant screening is better than restricting it.",
    "A taxpayer supported public healthcare system needs to be provided to people without health insurance.",
    "We have to protect environment with stricter pollution laws.",
    "Economy will be made better with a government stimulus package versus across the board tax cuts.",
    "There is nothing wrong with school organized prayer",
    "There should be more restrictions on the current process of owning a gun.",
    "People in drug related crimes should serve jail time.",
    "The United States should continue drone strikes on suspected terrorist leaders.",
    "Affirmative action programs have been beneficial and should be continued.",
    "Abortion policy should be more strict (pro-life)",
    "It is wrong to use human embryos for scientific research experiments",
    "We should ban corporate donations to political campaigns"
  ];
  List<String> questions2 = [
    "There should be a wall along the southern border.",
    "The government should regulate drug prices.",
    "The best way to solve energy crisis is conservation.",
    "Companies should be able to build plants outside the U.S. only if it does not replace workers here.",
    "There should be more taxes on the rich to reduce student loan interest.",
    "Guns don't kill people, people kill people.",
    "Police officers should be required to wear body cameras.",
    "The president should be able to authorize attacks on terrorist organizations without congressional approval.",
    "Racial discrimination is the main reason why many minorities can't get ahead these days.",
    "Same sex couples should not be able to adopt children.",
    "Internet service providers should be able to rate-limit specific websites based on popularity.",
    "The electoral college should be abolished."
  ];

  List<double> sv = List.filled(12, 5.0);
  List<double> sv2 = List.filled(12, 5.0);

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      appBar: new AppBar(
        title: new Text("Political Quiz"),
      ),
      body: new Swiper(
        itemBuilder: _buildQuizPage,
        itemCount: 14,
        loop: false,
        pagination: new SwiperPagination(),
        control: new SwiperControl(),
      ),
    );
  }

  Future<String> get _localPath async {
    final directory = await getApplicationDocumentsDirectory();
    return directory.path;
  }

  Widget _buildQuizPage(BuildContext context, int index) {
    if (index == 0) {
      return Center(
        child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
          Container(
            padding: EdgeInsets.all(5.0),
            width: MediaQuery.of(context).size.width * 0.9,
            child: Text(
              "What is your political typology?",
              textScaleFactor: 1.8,
            ),
          ),
          Container(
            height: MediaQuery.of(context).size.height * 0.1,
          ),
          Container(
            padding: EdgeInsets.all(5.0),
            width: MediaQuery.of(context).size.width * 0.9,
            child: Text(
                "Swipe left to begin taking the political snapshot quiz. Use the sliders to"
                " indicate how much you agree or disagree with the statements. Your "
                "answers are saved locally and are completely private.",
              textAlign: TextAlign.center,
            ),
          ),
          Container(
            height: MediaQuery.of(context).size.height * 0.1,
          ),
          Container(
            width: MediaQuery.of(context).size.width * 0.9,
            child: Column(
              children: <Widget>[
                Text(
                  "Or, press this button to skip the quiz (some personalization features may not work!)",
                  textAlign: TextAlign.center,
                ),
                FlatButton(
                  child: Text("Skip Quiz"),
                  color: Color.fromARGB(255, 101, 101, 101),
                  onPressed: (){
                    _localPath.then((path){
                      File f = File('$path/userPoliticalSides.txt');
                      f.writeAsString(5.toString() + ", " + 5.toString());
                      Navigator.of(context).pushReplacement(
                          new MaterialPageRoute(builder: (context) => new ModuleManager()));
                    });
                  },
                )
              ],
            ),
          ),
        ]),
      );
    }
    if (index == 13) {
      return Center(
        child: Container(
          child: FlatButton(
            color: Color.fromARGB(255, 101, 101, 101),
            child: Text("Get my political snapshot"),
            onPressed: (){
              _localPath.then((path){
                File f = File('$path/userPoliticalSides.txt');
                double econ = sv[0] + (10 - sv2[0]) + sv[1] + (10 - sv2[1]) +
                    sv[2] + sv[3] + (10 - sv2[3]) + sv2[4] + (10 - sv[7]) + sv2[8] + sv[11];
                econ /= 11;
                double social = (10 - sv2[2]) + (10 - sv[4]) + sv[5] + (10 - sv2[5]) +
                    (10- sv[6]) + sv2[6] + (10 - sv2[7]) + sv[8] + (10 - sv[9]) +
                    (10 - sv2[9]) + (10 - sv[10]) + (10 - sv2[10]) + sv2[11];
                social /= 13;
                f.writeAsString(econ.toString() + ", " + social.toString());
                print("ECON: " + econ.toString() + ", SOCIAL: " + social.toString());
                Navigator.of(context).pushReplacement(
                    new MaterialPageRoute(builder: (context) => new ModuleManager()));
              });
            },
          ),
        ),
      );
    }
    return new Container(
      padding: EdgeInsets.all(5.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Column(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: <Widget>[
              Container(
                child: Text(
                  topics[index - 1] + " (" + (index).toString() + "/12)",
                  textScaleFactor: 1.8,
                ),
              ),
              Column(
                children: <Widget>[
                  Container(
                    padding: EdgeInsets.all(5.0),
                    width: MediaQuery.of(context).size.width * 0.9,
                    child: Text(
                      questions[index - 1],
                      textAlign: TextAlign.center,
                      maxLines: 3,
                    ),
                  ),
                  Row(
                    children: <Widget>[
                      Container(child: Text("Disagree")),
                      Slider(
                        min: 0,
                        max: 10,
                        divisions: 4,
                        value: sv[index - 1],
                        onChanged: (newVal) {
                          setState(() => sv[index - 1] = newVal);
                        },
                      ),
                      Container(
                        child: Text("Agree"),
                      )
                    ],
                  ),
                  Container(
                    height: 7.0,
                  ),
                  Container(
                    padding: EdgeInsets.all(5.0),
                    width: MediaQuery.of(context).size.width * 0.9,
                    child: Text(
                      questions2[index - 1],
                      textAlign: TextAlign.center,
                      maxLines: 3,
                    ),
                  ),
                  Row(
                    children: <Widget>[
                      Container(child: Text("Disagree")),
                      Slider(
                        min: 0,
                        max: 10,
                        divisions: 4,
                        value: sv2[index - 1],
                        onChanged: (newVal) {
                          setState(() => sv2[index - 1] = newVal);
                        },
                      ),
                      Container(
                        child: Text("Agree"),
                      )
                    ],
                  ),
                ],
              ),
              Container(
                child: Text("<<< Swipe to continue or go back >>>"),
              )
            ],
          )
        ],
      ),
    );
  }
}
