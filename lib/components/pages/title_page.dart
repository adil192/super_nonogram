import 'package:flutter/material.dart';

class TitlePage extends StatelessWidget {
  const TitlePage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Scaffold(
      body: ColoredBox(
        color: colorScheme.primary,
        child: Center(
          child: LayoutBuilder(
            builder: (context, constraints) {
              return Text(
                "Super Nonogram",
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: switch (constraints.maxWidth) {
                    < 400 => 24,
                    < 600 => 36,
                    _ => 48,
                  },
                  color: colorScheme.onPrimary,
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}
