import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'dart:io';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:petri_net_front/state/providers/ImageState.dart';

class ImageInput extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final imageState = ref.watch(imageProvider);

    Widget content = Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(
          Icons.camera_alt,
          color: Theme.of(context).colorScheme.inverseSurface,
        ),
        const SizedBox(width: 8),
        Text(
          'Twoje zdjęcie',
          style: TextStyle(
            color: Theme.of(context).colorScheme.inverseSurface,
            fontSize: 16.0,
          ),
        ),
      ],
    );

    if (imageState != null) {
      content = Image.file(
        imageState,
        width: double.infinity,
        height: MediaQuery.of(context).size.width * 0.7,
        fit: BoxFit.cover,
      );
    }
    return Container(
      decoration: BoxDecoration(
          border: Border.all(
        width: 0.6,
        color: Theme.of(context).colorScheme.inverseSurface,
      )),
      height: MediaQuery.of(context).size.width * 0.7,
      width: double.infinity,
      alignment: Alignment.center,
      child: content,
    );
  }
}
