import 'dart:convert';

class NewsArticle {
  final String? title;
  final String? snippet;
  final String? publisher;
  final String? category;
  final String? timestamp;
  final String? newsUrl;
  final Map<String, String>? images;
  final int? fetchedAt;
  final bool? hasSubnews;
  final List<NewsArticle>? subnews;

  NewsArticle({
    this.title,
    this.snippet,
    this.publisher,
    this.category,
    this.timestamp,
    this.newsUrl,
    this.images,
    this.fetchedAt,
    this.hasSubnews,
    this.subnews,
  });

  factory NewsArticle.fromJson(Map<String, dynamic> json) {
    return NewsArticle(
      title: json['title'],
      snippet: json['snippet'],
      publisher: json['publisher'],
      category: json['category'],
      timestamp: json['timestamp'],
      newsUrl: json['newsUrl'],
      images: json['images'] != null ? Map<String, String>.from(json['images']) : null,
      fetchedAt: json['fetched_at'],
      hasSubnews: json['hasSubnews'],
      subnews: json['subnews'] != null
          ? List<NewsArticle>.from(json['subnews'].map((x) => NewsArticle.fromJson(x)))
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'snippet': snippet,
      'publisher': publisher,
      'category': category,
      'timestamp': timestamp,
      'newsUrl': newsUrl,
      'images': images,
      'fetched_at': fetchedAt,
      'hasSubnews': hasSubnews,
      'subnews': subnews?.map((x) => x.toJson()).toList(),
    };
  }
}