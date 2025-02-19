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
          .map((doc) => NewsArticleFirestore.fromFirestore(doc))
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

  static Future<void> addBookmark({
    required String userID,
    required String newsID,
  }) async {
    try {
      await _firestore.collection('bookmarks').add({
        'userID': userID,
        'newsID': newsID,
        'bookmarkedAt': FieldValue.serverTimestamp(),
      });
    } catch (e, stack) {
      FirebaseCrashlytics.instance.recordError(e, stack, reason: 'Error adding bookmark');
      rethrow;
    }
  }

  static Future<void> removeBookmark({
    required String userID,
    required String newsID,
  }) async {
    try {
      print("userID: $userID\n newsID: $newsID");
      final QuerySnapshot querySnapshot = await _firestore
          .collection('bookmarks')
          .where('userID', isEqualTo: userID)
          .where('newsID', isEqualTo: newsID)
          .limit(1)
          .get();

      if (querySnapshot.docs.isNotEmpty) {
        await querySnapshot.docs.first.reference.delete();
      }
    } catch (e, stack) {
      print("Remove bookmark error: $e");
      FirebaseCrashlytics.instance.recordError(e, stack, reason: 'Error removing bookmark');
      rethrow;
    }
  }

  static Future<List<String>> getAllBookmarkIDs({
    required String userID,
  }) async {
    try {
      final QuerySnapshot bookmarkSnapshot = await _firestore
          .collection('bookmarks')
          .where('userID', isEqualTo: userID)
          .orderBy('bookmarkedAt', descending: true)
          .get();

      return bookmarkSnapshot.docs
          .map((doc) => (doc.data() as Map<String, dynamic>)['newsID'] as String)
          .toList();
    } catch (e, stack) {
      FirebaseCrashlytics.instance.recordError(e, stack, reason: 'Error fetching bookmark IDs');
      rethrow;
    }
  }

  static Future<List<NewsArticle>> getAllBookmarks({
    required String userID,
  }) async {
    try {
      final List<String> bookmarkedNewsIDs = await getAllBookmarkIDs(userID: userID);

      if (bookmarkedNewsIDs.isEmpty) {
        return [];
      }

      final QuerySnapshot newsSnapshot = await _firestore
          .collection('news_articles')
          .where(FieldPath.documentId, whereIn: bookmarkedNewsIDs)
          .get();

      final Map<String, NewsArticle> newsMap = {
        for (var doc in newsSnapshot.docs)
          doc.id: NewsArticleFirestore.fromFirestore(doc)
      };

      // Preserve the order of bookmarks
      return bookmarkedNewsIDs
          .map((id) => newsMap[id])
          .whereType<NewsArticle>()
          .toList();
    } catch (e, stack) {
      FirebaseCrashlytics.instance.recordError(e, stack, reason: 'Error fetching all bookmarks');
      rethrow;
    }
  }
}