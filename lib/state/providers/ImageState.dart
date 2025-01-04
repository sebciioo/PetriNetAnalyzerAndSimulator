import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'dart:io';

class ImageStateNotifier extends StateNotifier<File?> {
  ImageStateNotifier() : super(null);

  void setImage(File image) {
    state = image;
  }

  void clearImage() {
    state = null;
  }
}

final imageProvider = StateNotifierProvider<ImageStateNotifier, File?>((ref) {
  return ImageStateNotifier();
});
