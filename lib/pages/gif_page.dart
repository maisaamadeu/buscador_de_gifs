import 'package:flutter/material.dart';
import 'package:share/share.dart';

class GifPage extends StatelessWidget {
  const GifPage({super.key, required this.gifData});

  final Map gifData;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: Text(gifData["title"]),
        backgroundColor: Colors.black,
        centerTitle: true,
        actions: [
          IconButton(
            onPressed: () {
              Share.share(
                  'Hey, olhei esse GIF e pensei em você!\nLink: ${gifData["images"]["fixed_height"]["url"]} ');
            },
            icon: Icon(Icons.share),
          ),
        ],
      ),
      body: Center(
        child: ClipRRect(
          borderRadius: BorderRadius.circular(20),
          child: Image.network(gifData["images"]["fixed_height"]["url"]),
        ),
      ),
    );
  }
}
