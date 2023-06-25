import 'dart:convert';
import 'dart:ui';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:super_nonogram/api/image_to_board.dart';
import 'package:super_nonogram/board/board.dart';

abstract class PixabayApi {
  static const apiKey = '25286000-bf7eb8ff8e6d2d1630cf59fae';
  static const maxResults = 5;
  static const baseUrl = 'https://pixabay.com/api/';
  
  static Future<PixabaySearchResults> search(String query) async {
    final url = '$baseUrl'
        '?key=$apiKey'
        '&q=${Uri.encodeQueryComponent(query)}'
        '&colors=transparent'
        '&safesearch=true'
        '&per_page=$maxResults';
    final response = await http.get(Uri.parse(url));
    if (response.statusCode == 200) {
      return PixabaySearchResults.fromJson(jsonDecode(response.body));
    } else {
      throw Exception('Pixabay API error: ${response.statusCode}');
    }
  }

  static Future<(Uint8List?, BoardState?)> getBoardFromSearch(String query) async {
    final searchResults = await search(query);
    for (final image in searchResults.images) {
      if (kDebugMode) print('Trying to import image ${image.id} from ${image.webformatUrl}');

      final response = await http.get(Uri.parse(image.webformatUrl));
      if (response.statusCode != 200) {
        throw Exception('Pixabay image download error: ${response.statusCode}');
      }

      final board = await ImageToBoard.importFromBytes(response.bodyBytes);
      if (board != null) return (response.bodyBytes, board);
    }
    return (null, null);
  }
}

class PixabaySearchResults {
  final int total;
  final int totalHits;
  final List<PixabayImage> images;

  PixabaySearchResults._({
    required this.total,
    required this.totalHits,
    required this.images,
  });

  factory PixabaySearchResults.fromJson(Map<String, dynamic> json) {
    final images = <PixabayImage>[];
    for (final imageJson in json['hits']) {
      images.add(PixabayImage.fromJson(imageJson));
    }
    return PixabaySearchResults._(
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
