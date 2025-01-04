import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/petriNet.dart';

class PetriNetRepository {
  final String baseUrl;

  PetriNetRepository(this.baseUrl);

  Future<PetriNet> fetchPetriNet() async {
    final response = await http.get(Uri.parse('$baseUrl/api/get-data'));
    if (response.statusCode == 200) {
      return PetriNet.fromJson(jsonDecode(response.body));
    } else {
      throw Exception('Failed to fetch PetriNet data');
    }
  }

  Future<void> sendPetriNet(PetriNet petriNet) async {
    final response = await http.post(
      Uri.parse('$baseUrl/api/analyze-data'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(petriNet.toJson()),
    );
    if (response.statusCode != 200) {
      throw Exception('Failed to send PetriNet data');
    }
  }
}
