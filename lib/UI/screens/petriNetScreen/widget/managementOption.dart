import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:petri_net_front/data/models/petriNet.dart';
import 'package:petri_net_front/state/providers/modeState.dart';
import 'package:petri_net_front/UI/screens/imagePickerScreen/widget/customElevatedButton.dart';
import 'package:petri_net_front/data/models/mode.dart';

class ManagementOption extends ConsumerWidget {
  const ManagementOption({super.key, required this.petriNet});
  final PetriNet petriNet;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final modeState = ref.watch(modeProvider);

    return GridView.count(
      shrinkWrap: true,
      crossAxisCount: 2,
      mainAxisSpacing: 12,
      crossAxisSpacing: 12,
      childAspectRatio: 2,
      children: [
        CustomElevatedButton(
          label: "Edytuj tokeny",
          onPressed: () {
            ref
                .read(modeProvider.notifier)
                .setEditModeType(EditModeType.addTokens);
          },
          backgroundColor: modeState.editModeType == EditModeType.addTokens
              ? Theme.of(context).colorScheme.secondary
              : Colors.white,
          textColor: modeState.editModeType == EditModeType.addTokens
              ? Colors.white
              : Colors.black,
          fontMin: 14,
          fontMax: 15,
          padding: 2,
        ),
        CustomElevatedButton(
          label: "Dodaj elementy",
          onPressed: () {
            ref
                .read(modeProvider.notifier)
                .setEditModeType(EditModeType.addElements);
          },
          backgroundColor: modeState.editModeType == EditModeType.addElements
              ? Theme.of(context).colorScheme.secondary
              : Colors.white,
          textColor: modeState.editModeType == EditModeType.addElements
              ? Colors.white
              : Colors.black,
          fontMin: 14,
          fontMax: 15,
          padding: 2,
        ),
        CustomElevatedButton(
          label: "Usuń elementy",
          onPressed: () {
            ref
                .read(modeProvider.notifier)
                .setEditModeType(EditModeType.removeElements);
          },
          backgroundColor: modeState.editModeType == EditModeType.removeElements
              ? Theme.of(context).colorScheme.secondary
              : Colors.white,
          textColor: modeState.editModeType == EditModeType.removeElements
              ? Colors.white
              : Colors.black,
          fontMin: 14,
          fontMax: 15,
          padding: 2,
        ),
        CustomElevatedButton(
          label: "Przesuń elementy",
          onPressed: () {
            ref
                .read(modeProvider.notifier)
                .setEditModeType(EditModeType.moveElements);
          },
          backgroundColor: modeState.editModeType == EditModeType.moveElements
              ? Theme.of(context).colorScheme.secondary
              : Colors.white,
          textColor: modeState.editModeType == EditModeType.moveElements
              ? Colors.white
              : Colors.black,
          fontMin: 14,
          fontMax: 15,
          padding: 2,
        ),
      ],
    );
  }
}
