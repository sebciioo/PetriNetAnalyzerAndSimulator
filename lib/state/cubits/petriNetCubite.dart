import 'package:flutter_bloc/flutter_bloc.dart';
import '../../data/repositories/petriNetRepository.dart';
import '../../data/models/petriNet.dart';

class PetriNetCubit extends Cubit<PetriNet?> {
  final PetriNetRepository repository;

  PetriNetCubit(this.repository) : super(null);

  void loadPetriNet() async {
    try {
      final petriNet = await repository.fetchPetriNet();
      emit(petriNet);
    } catch (e) {
      emit(null); //
    }
  }

  void updatePetriNet(PetriNet petriNet) async {
    try {
      await repository.sendPetriNet(petriNet);
      emit(petriNet);
    } catch (e) {
      emit(state);
    }
  }
}
