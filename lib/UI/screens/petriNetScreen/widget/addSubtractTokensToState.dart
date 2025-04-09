import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:petri_net_front/data/models/petriNet.dart';
import 'package:defer_pointer/defer_pointer.dart';
import 'package:petri_net_front/state/providers/petriNetState.dart';

class AddSubtractTokensToState extends ConsumerWidget {
  const AddSubtractTokensToState({super.key});

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

    List<Widget> _buildStatesButtons() {
      return petriNetState!.states.map((state) {
        final position = state.center;
        final transformedPosition = transformationController.toScene(position);
        const double buttonSize = 30.0;

        return Positioned(
          top: (transformedPosition.dy - buttonSize / 2) - 45,
          left: transformedPosition.dx - (buttonSize * 2.5) / 2,
          child: DeferPointer(
            child: Container(
              width: buttonSize * 2.5,
              height: buttonSize,
              decoration: BoxDecoration(
                color: Colors.blue.withOpacity(0.7),
                borderRadius: BorderRadius.circular(25.0),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  GestureDetector(
                    onTap: () {
                      _removeTokens(state);
                    },
                    child: Container(
                      width: (buttonSize * 2.5) / 2,
                      height: buttonSize,
                      decoration: const BoxDecoration(
                        borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(25.0),
                          bottomLeft: Radius.circular(25.0),
                        ),
                      ),
                      child: const Icon(
                        Icons.remove_circle_outline,
                        size: 25,
                        color: Colors.white,
                      ),
                    ),
                  ),
                  GestureDetector(
                    onTap: () {
                      _addTokens(state);
                    },
                    child: Container(
                      width: (buttonSize * 2.5) / 2,
                      height: buttonSize,
                      decoration: const BoxDecoration(
                        borderRadius: BorderRadius.only(
                          topRight: Radius.circular(25.0),
                          bottomRight: Radius.circular(25.0),
                        ),
                      ),
                      child: const Icon(
                        Icons.add_circle_outline,
                        size: 25,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      }).toList();
    }

    return Stack(
      clipBehavior: Clip.none,
      children: _buildStatesButtons(),
    );
  }
}
