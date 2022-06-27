import 'package:news/feature/data/datasource/storage_data_source.dart';

class StorageRepository{
  final storageDataSource = StorageDataSource();

  Future<String?> uploadFileFromGallery(String doc, String? photoGalleryPath) async => await storageDataSource.uploadFileFromGallery(doc, photoGalleryPath);

  Future<String?> uploadFileFromCamera(String doc, String? photoCameraPath) async => await storageDataSource.uploadFileFromCamera(doc, photoCameraPath);
}