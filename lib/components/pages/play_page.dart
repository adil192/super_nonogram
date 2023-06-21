import 'package:flutter/material.dart';

class PlayPage extends StatefulWidget {
  const PlayPage({super.key});

  @override
  State<PlayPage> createState() => _PlayPageState();
}
class _PlayPageState extends State<PlayPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Hero(
          tag: 'title',
          child: Text('Super Nonogram'),
        ),
        actions: [
          IconButton(
            onPressed: () {},
            icon: const Icon(Icons.settings),
          ),
        ],
      ),
      body: const Center(
        child: Text('Play'),
      ),
    );
  }
}
