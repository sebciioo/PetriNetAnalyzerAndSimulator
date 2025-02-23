import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:petri_net_front/data/models/petriNet.dart';
import 'package:defer_pointer/defer_pointer.dart';
import 'package:petri_net_front/state/providers/petriNetState.dart';

class RemoveElementsFromNet extends ConsumerWidget {
  const RemoveElementsFromNet({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final transformationController = TransformationController();
    final petriNetState = ref.watch(petriNetProvider);

    void _addTokens(States state) {
      ref.read(petriNetProvider.notifier).addToken(state);
    }

    void _removeTokens(States state) {
      if (state.tokens >= 1) {
        ref.read(petriNetProvider.notifier).removeToken(state);
      }
    }

    return Stack();
  }
}
