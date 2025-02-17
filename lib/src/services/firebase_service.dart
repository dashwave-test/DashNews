import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import '../models/news_article.dart';
import '../models/news_category.dart';

class FirebaseService {
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  static Future<List<NewsCategory>> getGNewsCategoriesFuture() async {
    try {
      final QuerySnapshot querySnapshot =
          await _firestore.collection('gnews_categories').get();

      return querySnapshot.docs
          .map((doc) => NewsCategory.fromJson(doc.data() as Map<String, dynamic>))
          .toList();
    } catch (e, stack) {
      FirebaseCrashlytics.instance.recordError(e, stack, reason: 'Error fetching GNews categories');
      rethrow;
    }
  }

  static Future<List<NewsCategory>> getNewsCategoriesFuture() async {
    try {
      final QuerySnapshot querySnapshot =
          await _firestore.collection('news_categories').get();

      return querySnapshot.docs
          .map((doc) => NewsCategory.fromJson(doc.data() as Map<String, dynamic>))
          .toList();
    } catch (e, stack) {
      FirebaseCrashlytics.instance.recordError(e, stack, reason: 'Error fetching news categories');
      rethrow;
    }
  }

  static Future<List<NewsArticle>> getLatestNews({
    required String categoryID,
    String languageCode = 'en',
    String countryCode = 'IN',
    required int count,
    DocumentSnapshot? lastDoc = null,
  }) async {
    try {
      final QuerySnapshot querySnapshot = await _firestore
          .collection('news_articles')
          .where('category', isEqualTo: categoryID)
          .orderBy('timestamp', descending: true)
          .limit(count)
          .get();

      return querySnapshot.docs
          .map((doc) => NewsArticle.fromJson(doc.data() as Map<String, dynamic>))
          .toList();
    } catch (e, stack) {
      FirebaseCrashlytics.instance.recordError(e, stack, reason: 'Error fetching latest news');
      rethrow;
    }
  }

  static Future<({List<NewsArticle> articles, DocumentSnapshot? lastDocument})> getPaginatedNews({
    required String categoryID,
    String languageCode = 'en',
    String countryCode = 'IN',
    int startPage = 0,
    required int count,
    DocumentSnapshot? lastDoc,
  }) async {
    try {
      print("Category ID: $categoryID");
      Query query = _firestore
          .collection('news_articles')
          .where('category', isEqualTo: categoryID)
          .orderBy('timestamp', descending: true)
          .limit(count);

      if (lastDoc != null) {
        query = query.startAfterDocument(lastDoc);
      }

      final QuerySnapshot querySnapshot = await query.get();

      print("Number of documents returned: ${querySnapshot.docs.length}");

      final List<NewsArticle> articles = querySnapshot.docs
          .map((doc) => NewsArticle.fromJson(doc.data() as Map<String, dynamic>))
          .toList();

      final DocumentSnapshot? lastDocument = querySnapshot.docs.isNotEmpty ? querySnapshot.docs.last : null;

      return (articles: articles, lastDocument: lastDocument);
    } catch (e, stack) {
      FirebaseCrashlytics.instance.recordError(e, stack, reason: 'Error fetching paginated news');
      rethrow;
    }
  }

  static Future<List<NewsArticle>> getTrendingNews({
    required String categoryID,
    String languageCode = 'en',
    String countryCode = 'IN',
    int startPage = 0,
    required int count,
  }) async {
    try {
      final QuerySnapshot querySnapshot = await _firestore
          .collection('news_articles')
          .where('category', isEqualTo: categoryID)
          .orderBy('timestamp', descending: true)
          .limit(count)
          .get();

      return querySnapshot.docs
          .map((doc) => NewsArticle.fromJson(doc.data() as Map<String, dynamic>))
          .toList();
    } catch (e, stack) {
      FirebaseCrashlytics.instance.recordError(e, stack, reason: 'Error fetching trending news');
      rethrow;
    }
  }

  static Future<List<NewsArticle>> getBookmarkedNews({
    required List<String> bookmarkedArticleIds,
  }) async {
    try {
      if (bookmarkedArticleIds.isEmpty) {
        return [];
      }

      final QuerySnapshot querySnapshot = await _firestore
          .collection('news_articles')
          .where(FieldPath.documentId, whereIn: bookmarkedArticleIds)
          .get();

      return querySnapshot.docs
          .map((doc) => NewsArticle.fromJson(doc.data() as Map<String, dynamic>))
          .toList();
    } catch (e, stack) {
      FirebaseCrashlytics.instance.recordError(e, stack, reason: 'Error fetching bookmarked news');
      rethrow;
    }
  }

  static Future<List<NewsArticle>> searchNews({
    required String query,
    String languageCode = 'en',
    String countryCode = 'IN',
    int startPage = 0,
    required int count,
  }) async {
    try {
      final QuerySnapshot querySnapshot = await _firestore
          .collection('news_articles')
          .where('title', isGreaterThanOrEqualTo: query)
          .where('title', isLessThan: query + 'z')
          .orderBy('title')
          .orderBy('timestamp', descending: true)
          .limit(count)
          .get();

      return querySnapshot.docs
          .map((doc) => NewsArticle.fromJson(doc.data() as Map<String, dynamic>))
          .toList();
    } catch (e, stack) {
      FirebaseCrashlytics.instance.recordError(e, stack, reason: 'Error searching news');
      rethrow;
    }
  }
}