import "package:flutter/material.dart";
import "package:flutter_svg/svg.dart";
import "package:get/get.dart";
import "package:image_picker/image_picker.dart";
import "package:mix/mix.dart";

import "../core/assets.dart";

class UploadDocument extends StatelessWidget {
  final String title;
  final Future<void> Function(XFile) onFile;
  final String? fileName;
  final String imgDocument;
  final Mix? mix;
  final bool disabled;

  UploadDocument({
    super.key,
    required this.title,
    required this.onFile,
    required this.imgDocument,
    this.fileName,
    this.mix,
    this.disabled = false,
  });

  final picker = ImagePicker();
  static const ValueKey uploadDocumentKey = ValueKey("uploadDocumentKey");

  @override
  Widget build(BuildContext context) {
    final style = Mix(
      p(20),
      borderColor(Colors.amber),
      rounded(8),
      crossAxis(CrossAxisAlignment.center),
      width(double.infinity),
    );

    final stylesCombined = Mix.combine(style, mix);
    return VBox(
      key: uploadDocumentKey,
      mix: stylesCombined,
      children: [
        const SizedBox(height: 40),
        SizedBox(width: 70, height: 70, child: _buildImage()),
        const SizedBox(height: 40),
        _buildButtons(),
        if (fileName != null && fileName != "") ...[
          const SizedBox(height: 10),
          _buildFileName()
        ]
      ],
    );
  }

  Widget _buildFileName() {
    return Container(
      padding: const EdgeInsets.all(8),
      width: double.infinity,
      decoration: const BoxDecoration(
        color: Colors.black,
        borderRadius: BorderRadius.all(
          Radius.circular(20.0),
        ),
      ),
      child: Center(),
    );
  }

  Typography _buildTitle() {
    return Typography.material2014();
  }

  Widget _buildImage() {
    if (fileName != null) {
      return SvgPicture.asset(
        Assets.icCamera,
        color: Colors.black,
      );
    }
    return SvgPicture.asset(imgDocument);
  }

  Widget _buildButtons() {
    return VBox(
      children: [
        FloatingActionButton(
          onPressed: getImage,
          tooltip: 'Take Photo',
          child: const Icon(Icons.camera_alt),
        ),
        const SizedBox(height: 10),
      ],
    );
  }

  Future getImage() async {
    try {
      final XFile? file = await picker.pickImage(
        source: ImageSource.camera,
        imageQuality: 100,
        maxHeight: 1024,
        maxWidth: 1024,
      );
      onFile(file!);
    } catch (e) {
      e.printError();
    }
  }
}
