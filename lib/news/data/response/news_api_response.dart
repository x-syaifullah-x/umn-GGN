import 'dart:convert';

import 'package:global_net/news/data/response/model/articel.dart';
import 'package:global_net/news/data/response/model/source.dart';

class NewsApiResponse {
  NewsApiResponse({
    required this.status,
    required this.totalResults,
    required this.articles,
  });
  String status;
  int totalResults;
  List<Artticle> articles;

  factory NewsApiResponse.from(Map<dynamic, dynamic> body) {
    final status = body['status'];
    final totalResults = body['totalResults'];
    final articles = (body['articles'] as List).map((e) {
      return Artticle.from(e);
    });
    return NewsApiResponse(
      status: status,
      totalResults: totalResults,
      articles: articles.toList(),
    );
  }
}
