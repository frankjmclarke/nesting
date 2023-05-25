import 'package:html/parser.dart' as parser;
import 'package:html/dom.dart' as dom;
/*
String? parseAddress(String htmlContent) {
  final document = htmlParser.parse(htmlContent);
  final addressElement = document.querySelector('address');
  if (addressElement != null) {
    String addressText = addressElement.text;
    String? canadaAddress = extractCanadaAddress(addressText);
    return canadaAddress;
  } else {
    String? canadaAddress = searchForCanadaAddress(htmlContent);
    return canadaAddress;
  }
}*/

String? extractCanadaAddress(String addressText) {
  // Apply your address extraction logic here
  // You can use string manipulation or regular expressions to extract the Canadian address
  // This is just a simple example, you may need to modify it based on your specific use case

  /*
  ^[ABCEGHJ-NPRSTVXY][0-9][ABCEGHJ-NPRSTV-Z][ ]?[0-9][ABCEGHJ-NPRSTV-Z][0-9]$
  */

  RegExp canadaAddressRegex = RegExp(
      r'(\d+)\s+([A-Za-z]+\s+){1,5}(Street|Avenue|Road|Boulevard)\s*,\s*([A-Za-z\s]+)\s*(,|,)\s*([A-Za-z\s]+)\s*(\w{1}\d{1}\w{1}\s*\d{1}\w{1}\d{1})');
  Match? match = canadaAddressRegex.firstMatch(addressText);
  if (match != null) {
    String streetNumber = match.group(1)!;
    String streetName = match.group(2)!;
    String city = match.group(4)!;
    String province = match.group(6)!;
    String postalCode = match.group(7)!;

    return '$streetNumber $streetName, $city, $province, $postalCode';
  }

  return null;
}

String? searchForCanadaAddress(String htmlContent) {
  // Apply your search logic here to find the address within the HTML content
  // You can use string manipulation or regular expressions to search for the address
  // This is just a simple example, you may need to modify it based on your specific use case

  RegExp canadaAddressRegex = RegExp(
      r'(\d+)\s+([A-Za-z]+\s+){1,5}(Street|Avenue|Road|Boulevard)\s*,\s*([A-Za-z\s]+)\s*(,|,)\s*([A-Za-z\s]+)\s*(\w{1}\d{1}\w{1}\s*\d{1}\w{1}\d{1})');
  Match? match = canadaAddressRegex.firstMatch(htmlContent);
  if (match != null) {
    String streetNumber = match.group(1)!;
    String streetName = match.group(2)!;
    String city = match.group(4)!;
    String province = match.group(6)!;
    String postalCode = match.group(7)!;

    return '$streetNumber $streetName, $city, $province, $postalCode';
  }

  return null;
}

void parseAddressSimple(String text) {
  // Split the text into individual words
  List<String> words = text.split(' ');

  // Search for keywords indicating a street address
  String streetAddress = '';
  int addressIndex = -1;
  for (int i = 0; i < words.length; i++) {
    String word = words[i];

    if (isNumeric(removeHyphens(word)) &&
        i < words.length - 2 &&
        isStreetIdentifier(words[i + 2])) {
      // Found a numeric value followed by a street identifier (e.g., 123 Main)
      streetAddress = word + ' ' + words[i + 1] + ' ' + words[i + 2];
      addressIndex = i;
      break;
    }
  }

  // Extract the city based on the words after the street address
  String city = '';
  if (addressIndex != -1 && addressIndex < words.length - 3) {
    city = words[addressIndex + 3];
  }

  // Print the extracted address details
  if (streetAddress.isNotEmpty) {
    print('Street Address: $streetAddress');
  } else {
    print('No street address found');
  }

  if (city.isNotEmpty) {
    print('City: $city');
  } else {
    print('No city found');
  }
}

String removeMultipleSpaces(String text) {
  return text.replaceAll(RegExp(r'\s+'), ' ');
}

String replaceSpacesWithHyphen(String text) {
  // Split the text into individual words
  List<String> words = text.split(' ');

  // Iterate through the words to find adjacent numbers
  for (int i = 0; i < words.length - 1; i++) {
    String currentWord = words[i];
    String nextWord = words[i + 1];
    //  print (currentWord);

    // Check if the current word and the next word are numeric
    if (isNumeric(removeHyphens(currentWord)) && isNumeric(nextWord)) {
      // Replace the space between the numbers with a hyphen
      words[i] = currentWord.trimRight() + '-' + nextWord;
      // print(currentWord.trimRight() + '-' + nextWord);
      // print( nextWord);
      words.removeAt(i + 1);
    }
  }

  // Join the words back into a single string
  String result = words.join(' ');

  return result;
}

String removeHyphens(String text) {
  return text.replaceAll('-', '');
}

bool isNumeric(String value) {
  final numericRegex = RegExp(r'^-?(([0-9]*)|(([0-9]*)\.([0-9]*)))$');
  return numericRegex.hasMatch(value);
}

bool isStreetIdentifier(String value) {
  final streetIdentifiers = [
    'Street',
    'St',
    'Highway',
    'Hwy',
    'Avenue',
    'Ave',
    'Road',
    'Rd',
    'Boulevard',
    'Blv.',
    'Lane',
    'L.',
    'Place',
    'Pl',
    'Court',
    'Ct'
  ];
  return streetIdentifiers.contains(value);
}

String removePunctuation(String input) {
  return input.replaceAll(RegExp(r'[^\w\s]'), '');
}

////////////////////////////
Future<String> getLocationFromHTML(String htmlContent) async {
  final document = parser.parse(htmlContent);
  final scriptTags = document.getElementsByTagName('script');

  for (dom.Element scriptTag in scriptTags) {
    final scriptContent = scriptTag.innerHtml;

    if (scriptContent.contains('LatLng')) {
      // Extract the LatLng information from the script content
      final regex = RegExp(r'LatLng\(([^)]+)\)');
      final match = regex.firstMatch(scriptContent);
      if (match != null) {
        final latLng = match.group(1);

        // Split the LatLng into latitude and longitude
        final coordinates = latLng?.split(',');
        final latitude = coordinates?[0].trim();
        final longitude = coordinates?[1].trim();
        print('Latitude: $latitude, Longitude: $longitude');
        return 'Latitude: $latitude, Longitude: $longitude';
      }
    }
  }
  print('ZZZZZZZZZZZZZZZZZZZ');
  return ''; // Location not found
}
String findLatitude(String inputString) {
  final longitudeIndex = inputString.indexOf("data-latitude");
  if (longitudeIndex != -1) {
    final quoteIndex = inputString.indexOf('"', longitudeIndex);
    if (quoteIndex != -1) {
      final startingIndex = quoteIndex + 1;
      final endingIndex = inputString.indexOf('"', startingIndex);
      if (endingIndex != -1) {
        final longitude = inputString.substring(startingIndex, endingIndex);
        return longitude;
      }
    }
  }
  return 'XXXXXXXXXXXXXX'; // Longitude not found
}

String findLongitude(String inputString) {
  final longitudeIndex = inputString.indexOf("data-longitude");
  if (longitudeIndex != -1) {
    final quoteIndex = inputString.indexOf('"', longitudeIndex);
    if (quoteIndex != -1) {
      final startingIndex = quoteIndex + 1;
      final endingIndex = inputString.indexOf('"', startingIndex);
      if (endingIndex != -1) {
        final longitude = inputString.substring(startingIndex, endingIndex);
        return longitude;
      }
    }
  }
  return 'XXXXXXXXXXXXXX'; // Longitude not found
}

void getLocationFromHTMLFile(String htmlContent) async {
  try {
    final location = await getLocationFromHTML(htmlContent);
    print(location);
  } catch (e) {
    print('Error: $e');
  }
}
