import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:super_nonogram/api/api.dart';

void main() {
  test('Pixabay API response parsing', () {
    final PixabayResponse response = PixabayResponse.fromJson(jsonDecode(_apiResponse));
    expect(response.total, 4692);
    expect(response.totalHits, 500);
    expect(response.images.length, 1);

    final PixabayImage image = response.images.first;
    expect(image.id, 195893);
    expect(image.pageUrl, 'https://pixabay.com/en/blossom-bloom-flower-195893/');
    expect(image.previewUrl, 'https://cdn.pixabay.com/photo/2013/10/15/09/12/flower-195893_150.jpg');
    expect(image.previewSize, const Size(150, 84));
    expect(image.webformatUrl, 'https://pixabay.com/get/35bbf209e13e39d2_640.jpg');
    expect(image.webformatSize, const Size(640, 360));
  });
}

/// This is the example API response from Pixabay:
/// https://pixabay.com/api/docs/
const String _apiResponse = '''
{
  "total": 4692,
  "totalHits": 500,
  "hits": [
    {
      "id": 195893,
      "pageURL": "https://pixabay.com/en/blossom-bloom-flower-195893/",
      "type": "photo",
      "tags": "blossom, bloom, flower",
      "previewURL": "https://cdn.pixabay.com/photo/2013/10/15/09/12/flower-195893_150.jpg",
      "previewWidth": 150,
      "previewHeight": 84,
      "webformatURL": "https://pixabay.com/get/35bbf209e13e39d2_640.jpg",
      "webformatWidth": 640,
      "webformatHeight": 360,
      "largeImageURL": "https://pixabay.com/get/ed6a99fd0a76647_1280.jpg",
      "fullHDURL": "https://pixabay.com/get/ed6a9369fd0a76647_1920.jpg",
      "imageURL": "https://pixabay.com/get/ed6a9364a9fd0a76647.jpg",
      "imageWidth": 4000,
      "imageHeight": 2250,
      "imageSize": 4731420,
      "views": 7671,
      "downloads": 6439,
      "likes": 5,
      "comments": 2,
      "user_id": 48777,
      "user": "Josch13",
      "userImageURL": "https://cdn.pixabay.com/user/2013/11/05/02-10-23-764_250x250.jpg"
    }
	]
}
''';
