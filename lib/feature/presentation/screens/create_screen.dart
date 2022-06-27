import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:news/common/app_colors.dart';
import 'package:news/core/debug.dart';
import 'package:news/core/toast_notifications.dart';
import 'package:news/feature/data/models/news_model.dart';
import 'package:news/feature/data/repository/firestore_repository.dart';
import 'package:news/feature/data/repository/storage_repository.dart';
import 'package:news/feature/presentation/screens/news_screen.dart';
import 'package:news/feature/presentation/state/authentication_state.dart';
import 'package:news/feature/presentation/widgets/app_bar_widget.dart';
import 'package:news/feature/presentation/widgets/default_button_widget.dart';
import 'package:news/feature/presentation/widgets/route_animation.dart';
import 'package:news/feature/presentation/widgets/text_field_widget.dart';
import 'package:news/locator_service.dart';

import '../../../common/app_variables.dart';

class CreateScreen extends StatefulWidget {
  const CreateScreen({Key? key, required this.newsModel}) : super(key: key);
  final NewsModel? newsModel;

  @override
  State<CreateScreen> createState() => _CreateScreenState();
}

class _CreateScreenState extends State<CreateScreen> {
  TextEditingController titleController = TextEditingController();
  TextEditingController descriptionController = TextEditingController();
  String? photoCameraPath;
  String? photoGalleryPath;

  final currentUser = sl.get<AuthenticationState>().currentUser;
  late String appBarTitle;
  late String buttonTitle;

  @override
  void initState() {
    if (widget.newsModel != null) {
      titleController.text = widget.newsModel!.title;
      descriptionController.text = widget.newsModel!.body;
      photoGalleryPath = widget.newsModel?.image;

      appBarTitle = 'Редактирование';
      buttonTitle = 'Обновить';
    } else {
      appBarTitle = 'Создание новости';
      buttonTitle = 'Создать';
    }
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final entity = widget.newsModel;

    return Scaffold(
      backgroundColor: AppColors.scaffoldBackgroundColor,
      appBar: PreferredSize(preferredSize: const Size.fromHeight(60), child: AppBarWidget(title: appBarTitle)),
      body: SafeArea(
        minimum: const EdgeInsets.symmetric(vertical: AppVariables.kEdgeVerticalPadding, horizontal: AppVariables.kEdgeHorizontalPadding),
        child: Column(
          children: [
            TextFieldWidget(controller: titleController, title: 'Название новости'),
            const SizedBox(
              height: AppVariables.kEdgeVerticalPadding,
            ),
            TextFieldWidget(controller: descriptionController, title: 'Содержание новости'),
            Padding(
              padding: const EdgeInsets.symmetric(
                vertical: AppVariables.kEdgeVerticalPadding,
              ),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _downloadImageButton('Загрузить с камеры', Icons.camera_alt_rounded, () => _selectFileFromCamera()),
                      _downloadImageButton('Загрузить с галереи', Icons.memory, () async => await _selectFile()),
                    ],
                  ),
                  Text(
                    photoCameraPath ?? photoGalleryPath ?? '',
                    style: Theme.of(context).textTheme.bodyText2,
                  ),
                ],
              ),
            ),
            DefaultButtonWidget(function: () => _updateNews(entity), title: buttonTitle),
          ],
        ),
      ),
    );
  }

  Future<void> _selectFileFromCamera() async {
    final image = await ImagePicker.platform.getImage(source: ImageSource.camera);
    setState(() {
      photoCameraPath = File(image!.path).path;
      photoGalleryPath = null;
    });
  }

  Future<void> _selectFile() async {
    final result = await FilePicker.platform.pickFiles();
    if (result == null) return;

    setState(() {
      photoGalleryPath = result.files.first.path;
      photoCameraPath = null;
    });
  }

  void _updateNews(NewsModel? entity) async {
    if (titleController.text.isEmpty || descriptionController.text.isEmpty || photoCameraPath == null && photoGalleryPath == null) {
      BotToastNotification.showInfo('Название, описание или изображение новости не может быть пустым...');
      return;
    }
    try {
      if (entity == null) {
        NewsModel newsModel = NewsModel(
          id: null,
          dateTime: DateTime.now(),
          body: descriptionController.text,
          image: 'image',
          title: titleController.text,
          createdBy: currentUser!.uid,
        );

        final snapshot = await sl.get<FirestoreRepository>().createNews(newsModel);
        photoGalleryPath == null
            ? await sl.get<StorageRepository>().uploadFileFromCamera(snapshot, photoCameraPath)
            : await sl.get<StorageRepository>().uploadFileFromGallery(snapshot, photoGalleryPath);
        BotToastNotification.showInfo('Новость успешно создана');
      } else {
        NewsModel newsModel = entity.copyWith(title: titleController.text, body: descriptionController.text);
        await sl.get<FirestoreRepository>().updateNews(newsModel);
        photoGalleryPath == null
            ? await sl.get<StorageRepository>().uploadFileFromCamera(newsModel.id!, photoCameraPath)
            : await sl.get<StorageRepository>().uploadFileFromGallery(newsModel.id!, photoGalleryPath);
        BotToastNotification.showInfo('Новость успешно обновлена');
      }
      Navigator.of(context).pushAndRemoveUntil(createRouteAnimFromBottom(const NewsScreen()), (route) => false);
    } catch (e) {
      Navigator.of(context).pushAndRemoveUntil(createRouteAnimFromBottom(const NewsScreen()), (route) => false);
      errorPrint(e.toString());
    }
  }

  _downloadImageButton(String title, IconData icon, VoidCallback callback) => GestureDetector(
        onTap: callback,
        child: Row(
          children: [
            Icon(
              icon,
              color: Colors.white,
            ),
            const SizedBox(
              width: AppVariables.kEdgeHorizontalPadding / 5,
            ),
            Text(
              title,
              style: Theme.of(context).textTheme.bodyText2,
            ),
          ],
        ),
      );
}
