import 'package:news/feature/data/datasource/firestore_data_source.dart';
import 'package:news/feature/data/models/user_model.dart';

import '../models/message_model.dart';
import '../models/news_model.dart';

class FirestoreRepository {
  FirestoreDataSource firestoreDataSource = FirestoreDataSource();

  Future<List<NewsModel>> getAllNews() async => await firestoreDataSource.getAllNews();

  Future<NewsModel> getNews(String doc) async => await firestoreDataSource.getNews(doc);

  Future<List<UserModel>?> getFavoriteUsers(String doc, List<String>? uidArray) async => await firestoreDataSource.getFavoriteUsers(doc, uidArray);

  Future<dynamic> addComment(MessageModel messageModel, String doc) async => await firestoreDataSource.addComment(messageModel, doc);

  Future<List<NewsModel>> getFavoriteNews(String uid) async => await firestoreDataSource.getFavoriteNews(uid);

  Future<void> updateFavorite(String doc, String uid, bool isFavorite) async => await firestoreDataSource.updateFavorite(uid, doc, isFavorite);

  Future<void> updateNews(NewsModel newsModel) async => await firestoreDataSource.updateNews(newsModel);

  Future<String> createNews(NewsModel newsModel) async => await firestoreDataSource.createNews(newsModel);

  Future<void> deleteNews(String doc) async => await firestoreDataSource.deleteNews(doc);

  Future<void> sendComment(String value, String user, String uid, String doc) async => await firestoreDataSource.sendComment(value, user, uid, doc);
}
