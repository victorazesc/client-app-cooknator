import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:flutter/cupertino.dart';
import 'package:http/http.dart' as http;
import 'package:mix/mix.dart';
import 'package:flutter_html/flutter_html.dart';

class RecipeScreen extends StatefulWidget {
  RecipeScreen({super.key, required this.id});
  String id;
  @override
  // ignore: library_private_types_in_public_api
  _RecipeScreen createState() =>
      // ignore: no_logic_in_create_state
      _RecipeScreen(id: id);
}

class RecipeService {
  static Future<RecipeView> fetchBook(String id, String baseUrl) async {
    final response = await http.get(Uri.parse('$baseUrl$id'));
    final json = jsonDecode(response.body);
    return RecipeView.fromJson(json);
  }
}

class _RecipeScreen extends State<RecipeScreen> {
  _RecipeScreen({required this.id});
  late String baseUrl;
  late String apiUrl;
  String id;
  List<String> ingredients = [
    '2 xícaras (chá) de batata-doce sem casca em cubos (300 g)Sal e pimenta-do-reino moída a gosto',
    '2 xícaras (chá) de leite (480 ml)',
    '1 e 1/4 de xícara (chá) de água (300 ml)',
    '1 dente alho descascado (6 g)',
    '1/2 xícara (chá) de tomilho debulhado (10 g)',
    '1 xícara (chá) de parmesão (100 g)',
    '3 colheres (sopa) de manteiga gelada (45 g)',
    'Bisteca suína (opcional)',
    'Azeite de oliva',
    '4 bistecas de porco (+/- 600 g) temperadas com sal e pimenta-do-reino moída a gosto',
    '2 colheres (sopa) de alho frito laminado (20 g)',
    '2 colheres (sopa) de orégano fresco',
  ];
  List<String> preparation = [
    '2 xícaras (chá) de batata-doce sem casca em cubos (300 g)Sal e pimenta-do-reino moída a gosto',
    '2 xícaras (chá) de leite (480 ml)',
    '1 e 1/4 de xícara (chá) de água (300 ml)',
    '1 dente alho descascado (6 g)',
    '1/2 xícara (chá) de tomilho debulhado (10 g)',
    '1 xícara (chá) de parmesão (100 g)',
    '3 colheres (sopa) de manteiga gelada (45 g)',
    'Bisteca suína (opcional)',
    'Azeite de oliva',
    '4 bistecas de porco (+/- 600 g) temperadas com sal e pimenta-do-reino moída a gosto',
    '2 colheres (sopa) de alho frito laminado (20 g)',
    '2 colheres (sopa) de orégano fresco',
  ];

  late Future<RecipeView> recipe;

  @override
  void initState() {
    super.initState();
    apiUrl = dotenv.env['API_URL']!;
    baseUrl = '$apiUrl/recipes/';
    recipe = RecipeService.fetchBook(widget.id, baseUrl);
    initialization();
    print(recipe);
  }

  @override
  void initialization() async {
    FlutterNativeSplash.remove();
  }

  String toUppercase(String texto) {
    return texto.toUpperCase();
  }

  String formatTime(String time) {
    if (time.startsWith('00h')) {
      time = time.replaceFirst(
          '00h', ''); // Remove "00h" from the beginning of the string
    }
    return time;
  }

  Future<RecipeView> searchRecipe() async {
    final url = '$baseUrl/$id';
    final response = await http.get(Uri.parse(url));
    final json = jsonDecode(response.body);
    return json;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
            backgroundColor: Colors.white,
            leading: IconButton(
              onPressed: () {
                Navigator.pop(context);
              },
              icon: const Icon(
                Icons.chevron_left,
                color: Colors.black87,
                size: 35,
              ),
            ),
            actions: [
              IconButton(
                onPressed: () {},
                icon: const Icon(
                  CupertinoIcons.heart,
                  color: Colors.black87,
                  size: 25,
                ),
              ),
              IconButton(
                onPressed: () {},
                icon: const Icon(
                  Icons.share,
                  color: Colors.black87,
                  size: 25,
                ),
              ),
            ]),
        body: SingleChildScrollView(
          child: FutureBuilder<RecipeView>(
            future: recipe,
            builder: (context, snapshot) {
              if (snapshot.hasData) {
                final recipe = snapshot.data!;
                return Column(
                  children: [
                    Stack(
                      children: [
                        Image.network(recipe.image),
                        Positioned(
                          top: 15,
                          left: 15,
                          child: Container(
                            padding: const EdgeInsets.all(6),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(5.0),
                              color: Colors.black87,
                            ),
                            child: Row(
                              children: [
                                Icon(Icons.timer_outlined, color: Colors.white),
                                SizedBox(width: 5),
                                Text(formatTime(recipe.prepTime ?? ''),
                                    style: TextStyle(color: Colors.white))
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          vertical: 20, horizontal: 20),
                      decoration: const BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.only(
                            topRight: Radius.circular(30),
                            topLeft: Radius.circular(30)),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            recipe.title,
                            style: const TextStyle(
                              fontFamily: 'Poppins',
                              fontWeight: FontWeight.w600,
                              fontSize: 20,
                            ),
                          ),
                          const SizedBox(
                            height: 10,
                          ),
                          Text(
                            recipe.description ?? '',
                            style: const TextStyle(
                              fontFamily: 'Poppins',
                              fontSize: 14,
                            ),
                          ),
                          const SizedBox(
                            height: 10,
                          ),
                          Html(
                            data:
                                '<p style="margin-left: -7px">${recipe.content}</p>',
                          ),
                          const SizedBox(
                            height: 20,
                          ),
                          Container(
                            margin: const EdgeInsets.only(top: 25, bottom: 25),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Column(
                                  children: [
                                    Text(
                                      "Serve até",
                                      style: TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.w500),
                                    ),
                                    Text(recipe.yield ?? ''),
                                  ],
                                ),
                                Column(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  children: [
                                    Text(
                                      "Custo",
                                      style: TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.w500),
                                    ),
                                    Text(recipe.cost ?? ''),
                                  ],
                                ),
                                Column(
                                  children: [
                                    Text(
                                      "Nível",
                                      style: TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.w500),
                                    ),
                                    Text(recipe.level),
                                  ],
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(
                            height: 20,
                          ),
                          Row(
                            children: const [
                              Text(
                                "Ingredientes",
                                style: TextStyle(
                                  fontFamily: 'Poppins',
                                  fontWeight: FontWeight.w600,
                                  fontSize: 19,
                                ),
                              ),
                              SizedBox(
                                width: 10,
                              ),
                              Icon(Icons.keyboard_arrow_down)
                            ],
                          ),
                          const SizedBox(
                            height: 30,
                          ),
                          if (recipe.ingredients.length > 0)
                            ListView.builder(
                              shrinkWrap: true,
                              itemCount: recipe.ingredients.length,
                              itemBuilder: (context, index) {
                                return Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      SizedBox(height: 10),
                                      Row(children: [
                                        Icon(Icons.cookie_outlined),
                                        Expanded(
                                            child: Text(
                                          recipe.ingredients[index],
                                          softWrap: true,
                                          maxLines: 2,
                                          overflow: TextOverflow.fade,
                                        ))
                                      ])
                                    ]);
                              },
                            ),
                          SizedBox(height: 40),
                          Row(
                            children: const [
                              Text(
                                "Modo de Preparo",
                                style: TextStyle(
                                  fontFamily: 'Poppins',
                                  fontWeight: FontWeight.w600,
                                  fontSize: 19,
                                ),
                              ),
                              SizedBox(
                                width: 10,
                              ),
                              Icon(Icons.keyboard_arrow_down)
                            ],
                          ),
                          const SizedBox(
                            height: 25,
                          ),
                          if (recipe.preparation.length > 0)
                            ListView.builder(
                              shrinkWrap: true,
                              itemCount: recipe.preparation.length,
                              itemBuilder: (context, index) {
                                return Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      SizedBox(height: 10),
                                      Row(children: [
                                        Text(index.toString() + ' - '),
                                        SizedBox(width: 5),
                                        Expanded(
                                            child: Text(
                                          recipe.preparation[index],
                                          softWrap: true,
                                          maxLines: 2,
                                          overflow: TextOverflow.fade,
                                        ))
                                      ])
                                    ]);
                              },
                            ),
                          const SizedBox(
                            height: 30,
                          ),
                        ],
                      ),
                    ),
                  ],
                );
              } else if (snapshot.hasError) {
                return Text('Error: ${snapshot.error}');
              } else {
                return Center(child: CircularProgressIndicator());
              }
            },
          ),
        ));
  }
}

class RecipeView {
  final String id;
  final String title;
  final String image;
  final String prepTime;
  final String description;
  final String content;
  final String yield;
  final String level;
  final String cost;
  final List<dynamic> ingredients;
  final List<dynamic> preparation;

  RecipeView({
    required this.id,
    required this.title,
    required this.image,
    required this.prepTime,
    required this.description,
    required this.content,
    required this.yield,
    required this.level,
    required this.cost,
    required this.ingredients,
    required this.preparation,
  });

  factory RecipeView.fromJson(Map<String, dynamic> json) {
    return RecipeView(
      id: json['id'],
      title: json['title'],
      image: json['image'],
      prepTime: json['prepTime'],
      description: json['description'],
      content: json['content'],
      yield: json['yield'],
      level: json['level'],
      cost: json['cost'],
      ingredients: json['ingredients'],
      preparation: json['preparation'],
    );
  }
}
