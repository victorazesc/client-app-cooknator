import 'dart:convert';
import 'dart:io';

import 'package:camera_camera/camera_camera.dart';
import 'package:flutter/material.dart';
import 'package:animated_splash_screen/animated_splash_screen.dart';
import 'package:flutter/services.dart';
import "package:flutter_svg/svg.dart";
import 'package:get/get.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

import 'app/core/assets.dart';
import 'app/pages/preview_page.dart';
import 'app/pages/recipes_list.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_native_splash/flutter_native_splash.dart';

import 'app/pages/recipes_view.dart';

Future<void> main() async {
  await dotenv.load();
  WidgetsBinding widgetsBinding = WidgetsFlutterBinding.ensureInitialized();
  // FlutterNativeSplash.preserve(widgetsBinding: widgetsBinding);
  SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp])
      .then((_) {
    runApp(const MyApp());
  });
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
        title: 'Flutter Demo',
        // theme: ThemeData(
        //   colorScheme: ColorScheme.fromSwatch().copyWith(
        //     shadow: null,
        //     primary: const Color.fromARGB(238, 238, 238, 238),
        //     secondary: const Color.fromARGB(255, 0, 0, 0),
        //   ),
        // ),
        home: const SearchScreen(),
        // home: RecipeScreen(),
        // home: AnimatedSplashScreen(
        //     duration: 3000,
        //     splash: 'assets/images/logo.png',
        //     nextScreen: const SearchScreen(),
        //     splashIconSize: double.tryParse("120.5"),
        //     // nextScreen: const SearchScreen(),
        //     splashTransition: SplashTransition.fadeTransition,
        //     curve: Curves.easeInBack,
        //     // pageTransitionType: PageTransitionType.scale,
        //     backgroundColor: Colors.white),
        routes: {
          '/search': (context) => const SearchScreen(),
        });
  }
}

class FirstScreen extends StatelessWidget {
  const FirstScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            SizedBox(
              width: 80, // Define a largura desejada
              height: 80, // Define a altura desejada
              child: FloatingActionButton(
                onPressed: () {
                  // Navigate to the second screen using a named route.
                  Navigator.pushNamed(context, '/search');
                },
                tooltip: 'Increment',
                backgroundColor: Colors.white,
                elevation: 1.0,
                shape: const CircleBorder(
                  side: BorderSide(width: 2.0, color: Colors.black),
                ),
                heroTag: null,
                clipBehavior: Clip.none,
                mini: false,
                materialTapTargetSize: MaterialTapTargetSize.padded,
                child: SvgPicture.asset(Assets.icPan),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _SearchScreen createState() => _SearchScreen();
}

class _SearchScreen extends State<SearchScreen> {
  String searchText = "";
  late File photo;
  late String apiUrl;
  String baseUrl = "";
  List<String> searchedTerms = [];

  void getSearchedTerms() {
    () async {
      String? myString = await loadData("searchedTerms");

// Converte a string de volta para uma lista de strings
      List<String> searchedTerms = myString?.split(",") ?? [];
    }();
  }

  void searchRecipes() async {
    String url = '$baseUrl?ingredients=$searchText';
    http.Response response = await http.get(Uri.parse(url));
    if (response.statusCode == 200) {
      Map<String, dynamic> data = jsonDecode(response.body);
      final recipes = (data['recipes'] as List)
          .map((json) => Recipe.fromJson(json))
          .toList();
      setState(() {
        searchedTerms.add(searchText);
      });
      saveData('searchedTerms', searchedTerms.join(','));
      Get.to(RecipesList(
        recipesList: recipes,
        search: searchText,
      ));
    } else {
      print('Erro na requisição: ${response.statusCode}');
    }
  }

  showPreview(file) async {
    List<Recipe> recipes = await Get.to(() => PreviewPage(file: file));

    if (file != null) {
      Get.to(RecipesList(
        recipesList: recipes,
        search: "",
      ));
    }
  }

  @override
  void initState() {
    getSearchedTerms();
    super.initState();
    initialization();
    apiUrl = dotenv.env['API_URL']!;
    baseUrl = '$apiUrl/recipes';
  }

  @override
  void initialization() async {
    FlutterNativeSplash.remove();
  }

  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
          body: SafeArea(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Expanded(
                child: Center(
                    child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                  SizedBox(
                    width: 130,
                    height: 130,
                    child: FloatingActionButton(
                      onPressed: () => Get.to(
                          CameraCamera(onFile: (file) => showPreview(file))),
                      tooltip: 'Increment',
                      backgroundColor: Colors.white,
                      elevation: 1.0,
                      shape: const CircleBorder(
                        side: BorderSide(width: 2.0, color: Colors.black),
                      ),
                      heroTag: null,
                      clipBehavior: Clip.none,
                      mini: false,
                      materialTapTargetSize: MaterialTapTargetSize.padded,
                      child: SvgPicture.asset(Assets.icCamera),
                    ),
                  ),
                  const SizedBox(height: 20),
                  const Text(
                    "What are you looking for?",
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.normal,
                    ),
                  ),
                  const SizedBox(height: 20),
                  const SizedBox(
                    width: 130,
                    height: 25,
                    child: Text(
                      "History",
                      textAlign: TextAlign.center,
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                  SizedBox(
                      width: 150,
                      height: 150,
                      child: Center(
                        child: ListView.builder(
                          itemCount: searchedTerms.length,
                          itemBuilder: (context, index) {
                            return Padding(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 20, vertical: 10),
                                child: Text(
                                  textAlign: TextAlign.center,
                                  searchedTerms[index],
                                ));
                          },
                        ),
                      )),
                ]))),
            BottomAppBar(
              elevation: 0.0,
              color: const Color(0xEEEEEEEE),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      onChanged: (text) {
                        setState(() {
                          searchText = text;
                        });
                      },
                      onSubmitted: (value) => searchRecipes(),
                      decoration: const InputDecoration(
                        hintText: "Search...",
                        filled: true,
                        fillColor: Color(0xEEEEEEEE),
                        hintStyle: TextStyle(color: Colors.grey),
                        border: InputBorder.none,
                        contentPadding:
                            EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                      ),
                      style: const TextStyle(color: Colors.black),
                    ),
                  ),
                  IconButton(
                    onPressed: () => searchRecipes(),
                    icon: const Icon(Icons.search, color: Colors.black),
                  ),
                ],
              ),
            )
          ],
        ),
      )),
    );
  }
}
