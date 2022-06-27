import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:news/feature/domain/entity/message_entity.dart';

class MessageModel extends MessageEntity {
  const MessageModel({required String body, required String user, required String uid, required DateTime dateTime})
      : super(body: body, user: user, uid: uid, dateTime: dateTime);

  Map<String, dynamic> toJson() {
    return {'body': body, 'date': dateTime, 'uid': uid, 'user': user};
  }

  factory MessageModel.fromJson(Map<String, dynamic> json) =>
      MessageModel(body: json['body'], user: json['user'], uid: json['uid'], dateTime: (json['date'] as Timestamp).toDate());
}
