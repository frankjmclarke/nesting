import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;

Future<String> getAddressFromLatLng(double latitude, double longitude) async {
  final apiKey = dotenv.env['GOOGLE_MAPS_KEY']; // Replace with your Google Maps API key
  final apiUrl =
      'https://maps.googleapis.com/maps/api/geocode/json?latlng=$latitude,$longitude&key=$apiKey';

  final response = await http.get(Uri.parse(apiUrl));
  if (response.statusCode == 200) {
    final jsonResponse = json.decode(response.body);
    final results = jsonResponse['results'];
    if (results.isNotEmpty) {
      final firstResult = results[0];
      final formattedAddress = firstResult['formatted_address'];
      print('ADDR '+formattedAddress );
      return formattedAddress;
    }
  }

  return ''; // Address not found
}

void getAddress(double latitude, double longitude) async {
  try {
    final address = await getAddressFromLatLng(latitude, longitude);
    if (address != '') {
      print('Address: $address');
    } else {
      print('Address not found.');
    }
  } catch (e) {
    print('Error: $e');
  }
}

