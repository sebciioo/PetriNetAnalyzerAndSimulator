import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'dart:io';

class ErrorStateNotifier extends StateNotifier<String?> {
  ErrorStateNotifier() : super(null);

  void setText(String text) {
    state = 'Błąd serwera spróbuj ponowanie!';
  }
}

final errorProvider = StateNotifierProvider<ErrorStateNotifier, String?>((ref) {
  return ErrorStateNotifier();
});
