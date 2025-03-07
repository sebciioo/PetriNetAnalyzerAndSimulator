import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:petri_net_front/backendServer/serverManager.dart';
import 'package:petri_net_front/data/models/petriNet.dart';
import 'package:petri_net_front/state/providers/ImageState.dart';
import 'package:petri_net_front/state/providers/errorState.dart';
import 'package:petri_net_front/state/providers/loadingState.dart';
import 'package:petri_net_front/state/providers/petriNetState.dart';
import 'package:petri_net_front/UI/screens/imagePickerScreen/widget/customElevatedButton.dart';
import 'package:petri_net_front/UI/screens/imagePickerScreen/widget/imageInput.dart';
import 'package:petri_net_front/UI/screens/petriNetScreen/petriNetsScreen.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';

class ImagePickerScreen extends ConsumerWidget {
  const ImagePickerScreen({super.key, required this.serverManager});
  final ServerManager serverManager;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final imageState = ref.watch(imageProvider);
    final errorState = ref.watch(errorProvider);
    final loadingState = ref.watch(loadingProvider);
    print("--------------------------------------------------");
    print(loadingState);
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
        return;
      }

      ref.read(imageProvider.notifier).setImage(File(pickedImage.path));
    }

    void goToPetriNetScreen(BuildContext context) {
      Navigator.of(context).push(
        MaterialPageRoute(
            builder: (ctx) => PetriNetScreen(
                  serverManager: serverManager,
                )),
      );
    }

    void _setPetriNetToProvider(BuildContext context) async {
      final jsonResponse =
          await serverManager.sendImageFromPhoneToServer(imageState!);

      if (!context.mounted) {
        ref.read(loadingProvider.notifier).stopProcessing();
        return;
      }
      if (!jsonResponse.containsKey('error')) {
        final PetriNet petriNetResponse = PetriNet.fromJson(jsonResponse);
        ref.read(petriNetProvider.notifier).setPetriNet(petriNetResponse);
        ref.read(loadingProvider.notifier).stopProcessing();
        goToPetriNetScreen(context);
      } else {
        ref.read(loadingProvider.notifier).stopProcessing();
        ref.read(errorProvider.notifier).setText(jsonResponse['message']);
      }
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
                                      label: loadingState
                                          ? "Przetwarzanie..."
                                          : "Gotowe!",
                                      icon: loadingState
                                          ? Icons.hourglass_empty
                                          : Icons.check,
                                      onPressed: loadingState
                                          ? () => {}
                                          : () {
                                              ref
                                                  .read(
                                                      loadingProvider.notifier)
                                                  .startProcessing();
                                              _setPetriNetToProvider(context);
                                            },
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
                                      onPressed: loadingState
                                          ? () => {}
                                          : () {
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
              Align(
                alignment: const AlignmentDirectional(1, 1),
                child: Padding(
                  padding: const EdgeInsetsDirectional.fromSTEB(0, 0, 20, 30),
                  child: FloatingActionButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                      ref.read(imageProvider.notifier).clearImage();
                    },
                    backgroundColor: Theme.of(context).colorScheme.secondary,
                    elevation: 0,
                    child: const Icon(
                      Icons.arrow_back_rounded,
                      color: Colors.white,
                      size: 25,
                    ),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: errorState != null
                    ? Container(
                        child: Text(
                          errorState,
                          style: const TextStyle(
                              color:
                                  Colors.red), // Opcjonalnie stylizacja błędu
                        ),
                      )
                    : const SizedBox
                        .shrink(), // Puste miejsce, jeśli `errorState` jest `null`
              ),
            ],
          ),
        ),
      ),
    );
  }
}
