import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';

class StorageDataSource {
  Future<String?> uploadFileFromCamera(String doc, String? photoCameraPath) async {
    if (photoCameraPath == null) return null;
    final file = File(photoCameraPath);
    final fireStoragePath = doc;

    final ref = FirebaseStorage.instance.ref().child(fireStoragePath);
    UploadTask? uploadTask = ref.putFile(file);

    final snapshot = await uploadTask.whenComplete(() {});
    final urlDownload = await snapshot.ref.getDownloadURL();
    await FirebaseFirestore.instance.collection('news').doc(doc).update({
      'image': urlDownload,
    });

    return urlDownload;
  }

  Future<String?> uploadFileFromGallery(String doc, String? photoGalleryPath) async {
    if (photoGalleryPath == null) return null;
    final file = File(photoGalleryPath);
    final fireStoragePath = doc;

    final ref = FirebaseStorage.instance.ref().child(fireStoragePath);
    UploadTask? uploadTask = ref.putFile(file);

    final snapshot = await uploadTask.whenComplete(() {});

    final urlDownload = await snapshot.ref.getDownloadURL();

    await FirebaseFirestore.instance.collection('news').doc(doc).update({
      'image': urlDownload,
    });

    return urlDownload;
  }
}
