import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:news/feature/domain/entity/news_entity.dart';

class NewsModel extends NewsEntity {
  const NewsModel({
    required String? id,
    required DateTime? dateTime,
    required String body,
    required String image,
    required String title,
    List<String>? favorite,
    required String createdBy,
    // List<Map<String, dynamic>>? comments
  }) : super(id: id, dateTime: dateTime, body: body, image: image, title: title, favorite: favorite, createdBy: createdBy);

  factory NewsModel.fromJson(Map<String, dynamic> json, String id) => NewsModel(
        // id: id,
        // dateTime: (json['date'] as Timestamp).toDate(),
        // body: json['body'],
        // image: json['image'],
        // title: json['title'],
        // favorite: json['favorite'],
        id: id,
        dateTime: (json['date'] as Timestamp).toDate(),
        body: json['body'],
        image: json['image'],
        title: json['title'],
        favorite: json['favorite'] == null ? null : List.from(json['favorite']),
        createdBy: json['createdBy'],
      );

  Map<String, dynamic> toJson() => {'body': body, 'createdBy': createdBy, 'date': dateTime, 'favorite': List.from(favorite ?? []), 'image': image, 'title': title};

  NewsModel copyWith({String? createdBy, String? id, DateTime? dateTime, String? body, String? image, String? title, List<String>? favorite}) {
    return NewsModel(
        createdBy: createdBy ?? this.createdBy,
        id: id ?? this.id,
        dateTime: dateTime ?? this.dateTime,
        body: body ?? this.body,
        title: title ?? this.title,
        favorite: favorite ?? this.favorite,
        image: image ?? this.image);
  }
}
