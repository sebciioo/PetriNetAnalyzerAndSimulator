import 'package:flutter_riverpod/flutter_riverpod.dart';

class LoadingStateNotifier extends StateNotifier<bool> {
  LoadingStateNotifier() : super(false);

  void startProcessing() => state = true;
  void stopProcessing() => state = false;
}

final loadingProvider = StateNotifierProvider<LoadingStateNotifier, bool>(
  (ref) => LoadingStateNotifier(),
);
