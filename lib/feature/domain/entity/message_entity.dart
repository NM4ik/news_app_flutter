import 'package:equatable/equatable.dart';

class MessageEntity extends Equatable {
  final String body;
  final String user;
  final String uid;
  final DateTime dateTime;

  const MessageEntity({required this.body, required this.user, required this.uid, required this.dateTime});

  @override
  List<Object> get props => [body, user, uid, dateTime];
}
