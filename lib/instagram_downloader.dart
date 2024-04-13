import 'dart:developer';

import 'package:direct_link/direct_link.dart';
import 'package:flutter/material.dart';




class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: onPressed,
        tooltip: 'Check',
        child: const Icon(Icons.add),
      ),
    );
  }

  Future<void> onPressed() async {
    var directLink = DirectLink();

    var url = 'https://fb.watch/r6FBtx6AWV/';

    var model = await directLink.check(url);

    if (model == null) {
      return log('model is null');
    }

    log('title: ${model.title}');
    log('thumbnail: ${model.thumbnail}');
    log('duration: ${model.duration}');
    for (var e in model.links!) {
      log('type: ${e.type}');
      log('quality: ${e.quality}');
      log('link: ${e.link}');
    }
  }
}