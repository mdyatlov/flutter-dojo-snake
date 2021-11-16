import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key}) : super(key: key);

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

const numberOfCubeInWidth = 20;

class _MyHomePageState extends State<MyHomePage> {
  static List<int> snakePosition = [45, 65, 85, 105, 125];
  int food = Random().nextInt(700);
  var duration = const Duration(milliseconds: 300);

  late final width = MediaQuery.of(context).size.width;
  late final cubeSize = width / numberOfCubeInWidth;
  late final numberOfCubeInHeight =
      (MediaQuery.of(context).size.height / cubeSize).round() - 10;

  late final totalNumberOfCube = numberOfCubeInHeight * numberOfCubeInWidth;

  late Timer currentTimer;

  Timer initTimer() {
    return Timer.periodic(duration, (Timer timer) {
      updateSnake();
      if (gameOver()) {
        timer.cancel();
        _showGameOverPopup();
      }
    });
  }

  var direction = 'down';

  void generateNextFood() {
    food = Random().nextInt(totalNumberOfCube);
  }

  void startGame() {
    snakePosition = [45, 65, 85, 105, 125];
    duration = const Duration(milliseconds: 300);
    currentTimer = initTimer();
    createNewTimer();
  }

  createNewTimer() {
    currentTimer.cancel();
    currentTimer = Timer.periodic(duration, (Timer timer) {
      updateSnake();
      if (gameOver()) {
        timer.cancel();
        _showGameOverPopup();
      }
    });
  }

  increaseSpeed() {
    if (duration.inMilliseconds != 50) {
      duration = Duration(milliseconds: duration.inMilliseconds - 25);
      createNewTimer();
    }
  }

  bool gameOver() {
    for (int i = 0; i < snakePosition.length; i++) {
      int count = 0;
      for (int j = 0; j < snakePosition.length; j++) {
        if (snakePosition[i] == snakePosition[j]) {
          count++;
        }
        if (count == 2) {
          return true;
        }
      }
    }

    return false;
  }

  void _showGameOverPopup() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('GAME OVER'),
          content: Text('You\'re score: ' + snakePosition.length.toString()),
          actions: <Widget>[
            TextButton(
              child: const Text('Play again !'),
              onPressed: () {
                startGame();
                Navigator.of(context).pop();
              },
            )
          ],
        );
      },
    );
  }

  void updateSnake() {
    setState(() {
      switch (direction) {
        case 'down':
          if (snakePosition.last > totalNumberOfCube - numberOfCubeInWidth) {
            snakePosition.add(snakePosition.last + numberOfCubeInWidth - totalNumberOfCube);
          } else {
            snakePosition.add(snakePosition.last + numberOfCubeInWidth);
          }
          break;
        case 'up':
          if (snakePosition.last < numberOfCubeInWidth) {
            snakePosition.add(snakePosition.last - numberOfCubeInWidth + totalNumberOfCube);
          } else {
            snakePosition.add(snakePosition.last - numberOfCubeInWidth);
          }
          break;
        case 'left':
          if (snakePosition.last % numberOfCubeInWidth == 0) {
            snakePosition.add(snakePosition.last - 1 + numberOfCubeInWidth);
          } else {
            snakePosition.add(snakePosition.last - 1);
          }
          break;
        case 'right':
          if ((snakePosition.last + 1) % numberOfCubeInWidth == 0) {
            snakePosition.add(snakePosition.last + 1 - numberOfCubeInWidth);
          } else {
            snakePosition.add(snakePosition.last + 1);
          }
          break;
      }

      if (snakePosition.last == food) {
        generateNextFood();
        increaseSpeed();
      } else {
        snakePosition.removeAt(0);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Column(
        children: <Widget>[
          Expanded(
            child: GestureDetector(
              onVerticalDragUpdate: (details) {
                if (direction != 'up' && details.delta.dy > 0) {
                  direction = 'down';
                } else if (direction != 'down' && details.delta.dy < 0) {
                  direction = 'up';
                }
              },
              onHorizontalDragUpdate: (details) {
                if (direction != 'left' && details.delta.dx > 0) {
                  direction = 'right';
                } else if (direction != 'right' && details.delta.dx < 0) {
                  direction = 'left';
                }
              },
              child: GridView.builder(
                physics: const NeverScrollableScrollPhysics(),
                itemCount: totalNumberOfCube,
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: numberOfCubeInWidth,
                ),
                itemBuilder: (BuildContext context, int index) {
                  if (snakePosition.contains(index)) {
                    return Container(
                      padding: const EdgeInsets.all(2),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(5),
                        child: Container(color: Colors.white),
                      ),
                    );
                  } else if (index == food) {
                    return Container(
                      padding: const EdgeInsets.all(2),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(5),
                        child: Container(color: Colors.green),
                      ),
                    );
                  } else {
                    return Container(
                      padding: const EdgeInsets.all(2),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(5),
                        child: Container(color: Colors.grey[900]),
                      ),
                    );
                  }
                },
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(bottom: 40.0, top: 20.0),
            child: Center(
              child: GestureDetector(
                onTap: startGame,
                child: const Text(
                  'START',
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ),
          )
        ],
      ),
    );
  }
}
