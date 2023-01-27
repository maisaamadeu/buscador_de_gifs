// ignore_for_file: import_of_legacy_library_into_null_safe

import 'dart:convert';
import 'package:buscador_de_gifs/pages/gif_page.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:share/share.dart';
import 'package:transparent_image/transparent_image.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  String search = '';
  int offset = 0;
  int limitSearch = 19;

  Future<Map> getGIFS() async {
    http.Response response;
    if (search == '') {
      response = await http.get(
        'https://api.giphy.com/v1/gifs/trending?api_key=tuHskkfe6ptl41foAFi4fVO5SlHMKrkW&limit=20&rating=g',
      );
    } else {
      response = await http.get(
        'https://api.giphy.com/v1/gifs/search?api_key=tuHskkfe6ptl41foAFi4fVO5SlHMKrkW&q=$search&limit=$limitSearch&offset=$offset&rating=g&lang=pt',
      );
    }

    return json.decode(response.body);
  }

  final RefreshController _refreshController =
      RefreshController(initialRefresh: false);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: Image.network(
          'https://developers.giphy.com/branch/master/static/header-logo-0fec0225d189bc0eae27dac3e3770582.gif',
        ),
        centerTitle: true,
      ),
      backgroundColor: Colors.black,
      body: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: 15,
          vertical: 5,
        ),
        child: Column(
          children: [
            TextField(
              decoration: InputDecoration(
                labelText: 'Pesquise aqui',
                labelStyle: const TextStyle(color: Colors.white),
                enabledBorder: OutlineInputBorder(
                  borderSide: const BorderSide(color: Colors.white),
                  borderRadius: BorderRadius.circular(50),
                ),
                focusedBorder: OutlineInputBorder(
                  borderSide: const BorderSide(color: Colors.white),
                  borderRadius: BorderRadius.circular(50),
                ),
              ),
              style: const TextStyle(
                color: Colors.white,
              ),
              onSubmitted: (value) {
                setState(() {
                  search = value;
                  offset = 0;
                });
              },
            ),
            const SizedBox(
              height: 15,
            ),
            Expanded(
              child: FutureBuilder(
                future: getGIFS(),
                builder: ((context, snapshot) {
                  switch (snapshot.connectionState) {
                    case ConnectionState.waiting:
                    case ConnectionState.none:
                      return const Center(
                        child: CircularProgressIndicator(
                          color: Colors.white,
                        ),
                      );
                    default:
                      if (snapshot.hasError) {
                        return const Center(
                          child: Text(
                            'Infelizmente ocorreu um erro ao carregar os dados, reinicie o aplicativo para tentar novamente. Pedimos perdão pelo incoviniente',
                            style: TextStyle(
                              color: Colors.red,
                              fontSize: 24,
                            ),
                          ),
                        );
                      } else {
                        return SmartRefresher(
                          controller: _refreshController,
                          enablePullDown: true,
                          header: const WaterDropMaterialHeader(),
                          onRefresh: () async {
                            await Future.delayed(
                                const Duration(milliseconds: 1000));
                            setState(() {});
                            _refreshController.refreshCompleted();
                          },
                          child: createGifTable(context, snapshot),
                        );
                      }
                  }
                }),
              ),
            ),
          ],
        ),
      ),
    );
  }

  int getCount(List data) {
    if (search == '') {
      return data.length;
    } else {
      return data.length + 1;
    }
  }

  Widget createGifTable(BuildContext context, AsyncSnapshot snapshot) {
    return GridView.builder(
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 10,
        mainAxisSpacing: 10,
      ),
      itemCount: getCount(snapshot.data["data"]),
      itemBuilder: (context, index) {
        if (search == '' || index < snapshot.data["data"].length) {
          return GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => GifPage(
                    gifData: snapshot.data["data"][index],
                  ),
                ),
              );
            },
            onLongPress: () {
              Share.share(
                  'Hey, olhei esse GIF e pensei em você!\nLink: ${snapshot.data["data"][index]["images"]["fixed_height"]["url"]} ');
            },
            child: ClipRRect(
              borderRadius: BorderRadius.circular(20),
              child: FadeInImage.memoryNetwork(
                image: snapshot.data["data"][index]["images"]["fixed_height"]
                    ["url"],
                height: 300.0,
                fit: BoxFit.cover,
                placeholder: kTransparentImage,
              ),
            ),
          );
        } else {
          return SizedBox(
            height: 300,
            child: GestureDetector(
              onTap: () {
                setState(() {
                  offset += 19;
                });
              },
              child: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: const [
                    Icon(
                      Icons.add,
                      color: Colors.white,
                      size: 70,
                    ),
                    Text(
                      'Carregar mais...',
                      style: TextStyle(color: Colors.white, fontSize: 22.0),
                    ),
                  ],
                ),
              ),
            ),
          );
        }
      },
    );
  }
}
