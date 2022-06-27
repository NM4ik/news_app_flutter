import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:news/core/debug.dart';
import 'package:news/feature/data/models/message_model.dart';
import 'package:news/feature/data/models/news_model.dart';
import 'package:news/feature/data/models/user_model.dart';

import '../../../locator_service.dart';

class FirestoreDataSource {
  CollectionReference newsCollection = FirebaseFirestore.instance.collection('news');
  CollectionReference usersCollection = FirebaseFirestore.instance.collection('users');

  Future<List<NewsModel>> getAllNews() async {
    try {
      List<NewsModel> newsList = [];
      List<UserModel> favoriteUsers = [];
      final response = await newsCollection.orderBy('date', descending: true).get();

      for (var element in response.docs) {
        newsList.add(NewsModel.fromJson(element.data() as Map<String, dynamic>, element.id));
      }
      return newsList;
    } catch (e) {
      errorPrint(e.toString());
      throw Exception();
    }
  }

  Future<NewsModel> getNews(String doc) async {
    try {
      NewsModel? news;
      final response = await newsCollection.doc(doc).get();
      news = NewsModel.fromJson(response.data() as Map<String, dynamic>, response.id);
      return news;
    } catch (e) {
      errorPrint(e.toString());
      throw Exception();
    }
  }

  Future<List<UserModel>?> getFavoriteUsers(String doc, List<String>? uidArray) async {
    try {
      List<UserModel> favoriteUsers = [];
      if (uidArray!.isNotEmpty) {
        final response = await usersCollection.where('uid', whereIn: uidArray).get();
        response.docs.map((e) => favoriteUsers.add(UserModel.fromJson(e.data() as Map<String, dynamic>))).toList();
      }
      return favoriteUsers;
    } catch (e) {
      errorPrint(e.toString());
      throw Exception();
    }
  }

  Future<void> updateFavorite(String uid, String doc, bool isFavorite) async {
    final List<NewsModel> newsModelList = [];
    final response = await newsCollection.doc(doc).get();
    NewsModel newsModel = NewsModel.fromJson(response.data() as Map<String, dynamic>, response.id);

    if (!isFavorite) {
      log(isFavorite.toString(), name: "TRUE");
      newsModel.favorite?.add(uid);
    } else {
      log(isFavorite.toString(), name: "FALSE");
      newsModel.favorite?.remove(uid);
    }

    await newsCollection.doc(doc).update({'favorite': newsModel.favorite});
  }

  Future<dynamic> addComment(MessageModel messageModel, String doc) async {
    await newsCollection.doc(doc).collection('comments').add(messageModel.toJson()).catchError((e) => print(e));
  }

  Future<List<NewsModel>> getFavoriteNews(String uid) async {
    try {
      List<NewsModel> favoriteNewsList = [];
      final response = await newsCollection.where('favorite', arrayContains: uid).get();
      response.docs.map((e) => favoriteNewsList.add(NewsModel.fromJson(e.data() as Map<String, dynamic>, e.id))).toList();
      return favoriteNewsList;
    } catch (e) {
      errorPrint(e.toString());
      throw Exception();
    }
  }

  Future<void> updateNews(NewsModel newsModel) async {
    try {
      await newsCollection.doc(newsModel.id).update(newsModel.toJson());
    } catch (e) {
      errorPrint(e.toString());
      throw Exception();
    }
  }

  Future<String> createNews(NewsModel newsModel) async {
    try {
      log(newsModel.toJson().toString(), name: "JSON");
      DocumentReference docRef = await newsCollection.add(newsModel.toJson());
      return docRef.id;
    } catch (e) {
      errorPrint(e.toString());
      throw Exception();
    }
  }

  Future<void> deleteNews(String doc) async {
    try {
      await newsCollection.doc(doc).delete();
    } catch (e) {
      errorPrint(e.toString());
      throw Exception();
    }
  }

  Future<void> sendComment(String value, String user, String uid, String doc) async {
    try {
      MessageModel messageModel = MessageModel(body: value, user: user, uid: uid, dateTime: DateTime.now());
      await sl.get<FirestoreDataSource>().addComment(messageModel, doc);
    } catch (e) {
      errorPrint('Error message send');
    }
  }
}
