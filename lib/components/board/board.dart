import 'dart:math';

import 'package:flutter/material.dart';

class Board extends StatefulWidget {
  const Board({super.key});

  @override
  State<Board> createState() => _BoardState();
}

class _BoardState extends State<Board> {
  static const width = 10;
  static const height = 10;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return FittedBox(
      child: SizedBox(
        width: 50.0 * width,
        height: 50.0 * height,
        child: GridView.builder(
          itemCount: width * height,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: width,
            mainAxisSpacing: 10,
            crossAxisSpacing: 10,
          ),
          padding: const EdgeInsets.all(20),
          itemBuilder: (context, index) => Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
              color: colorScheme.primary,
            ),
          ),
        ),
      ),
    );
  }
}
