import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:petri_net_front/UI/providers/ImageState.dart';
import 'package:petri_net_front/UI/screens/imagePickerScreen/widget/customElevatedButton.dart';
import 'package:petri_net_front/UI/screens/imagePickerScreen/widget/imageInput.dart';
import 'package:petri_net_front/UI/utils/responsive_constants.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';

class ImagePickerScreen extends ConsumerWidget {
  const ImagePickerScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final imageState = ref.watch(imageProvider);

    void _takePicture() async {
      final imagePicker = ImagePicker();
      final pickedImage = await imagePicker.pickImage(
          source: ImageSource.camera, maxWidth: 600);

      if (pickedImage == null) {
        return;
      }
      ref.read(imageProvider.notifier).setImage(File(pickedImage.path));
    }

    void _pickFromGallery() async {
      final imagePicker = ImagePicker();
      final pickedImage = await imagePicker.pickImage(
          source: ImageSource.gallery, maxWidth: 600);

      if (pickedImage == null) {
        return; // Jeśli użytkownik anulował wybór
      }

      ref.read(imageProvider.notifier).setImage(File(pickedImage.path));
    }

    return Scaffold(
      body: Center(
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Theme.of(context).colorScheme.primary,
                Theme.of(context).colorScheme.primaryContainer,
                Theme.of(context).colorScheme.onPrimary
              ],
              stops: const [0.0, 0.3, 0.8],
              begin: const AlignmentDirectional(-1.0, -1.0),
              end: const AlignmentDirectional(1.0, 1.0),
            ),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsetsDirectional.fromSTEB(0, 70, 0, 0),
                child: Container(
                  width: 250,
                  height: 70,
                  alignment: const AlignmentDirectional(0, 0),
                  child: const Text(
                    'PetriMind',
                    style: TextStyle(
                      fontFamily: 'htr',
                      color: Colors.white, // Kolor tekstu
                      fontSize: 60,
                      fontWeight: FontWeight.w500,
                      letterSpacing: 0.0,
                      shadows: [
                        Shadow(
                          offset: Offset(1.5, 1.5),
                          color: Colors.black,
                        ),
                        Shadow(
                          offset: Offset(1.5, 1.5),
                          color: Colors.black,
                        ),
                        Shadow(
                          offset: Offset(1.5, 1.5),
                          color: Colors.black,
                        ),
                        Shadow(
                          offset: Offset(2, 1.5),
                          color: Colors.black,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              Expanded(
                  child: Center(
                child: Container(
                  width: MediaQuery.of(context).size.width * 0.9,
                  height: MediaQuery.of(context).size.height * 0.65,
                  padding: const EdgeInsets.all(30.0),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16.0),
                    boxShadow: const [
                      BoxShadow(
                        color: Colors.black26,
                        blurRadius: 10.0,
                        offset: Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      Text(
                        "Dodaj zdjęcie sieci",
                        style: TextStyle(
                          fontSize: 24.0,
                          fontWeight: FontWeight.bold,
                          color: Theme.of(context).colorScheme.inverseSurface,
                        ),
                      ),
                      const SizedBox(
                        height: 20,
                      ),
                      const Text(
                        "Wybierz zdjęcie z galerii lub zrób nowe zdjęcie, aby kontynuować.",
                        style: TextStyle(
                          fontSize: 13.0,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF757575),
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(
                        height: 20,
                      ),
                      ImageInput(),
                      const SizedBox(
                        height: 20,
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 0.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: imageState == null
                                  ? CustomElevatedButton(
                                      label: "Zrób zdjęcie",
                                      icon: Icons.camera,
                                      onPressed: _takePicture,
                                      backgroundColor: Theme.of(context)
                                          .colorScheme
                                          .secondary,
                                      textColor:
                                          Theme.of(context).colorScheme.surface,
                                    )
                                  : CustomElevatedButton(
                                      label: "Gotowe!",
                                      icon: Icons.check,
                                      onPressed: () {},
                                      backgroundColor: Theme.of(context)
                                          .colorScheme
                                          .secondary,
                                      textColor:
                                          Theme.of(context).colorScheme.surface,
                                    ),
                            ),
                            SizedBox(width: 16),
                            Expanded(
                              child: imageState == null
                                  ? CustomElevatedButton(
                                      label: "Dodaj z galerii",
                                      icon: Icons.photo_camera_back,
                                      onPressed: _pickFromGallery,
                                      backgroundColor: Colors.white,
                                      textColor: Theme.of(context)
                                          .colorScheme
                                          .inverseSurface,
                                      borderColor: Theme.of(context)
                                          .colorScheme
                                          .secondary,
                                    )
                                  : CustomElevatedButton(
                                      label: "Usuń zdjęcie",
                                      icon: Icons.delete,
                                      onPressed: () {
                                        ref
                                            .read(imageProvider.notifier)
                                            .clearImage();
                                      },
                                      backgroundColor: Colors.white,
                                      textColor: Theme.of(context)
                                          .colorScheme
                                          .inverseSurface,
                                      borderColor: Theme.of(context)
                                          .colorScheme
                                          .secondary,
                                    ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              )),
            ],
          ),
        ),
      ),
    );
  }
}
