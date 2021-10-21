import 'dart:async';
import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_glow/flutter_glow.dart';
import 'package:glowyball/barrier.dart';
import 'package:particles_flutter/particles_flutter.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  // Ball variables
  static double ballY = 0;
  double initialPos = ballY;
  double height = 0;
  double time = 0;
  double gravity = -6; // how strong the gravity is bruh
  double velocity = 3; // how strong the jump is
  double ballWidth = 0.1;
  double ballHeight = 0.1;

  // Game Settings
  bool gameHasStarted = false;
  int score = 0;
  int highScore = 0;

  // Barrier Variables
  static List<double> barrierX = [2, 2+1.5, 2+3];
  static double barrierWidth = 0.5; // out of 2
  List<List<double>> barrierHeight = [
    // out of 2, where 2 is the entire height of the screen
    // [topHeight, bottomHeight]
    [0.7, 0.0], //SURE
    [0.5, 0.9], //SURE (2nd barrier)
    [1.0, 0.3], //SURE
    [0.6, 0.4], //SURE
    //[1.1, 0.5],
    //[0,4, 0.5]
  ];

  bool barrierScored0 = false;
  bool barrierScored1 = false;
  bool barrierScored2 = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: gameHasStarted ? jump : startGame,
      child: Scaffold(
        body: Column(
          children: [
            Expanded(
              flex: 10,
              child: Container(
                decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [Colors.deepPurple, Colors.black,],
                    )
                ),
                child: Stack(
                  children: [
                    /// Background Stuff
                    //particles(),
                    /// Player Stuff
                    Center(child:
                    Stack(
                      children: [
                        playerAvatar(),
                        barrier1(),
                        barrier2(),
                        barrier3(),
                        tapToPlay(),
                      ],
                    )),
                  ],
                )
              )
            ),
            Expanded(
                flex: 2,
                child: Container(
                  decoration: const BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [Colors.pink, Colors.indigo,],
                      )
                  ),
                ),
            ),

          ],
        ),
      ),
    );
  }

  // Custom Widgets
  Widget playerAvatar() {
    return Container(
      alignment: Alignment(0, ballY),
      child: GlowContainer(
        glowColor: Colors.green,
        width: MediaQuery.of(context).size.height * ballWidth / 1.5,
        height: MediaQuery.of(context).size.height * 3 / 4 * ballHeight / 1.5,
        color: Colors.cyan,
        shape: BoxShape.circle,
      ),
    );
  }
  Widget barrier1() {
    return Stack(
      children: [
        Barrier(
          barrierX: barrierX[0],
          barrierWidth: barrierWidth,
          barrierHeight: barrierHeight[0][0],
          isThisBottomBarrier: false,
        ),
        // Bottom Barrier 0
        Barrier(
          barrierX: barrierX[0],
          barrierWidth: barrierWidth,
          barrierHeight: barrierHeight[0][0],
          isThisBottomBarrier: true,
        ),
      ],
    );
  }
  Widget barrier2() {
    return Stack(
      children: [
        Barrier(
          barrierX: barrierX[1],
          barrierWidth: barrierWidth,
          barrierHeight: barrierHeight[1][0],
          isThisBottomBarrier: false,
        ),
        // Bottom Barrier 1
        Barrier(
          barrierX: barrierX[1],
          barrierWidth: barrierWidth,
          barrierHeight: barrierHeight[1][1],
          isThisBottomBarrier: true,
        ),
      ],
    );
  }
  Widget barrier3() {
    return Stack(
      children: [
        Barrier(
          barrierX: barrierX[2],
          barrierWidth: barrierWidth,
          barrierHeight: barrierHeight[2][0],
          isThisBottomBarrier: false,
        ),
        // Bottom Barrier 1
        Barrier(
          barrierX: barrierX[2],
          barrierWidth: barrierWidth,
          barrierHeight: barrierHeight[2][1],
          isThisBottomBarrier: true,
        ),
      ],
    );
  }

  Widget tapToPlay() {
    return Container(
      alignment: const Alignment(0, -0.5),
      child: GlowText(
        gameHasStarted ? '$score' : 'Glowy Ball',
        glowColor: Colors.cyan,
        style: const TextStyle(
            color: Colors.cyan,
            fontSize: 35
        ),),
    );
  }

  // Game Functions
  void startGame() {
    gameHasStarted = true;
    score = 0;
    Timer.periodic(const Duration(milliseconds: 50), (timer) async {
      // Upside down parabola
      // Simple quadratic equation
      height = gravity * time * time + velocity * time;

      setState((){
        ballY = initialPos - height;
      });

      // Check if ball is ded
      if (ballIsDead()) {
        timer.cancel();
        _showDialog();
      }

      if(!barrierScored0){
        if(barrierX[0] <= 0.03){
          setState(() {
            score++;
            barrierScored0 = true;
          });
        }
      }
      if(!barrierScored1){
        if(barrierX[1] <= 0.03){
          setState(() {
            score++;
            barrierScored1 = true;
          });
        }
      }
      if(!barrierScored2){
        if(barrierX[2] <= 0.03){
          setState(() {
            score++;
            barrierScored2 = true;
          });
        }
      }

      // Keep the Map Moving (move barriers)
      moveMap();

      // Keep the time going
      time += 0.035;
    });
  }
  void moveMap() {
    for (int i = 0; i < barrierX.length; i++){
      // Keep barriers moving
      setState((){
        barrierX[i] -= 0.08;
      });

      // If the barrier exits the screen, keep it looping
      if (barrierX[i] <= -1.5){
        barrierX[i] += 4.5;
        setState(() {
          if (i==0) barrierScored0 = false;
          if (i==1) barrierScored1 = false;
          if (i==2) barrierScored2 = false;
        });
      }
    }
  }
  void jump() {
    setState((){
      time = 0;
      initialPos = ballY;
    });
  }
  void _showDialog() {
    showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return AlertDialog(
            backgroundColor: Colors.cyan,
            title: const Center(child:GlowText("C O L L I D E D",
                glowColor: Colors.white,
                style: TextStyle(
                    color: Colors.white,
                    fontSize: 30)),
            ),
            actions: [
              GestureDetector(
                onTap: resetGame,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(5),
                  child: Container(
                    padding: const EdgeInsets.all(7),
                    color: Colors.white,
                    child: const Text('AGAIN'),
                  ),
                ),
              )
            ],
          );
        }
    );
  }
  void resetGame() {
    Navigator.pop(context); // dismiss the alert dialog
    setState(() {
      ballY = 0;
      gameHasStarted = false;
      time = 0;
      initialPos = ballY;
      barrierX = [2, 2+1.5, 2+3];
      barrierScored0 = false;
      barrierScored1 = false;
      barrierScored2 = false;
    });
  }

  bool ballIsDead() {
    // Check if the ball is hitting the top or the bottom of the screen
    if (ballY < -1 || ballY > 1){
      return true;
    }
    // Barrier hitting
    // Check if the ball is within X and Y coordinates of barriers
    for (int i = 0; i < barrierX.length; i++) {
      if (barrierX[i] <= ballWidth &&
          barrierX[i] + barrierWidth >= -ballWidth &&
          (ballY <= -1 + barrierHeight[i][0] ||
              ballY + ballHeight >= 1 - barrierHeight[i][1])) {
        return true;
      }
    }

    return false;
  }

}
