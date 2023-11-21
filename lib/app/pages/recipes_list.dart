import 'dart:convert';

import 'package:cook/app/pages/recipes_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:get/get.dart';
import 'package:get/get_state_manager/src/simple/get_widget_cache.dart';
import 'package:mix/mix.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

// Salva um valor no armazenamento local
Future<void> saveData(String key, String value) async {
  final prefs = await SharedPreferences.getInstance();
  await prefs.setString(key, value);
}

// Recupera um valor do armazenamento local
Future<String?> loadData(String key) async {
  final prefs = await SharedPreferences.getInstance();
  return prefs.getString(key);
}

// ignore: must_be_immutable
class RecipesList extends StatefulWidget {
  List<Recipe> recipesList = [];
  String search = "";
  RecipesList({super.key, required this.recipesList, required this.search});

  @override
  // ignore: library_private_types_in_public_api
  _RecipesList createState() =>
      // ignore: no_logic_in_create_state
      _RecipesList(recipesList: recipesList, search: search);
}

class _RecipesList extends State<RecipesList> {
  List<Recipe> recipesList = [];
  String search = "";

  late String apiUrl;

  _RecipesList({required this.recipesList, required this.search});

  final _searchController = TextEditingController();

  String baseUrl = '';

  searchRecipes() async {
    print(search);
    String url = '$baseUrl?ingredients=$search';
    http.Response response = await http.get(Uri.parse(url));

    if (response.statusCode == 200) {
      Map<String, dynamic> data = jsonDecode(response.body);
      final recipes = (data['recipes'] as List)
          .map((json) => Recipe.fromJson(json))
          .toList();
      setState(
        () => recipesList = recipes,
      );
    } else {
      print('Erro na requisição: ${response.statusCode}');
    }
  }

  @override
  void initState() {
    super.initState();
    _searchController.text = search;
    apiUrl = dotenv.env['API_URL']!;
    baseUrl = '$apiUrl/recipes';
  }

  Widget build(BuildContext context) {
    return MaterialApp(
        home: Scaffold(
            appBar: AppBar(
              elevation: 0.0,
              backgroundColor: const Color(0xEEEEEEEE),
              leading: IconButton(
                color: Colors.black,
                icon: const Icon(Icons.arrow_back),
                onPressed: () {
                  Get.back();
                },
              ),
              actions: [
                IconButton(
                  color: Colors.black,
                  icon: const Icon(Icons.close),
                  onPressed: () {
                    Navigator.pop(context);
                  },
                ),
              ],
              title: TextField(
                controller: _searchController,
                onChanged: (value) {
                  setState(() {
                    search = value;
                  });
                },
                onSubmitted: (value) {
                  searchRecipes();
                },
                decoration: const InputDecoration(
                  hintText: "Search...",
                  filled: true,
                  fillColor: Color(0xEEEEEEEE),
                  hintStyle: TextStyle(color: Colors.grey),
                  border: InputBorder.none,
                  contentPadding:
                      EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                ),
              ),
            ),
            body: Center(
                child: Column(
              children: [
                Padding(
                    padding: const EdgeInsets.only(bottom: 24, top: 24),
                    child: Text(
                      'Encontramos ${recipesList.length} receitas para você',
                      style: const TextStyle(
                          fontWeight: FontWeight.bold, fontSize: 14),
                    )),
                Expanded(
                  child: ListView.builder(
                    itemCount: recipesList.length,
                    itemBuilder: (context, index) {
                      return Column(children: [
                        RecipeItem(
                            image: recipesList[index].image,
                            id: recipesList[index].id,
                            title: recipesList[index].title,
                            likes: recipesList[index].likes,
                            prepTime: '')
                      ]);
                    },
                  ),
                ),
              ],
            ))));
  }
}

class Recipe {
  final String id;
  final String title;
  final String image;
  final int likes;

  const Recipe({
    required this.id,
    required this.title,
    required this.image,
    required this.likes,
  });

  factory Recipe.fromJson(Map<String, dynamic> map) {
    return Recipe(
      id: map['id'] as String,
      title: map['title'] as String,
      image: map['image'] as String,
      likes: map['likes'] as int,
    );
  }
}

class RecipeItem extends StatelessWidget {
  String image;
  String id;
  String title = 'Meu Título';
  int likes = 0;
  String prepTime = '';

  RecipeItem(
      {super.key,
      required this.image,
      required this.id,
      required this.title,
      required this.likes,
      required this.prepTime});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        GestureDetector(
          onTap: () {
            Get.to(RecipeScreen(id: id));
          },
          child: Stack(
            children: [
              Padding(
                padding: const EdgeInsets.only(bottom: 15, left: 20),
                child: Row(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: SizedBox.fromSize(
                        size: const Size.fromRadius(48), // Image radius
                        child: Image.network(image, fit: BoxFit.cover),
                      ),
                    ),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        // padding: const EdgeInsets.only(bottom: 24, left: 20, right: 20),
                        children: [
                          Padding(
                            padding: const EdgeInsets.only(
                                bottom: 25, left: 20, right: 20),
                            child: Text(
                              title,
                              style: const TextStyle(fontSize: 14),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.only(
                                bottom: 0, left: 20, right: 20),
                            child: Row(
                              children: [
                                const Icon(
                                  Icons.favorite,
                                  color: Colors.red,
                                  size: 15,
                                ),
                                Text(
                                    ' ${likes.toString()} ${likes.bitLength == 1 ? 'Curtida' : 'Curtidas'} '),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              Positioned.fill(
                child: Container(
                  color: Colors.transparent,
                ),
              ),
            ],
          ),
        ),
        Container(
          height: 1,
          decoration: const BoxDecoration(
            border: Border(
              bottom: BorderSide(color: Color(0xEEEEEEEE), width: 1.0),
            ),
          ),
        ),
        const Padding(
          padding: EdgeInsets.only(bottom: 15, left: 20, right: 20),
        )
      ],
    );
  }
}
