import 'dart:convert';
import 'dart:ui';

import 'package:http/http.dart' as http;

abstract class PixabayApi {
  static const apiKey = '25286000-bf7eb8ff8e6d2d1630cf59fae';
  static const maxResults = 3;
  static const baseUrl = 'https://pixabay.com/api/';
  
  static Future<PixabayResponse> search(String query) async {
    final url = '$baseUrl'
        '?key=$apiKey'
        '&q=${Uri.encodeQueryComponent(query)}'
        '&image_type=vector'
        '&colors=transparent'
        '&safesearch=true'
        '&per_page=$maxResults';
    final response = await http.get(Uri.parse(url));
    if (response.statusCode == 200) {
      return PixabayResponse.fromJson(jsonDecode(response.body));
    } else {
      throw Exception('Pixabay API error: ${response.statusCode}');
    }
  }
}

class PixabayResponse {
  final int total;
  final int totalHits;
  final List<PixabayImage> images;

  PixabayResponse._({
    required this.total,
    required this.totalHits,
    required this.images,
  });

  factory PixabayResponse.fromJson(Map<String, dynamic> json) {
    final images = <PixabayImage>[];
    for (final imageJson in json['hits']) {
      images.add(PixabayImage.fromJson(imageJson));
    }
    return PixabayResponse._(
      total: json['total'],
      totalHits: json['totalHits'],
      images: images,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'total': total,
      'totalHits': totalHits,
      'images': images,
    };
  }
}

class PixabayImage {
  final int id;
  final String pageUrl;

  final String previewUrl;
  final Size previewSize;

  final String webformatUrl;
  final Size webformatSize;

  const PixabayImage._({
    required this.id,
    required this.pageUrl,
    required this.previewUrl,
    required this.previewSize,
    required this.webformatUrl,
    required this.webformatSize,
  });
  
  factory PixabayImage.fromJson(Map<String, dynamic> json) {
    return PixabayImage._(
      id: json['id'],
      pageUrl: json['pageURL'],
      previewUrl: json['previewURL'],
      previewSize: Size(
        json['previewWidth'].toDouble(),
        json['previewHeight'].toDouble(),
      ),
      webformatUrl: json['webformatURL'],
      webformatSize: Size(
        json['webformatWidth'].toDouble(),
        json['webformatHeight'].toDouble(),
      ),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'pageURL': pageUrl,
      'previewURL': previewUrl,
      'previewWidth': previewSize.width,
      'previewHeight': previewSize.height,
      'webformatURL': webformatUrl,
      'webformatWidth': webformatSize.width,
      'webformatHeight': webformatSize.height,
    };
  }
}