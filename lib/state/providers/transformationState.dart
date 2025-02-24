import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final transformationControllerProvider =
    Provider<TransformationController>((ref) {
  return TransformationController();
});
