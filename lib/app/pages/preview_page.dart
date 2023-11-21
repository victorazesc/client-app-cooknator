import 'dart:convert';
import 'dart:io';

import 'package:cook/app/pages/recipes_list.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mix/mix.dart';
import 'package:http/http.dart' as http;

import '../core/utils/loading.dart';

class PreviewPage extends StatefulWidget {
  File file;
  PreviewPage({Key? key, required this.file}) : super(key: key);

  @override
  _PreviewPageState createState() => _PreviewPageState(file: file);
}

class _PreviewPageState extends State<PreviewPage> {
  File file;
  _PreviewPageState({Key? key, required this.file});
  bool isLoading = false;

  Future<void> uploadImage(File imageFile) async {
    setState(() {
      isLoading = true;
    });
    print("enviando imagem para api...");

    var request = http.MultipartRequest(
      'POST',
      Uri.parse(
          'https://7bdb-2804-14c-cc92-92bc-74b3-ccb5-5979-e8f6.sa.ngrok.io/recipes/recognize'),
    );
    request.files.add(
      await http.MultipartFile.fromPath(
        'image',
        imageFile.path,
      ),
    );

    var response = await request.send();
    if (response.statusCode == 201) {
      print('Imagem enviada com sucesso!');
      final jsonData = await utf8.decoder.bind(response.stream).join();
      final data = json.decode(jsonData);
      final recipeList = (data['recipes'] as List)
          .map((json) => Recipe.fromJson(json))
          .toList();
      Get.back(result: recipeList);
    } else {
      print('Erro ao enviar imagem: ${response.statusCode}');
    }

    setState(() {
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Stack(children: [
      Positioned.fill(
          child: Image.file(
        file,
        fit: BoxFit.cover,
      )),
      if (isLoading)
        Container(
          color: Colors.white.withOpacity(0.5),
          child: const Center(
            child: CircularProgressIndicator(),
          ),
        ),
      Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Align(
            alignment: Alignment.bottomCenter,
            child: Padding(
                padding: const EdgeInsets.all(32),
                child: CircleAvatar(
                    radius: 32,
                    backgroundColor: Colors.black.withOpacity(0.5),
                    child: IconButton(
                      icon: const Icon(
                        Icons.check,
                        color: Colors.white,
                        size: 30,
                      ),
                      onPressed: () => uploadImage(file),
                    ))),
          ),
          Align(
            alignment: Alignment.bottomCenter,
            child: Padding(
                padding: const EdgeInsets.all(32),
                child: CircleAvatar(
                    radius: 32,
                    backgroundColor: Colors.black.withOpacity(0.5),
                    child: IconButton(
                      icon: const Icon(
                        Icons.close,
                        color: Colors.white,
                        size: 30,
                      ),
                      onPressed: () => Get.back(),
                    ))),
          )
        ],
      ),
    ]));
  }
}
