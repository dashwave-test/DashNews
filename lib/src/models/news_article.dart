import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';

/// Represents a news article with its properties and metadata.
class NewsArticle {
  /// The unique identifier from Firestore document
  final String? docID;

  /// The title/headline of the news article
  final String? title;

  /// A brief summary or excerpt of the article content
  final String? snippet;

  /// The name of the news publisher/source
  final String? publisher;

  /// The category/section the article belongs to (e.g., 'politics', 'technology')
  final String? category;

  /// The timestamp when the article was published
  final String? timestamp;

  /// The URL to the full article
  final String? newsUrl;

  /// A map containing different versions of article images (e.g., thumbnail, full)
  final Map<String, String>? images;

  /// The timestamp when the article was fetched/cached
  final int? fetchedAt;

  /// Indicates if the article has related sub-articles
  final bool? hasSubnews;

  /// List of related sub-articles
  final List<NewsArticle>? subnews;

  /// Creates a new [NewsArticle] instance
  NewsArticle({
    this.docID,
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

  /// Creates a [NewsArticle] from a JSON map
  factory NewsArticle.fromJson(Map<String, dynamic> json, {String? id}) {
    return NewsArticle(
      docID: id ?? json['docID'],
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

  /// Converts the [NewsArticle] instance to a JSON map
  Map<String, dynamic> toJson() {
    return {
      'docID': docID,
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

/// Extension on [NewsArticle] to add Firestore-related functionality
extension NewsArticleFirestore on NewsArticle {
  /// Creates a [NewsArticle] from a Firestore DocumentSnapshot
  static NewsArticle fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>?;
    if (data == null) return NewsArticle();
    return NewsArticle.fromJson(data, id: doc.id);
  }
}