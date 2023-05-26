import 'package:html/parser.dart' as parser;
import 'package:http/http.dart' as http;

String extractImageUrl(String html) {
  final document = parser.parse(html);
  final imageElement = document.getElementsByTagName('img').first;
  final imageUrl = imageElement.attributes['src'];
  return imageUrl ?? '';
}

Future<String> getImageUrl(String html) async {
  final document = parser.parse(html);
  final images = document.getElementsByTagName('img');

  for (final imageElement in images) {
    final imageUrl = imageElement.attributes['src'];
    print('SSSSSSSS ' + imageUrl.toString());

    if (imageUrl != null) {
      final response = await http.head(Uri.parse(imageUrl));
      final contentLength = response.headers['content-length'];
      final imageSizeInBytes = int.tryParse(contentLength ?? '');
      print("imageSizeInBytes " + imageSizeInBytes.toString());
      if (imageSizeInBytes != null && imageSizeInBytes > 3040) {
        return imageUrl;
      }
    }
  }

  return "";
}
