import 'package:flutter/material.dart';
import 'package:flutter_glow/flutter_glow.dart';

class Barrier extends StatelessWidget {
  const Barrier({
    Key? key,
    this.barrierWidth,
    this.barrierHeight,
    this.barrierX,
    required this.isThisBottomBarrier
  }) : super(key: key);

  final barrierWidth;
  final barrierHeight;
  final barrierX;
  final bool isThisBottomBarrier;

  @override
  Widget build(BuildContext context) {
    return Container(
      alignment: Alignment((2 * barrierX + barrierWidth) / (2 - barrierWidth),
        isThisBottomBarrier ? 1 : -1),
      child: GlowContainer(
        color: Colors.pink,
        glowColor: Colors.red,
        width: MediaQuery.of(context).size.width * barrierWidth / 2,
        height: MediaQuery.of(context).size.height * 3 / 4 * barrierHeight / 2,
      ),
    );
  }
}
