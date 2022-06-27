import 'package:equatable/equatable.dart';

class UserEntity extends Equatable {
  final String uid;
  final String displayName;
  final String email;
  final String phone;
  final String photoUrl;

  const UserEntity({required this.uid, required this.email, required this.phone, required this.photoUrl, required this.displayName});

  @override
  List<Object> get props => [uid, email, phone, photoUrl, displayName];
}
