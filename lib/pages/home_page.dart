import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  String search = '';
  int offset = 0;

  Future<Map> getGIFS() async {
    http.Response response;
    if (search == '') {
      response = await http.get(
        'https://api.giphy.com/v1/gifs/trending?api_key=tuHskkfe6ptl41foAFi4fVO5SlHMKrkW&limit=25&rating=g',
      );
    } else {
      response = await http.get(
        'https://api.giphy.com/v1/gifs/search?api_key=tuHskkfe6ptl41foAFi4fVO5SlHMKrkW&q=$search&limit=25&offset=$offset&rating=g&lang=pt',
      );
    }

    return json.decode(response.body);
  }

  @override
  void initState() {
    super.initState();

    getGIFS().then((map) {
      print(map);
    });
  }

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
                        return createGifTable(context, snapshot);
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

  Widget createGifTable(BuildContext context, AsyncSnapshot snapshot) {
    return GridView.builder(
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 10,
        mainAxisSpacing: 10,
      ),
      itemCount: snapshot.data["data"].length,
      itemBuilder: (context, index) {
        return GestureDetector(
          child: ClipRRect(
            borderRadius: BorderRadius.circular(20),
            child: Image.network(
              snapshot.data["data"][index]["images"]["fixed_height"]["url"],
              height: 300.0,
              fit: BoxFit.cover,
            ),
          ),
        );
      },
    );
  }
}
