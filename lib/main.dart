import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'dart:async';
import 'dart:math';
import 'package:audioplayers/audioplayers.dart';
import 'package:path_provider/path_provider.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'dart:io';
import 'package:flare_flutter/flare_actor.dart';
import 'package:flutter/services.dart';

class Mgr {
  AudioPlayer ap = AudioPlayer();
  Future playLocal(name) async {
    final dir = await getApplicationDocumentsDirectory();
    final file = File("${dir.path}/$name");
    if (!(await file.exists())) {
      final data = await rootBundle.load("assets/$name");
      final bytes = data.buffer.asUint8List();
      await file.writeAsBytes(bytes, flush: true);
    }
    await ap.play(file.path, isLocal: true);
  }
}

void main() {
  SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp])
      .then((_) {
    runApp(new MyApp());
  });
}

class MyApp extends StatefulWidget {
  HomePage createState() => HomePage();
}

class HomePage extends State<MyApp> {
  Timer timer;
  int bug, score, fly, fly2, press, time;
  Random rnd = Random();
  Mgr punch = Mgr();
  Mgr loop = Mgr();

  @override
  void initState() {
    super.initState();
    _set();
    loop.ap.setReleaseMode(ReleaseMode.LOOP);
    loop.playLocal("loop.mp3");
  }

  void _set() {
    bug = 0;
    score = 0;
    fly = 9;
    fly2 = 8;
    press = -1;
    time = 31;
  }

  void start() {
    timer = Timer.periodic(Duration(seconds: 1), (timer) {
      if (time > 0) {
        setState(() {
          time = time - 1;
          bug = rnd.nextInt(9 - 0);
          if (bug > 0) {
            fly = rnd.nextInt(bug - 0);
            if (fly > 0) {
              if (rnd.nextInt(fly - 0) != bug) {
                fly2 = rnd.nextInt(fly - 0);
              }
            }
          }
          press = -1;
        });
      }
    });
  }

  Widget bar() {
    return AppBar(
        centerTitle: true, title: Text("BUGZ"), backgroundColor: Colors.black);
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(fontFamily: 'wild'),
      home: Scaffold(
        appBar: bar(),
        body: stack(
          [pos(flr("assets/lake.flr")), pos(res())],
        ),
      ),
    );
  }

  Widget pos(wid) {
    return Positioned.fill(child: wid);
  }

  Widget stack(wid) {
    return Stack(children: wid);
  }

  Widget col(wid) {
    return Column(mainAxisAlignment: MainAxisAlignment.center, children: wid);
  }

  Widget res() {
    if (time == 31) {
      return col([ply(start)]);
    } else if (time > 0) {
      return col([
        SizedBox(
          width: double.infinity,
          child: Card(elevation: 0.1, child: left(), color: Colors.transparent),
        ),
        Padding(padding: EdgeInsets.all(30)),
        Expanded(child: box())
      ]);
    } else {
      return col([str("Score : " + score.toString()), ply(_set)]);
    }
  }

  Widget left() {
    return col(
      [
        str("Score : " + score.toString()),
        str("Time Left : " + time.toString())
      ],
    );
  }

  Widget str(text) {
    return Text(text, style: TextStyle(color: Colors.white, fontSize: 30));
  }

  Widget ply(func) {
    return IconButton(
        iconSize: 150,
        color: Colors.orangeAccent.withOpacity(0.6),
        icon: Icon(Icons.play_circle_outline),
        onPressed: func);
  }

  Widget card(index) {
    if (bug == index) {
      if (press == index) {
        return img("spark.gif");
      } else {
        return img("bug.gif");
      }
    } else if (fly == index) {
      return chk(press, index);
    } else if (fly2 == index) {
      return chk(press, index);
    } else {
      if (press == index) {
        return flr("assets/sub.flr");
      } else {
        return img("leaf.gif");
      }
    }
  }

  Widget chk(press, index) {
    if (press == index) {
      return flr("assets/sub.flr");
    } else {
      return img("fly.gif");
    }
  }

  Widget img(name) {
    return Image(image: AssetImage("assets/" + name));
  }

  Widget flr(text) {
    return FlareActor(text, animation: "float");
  }

  void update(index) {
    if (index == bug) {
      punch.playLocal("punch.mp3").then((onValue) {
        setState(() {
          press = index;
          score += 1;
        });
      });
    } else {
      punch.playLocal("low.mp3").then((onValue) {
        setState(() {
          press = index;
          if (score > 0) {
            score -= 1;
          }
        });
      });
    }
  }

  Widget box() {
    return GridView.builder(
        itemCount: 9,
        gridDelegate:
            SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 3),
        itemBuilder: (BuildContext context, int index) {
          return GestureDetector(
            child: card(index),
            onTap: () {
              update(index);
            },
          );
        });
  }
}
