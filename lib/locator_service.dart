import 'package:get_it/get_it.dart';
import 'package:news/feature/data/datasource/firestore_data_source.dart';
import 'package:news/feature/data/repository/authentication_repository.dart';
import 'package:news/feature/data/repository/firestore_repository.dart';
import 'package:news/feature/data/repository/storage_repository.dart';
import 'package:news/feature/data/repository/user_repository.dart';
import 'package:news/feature/presentation/state/authentication_state.dart';

GetIt sl = GetIt.instance;

Future<void> init() async {
  sl.registerLazySingleton<FirestoreDataSource>(() => FirestoreDataSource());
  sl.registerLazySingleton<AuthenticationRepository>(() => AuthenticationRepository());
  sl.registerLazySingleton<UserRepository>(() => UserRepository());
  sl.registerLazySingleton<AuthenticationState>(() => AuthenticationState());
  sl.registerLazySingleton<FirestoreRepository>(() => FirestoreRepository());
  sl.registerLazySingleton<StorageRepository>(() => StorageRepository());
}
