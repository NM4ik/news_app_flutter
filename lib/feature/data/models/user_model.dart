import 'package:firebase_auth/firebase_auth.dart';

import '../../domain/entity/user_entity.dart';

class UserModel extends UserEntity {
  const UserModel({required String uid, required String email, required String phone, required String photoUrl, required String displayName})
      : super(uid: uid, email: email, phone: phone, photoUrl: photoUrl, displayName: displayName);

  factory UserModel.fromJson(Map<String, dynamic> json) =>
      UserModel(uid: json['uid'], email: json['email'] ?? '', phone: json['phone'] ?? '', photoUrl: json['photoUrl'] ?? '', displayName: json['name']);

  Map<String, dynamic> toJson() {
    return {'uid': uid, 'email': email, 'phone': phone, 'photoUrl': photoUrl, 'name': displayName};
  }

  UserModel copyWith({String? uid, String? email, String? phone, String? photoUrl, String? displayName}) {
    return UserModel(
        uid: uid ?? this.uid,
        email: email ?? this.email,
        phone: phone ?? this.phone,
        photoUrl: photoUrl ?? this.photoUrl,
        displayName: displayName ?? this.displayName);
  }

  factory UserModel.toUser(User user) {
    return UserModel(uid: user.uid, phone: user.phoneNumber ?? '', photoUrl: user.photoURL ?? '', email: user.email ?? '', displayName: user.displayName ?? '');
  }
}
