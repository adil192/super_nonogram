import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class TitlePage extends StatelessWidget {
  const TitlePage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final mediaQuery = MediaQuery.of(context);

    final double titleFontSize;
    final double buttonFontSize;
    switch (mediaQuery.size.width) {
      case < 400:
        titleFontSize = 24;
        buttonFontSize = 16;
        break;
      case < 600:
        titleFontSize = 36;
        buttonFontSize = 24;
        break;
      default:
        titleFontSize = 48;
        buttonFontSize = 32;
    }

    return Scaffold(
      body: ColoredBox(
        color: colorScheme.primary,
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Hero(
                tag: 'title',
                child: Text(
                  "Super Nonogram",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: titleFontSize,
                    color: colorScheme.onPrimary,
                  ),
                ),
              ),
              const SizedBox(height: 64),
              ElevatedButton(
                onPressed: () {
                  GoRouter.of(context).push("/play");
                },
                child: Padding(
                  padding: EdgeInsets.all(buttonFontSize / 2),
                  child: Text(
                    "Play",
                    style: TextStyle(
                      fontSize: buttonFontSize,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
