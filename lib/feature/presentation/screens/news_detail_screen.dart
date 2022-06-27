import 'package:bubble/bubble.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';
import 'package:news/common/app_colors.dart';
import 'package:news/common/app_variables.dart';
import 'package:news/core/toast_notifications.dart';
import 'package:news/feature/data/models/message_model.dart';
import 'package:news/feature/data/models/news_model.dart';
import 'package:news/feature/data/repository/firestore_repository.dart';
import 'package:news/feature/presentation/screens/create_screen.dart';
import 'package:news/feature/presentation/screens/news_screen.dart';
import 'package:news/feature/presentation/state/authentication_state.dart';
import 'package:news/feature/presentation/widgets/loading_widget.dart';
import 'package:news/locator_service.dart';
import 'package:provider/provider.dart';

import '../../data/models/user_model.dart';
import '../widgets/route_animation.dart';

class NewsDetailScreen extends StatefulWidget {
  const NewsDetailScreen({Key? key, required this.doc, required this.userUid}) : super(key: key);
  final String doc;
  final String userUid;

  @override
  State<NewsDetailScreen> createState() => _NewsDetailScreenState();
}

class _NewsDetailScreenState extends State<NewsDetailScreen> {
  final TextEditingController _commentController = TextEditingController();
  int counter = 3;
  bool isFavorite = false;

  @override
  Widget build(BuildContext context) {
    final currentUser = Provider.of<AuthenticationState>(context).currentUser;
    List<MessageModel> messages = [];

    return Scaffold(
      backgroundColor: AppColors.scaffoldBackgroundColor,
      body: FutureBuilder(
        future: sl.get<FirestoreRepository>().getNews(widget.doc),
        builder: (context, AsyncSnapshot<NewsModel> snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: LoadingWidget(),
            );
          }
          if (snapshot.hasData && snapshot.connectionState == ConnectionState.done) {
            final entity = snapshot.data!;
            entity.favorite?.forEach((element) {
              if (element == widget.userUid) {
                isFavorite = true;
              } else {
                isFavorite = false;
              }
            });

            return SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Stack(children: [
                    ClipRRect(
                      borderRadius: const BorderRadius.vertical(bottom: Radius.circular(24)),
                      child: CachedNetworkImage(
                        imageUrl: entity.image,
                        fit: BoxFit.cover,
                        width: double.infinity,
                        height: MediaQuery.of(context).size.height / 2,
                        colorBlendMode: BlendMode.darken,
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: AppVariables.kEdgeHorizontalPadding, vertical: AppVariables.kEdgeVerticalPadding * 2),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              GestureDetector(
                                  onTap: () => Navigator.of(context).pop(),
                                  child: const Icon(
                                    Icons.arrow_back_ios_new_rounded,
                                    color: Colors.white,
                                  )),
                              const Spacer(),
                              currentUser!.uid == entity.createdBy
                                  ? Row(
                                      children: [
                                        GestureDetector(
                                            onTap: () => Navigator.of(context).push(createRouteAnimFromBottom(CreateScreen(newsModel: entity))),
                                            child: const Icon(
                                              Icons.edit_rounded,
                                              color: Colors.white,
                                            )),
                                        const SizedBox(
                                          width: AppVariables.kEdgeHorizontalPadding,
                                        ),
                                        GestureDetector(
                                            onTap: () => _deleteConfirmDialog(entity.id!, context),
                                            child: const Icon(
                                              Icons.delete_outline_rounded,
                                              color: Colors.white,
                                            )),
                                      ],
                                    )
                                  : Container(),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ]),
                  SafeArea(
                      minimum: const EdgeInsets.symmetric(vertical: AppVariables.kEdgeVerticalPadding, horizontal: AppVariables.kEdgeHorizontalPadding),
                      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Flexible(
                              child: Text(
                                entity.title,
                                style: Theme.of(context).textTheme.headline2,
                              ),
                            ),
                            const SizedBox(
                              width: 10,
                            ),
                            GestureDetector(
                              onTap: () async {
                                await sl.get<FirestoreRepository>().updateFavorite(entity.id!, currentUser.uid, isFavorite);
                                setState(() {
                                  isFavorite = !isFavorite;
                                });
                                if (!isFavorite) {
                                  BotToastNotification.showInfo('Новость убрана из понравившихся');
                                } else {
                                  BotToastNotification.showInfo('Новость добавлена в понравившиеся');
                                }
                              },
                              onLongPress: () async {
                                final users = await sl.get<FirestoreRepository>().getFavoriteUsers(entity.id!, entity.favorite);
                                _showFavoriteUsersModal(users);
                              },
                              child: Icon(
                                isFavorite ? Icons.favorite : Icons.favorite_border_rounded,
                                color: isFavorite ? Colors.red : Colors.white,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(
                          height: AppVariables.kEdgeVerticalPadding / 4,
                        ),
                        Text(
                          DateFormat.MMMEd('ru').format(entity.dateTime!),
                          style: Theme.of(context).textTheme.bodyText2,
                        ),
                        const SizedBox(
                          height: AppVariables.kEdgeVerticalPadding / 1.5,
                        ),
                        Text(entity.body),
                        const SizedBox(
                          height: AppVariables.kEdgeVerticalPadding,
                        ),
                        Text(
                          'Комментарии к новости: ',
                          style: Theme.of(context).textTheme.headline2,
                        ),
                        Padding(
                          padding: const EdgeInsets.only(top: AppVariables.kEdgeVerticalPadding),
                          child: StreamBuilder<QuerySnapshot>(
                              stream: FirebaseFirestore.instance
                                  .collection('news')
                                  .doc(entity.id)
                                  .collection('comments')
                                  .orderBy('date', descending: true)
                                  .limit(counter)
                                  .snapshots(),
                              builder: (context, snapshot) {
                                if (snapshot.connectionState == ConnectionState.waiting) {
                                  return const LoadingWidget();
                                }
                                if (!snapshot.hasData) {
                                  const Text('Комментариев еще нет...');
                                }
                                if (snapshot.hasError) {
                                  return const Text("Ошибка загрузки комментариев");
                                }
                                if (snapshot.hasData) {
                                  final data = snapshot.data?.docs;
                                  data?.map((e) => messages.add(MessageModel.fromJson(e.data() as Map<String, dynamic>))).toList();

                                  return Column(
                                    crossAxisAlignment: CrossAxisAlignment.end,
                                    children: [
                                      ListView.separated(
                                          separatorBuilder: (context, index) => const SizedBox(
                                                height: 5,
                                              ),
                                          shrinkWrap: true,
                                          physics: const NeverScrollableScrollPhysics(),
                                          itemCount: data?.length ?? 0,
                                          itemBuilder: (context, index) {
                                            MessageModel message = messages[index];

                                            bool isUser = currentUser.uid == message.uid;
                                            return Bubble(
                                                alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
                                                color: AppColors.cardColor,
                                                padding: const BubbleEdges.all(AppVariables.kEdgeVerticalPadding / 2),
                                                margin: const BubbleEdges.only(top: 3),
                                                nip: isUser ? BubbleNip.rightBottom : BubbleNip.leftBottom,
                                                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                                                  Row(
                                                    children: [
                                                      Image.asset('assets/avatar.png'),
                                                      const SizedBox(
                                                        width: AppVariables.kEdgeHorizontalPadding,
                                                      ),
                                                      Text(message.user),
                                                      const Spacer(),
                                                      Text(DateFormat.yMMMEd('ru').format(message.dateTime).toString()),
                                                    ],
                                                  ),
                                                  const SizedBox(
                                                    height: AppVariables.kEdgeVerticalPadding / 2,
                                                  ),
                                                  Text(
                                                    message.body,
                                                  ),
                                                ]));
                                          }),
                                      const SizedBox(
                                        height: AppVariables.kEdgeVerticalPadding,
                                      ),
                                      GestureDetector(
                                        onTap: () => setState(() => counter += 3),
                                        child: Text(
                                          'Загрузить еще комментарии...',
                                          style: Theme.of(context).textTheme.bodyText2,
                                        ),
                                      )
                                    ],
                                  );
                                } else {
                                  return const Text('Ошбика загрузки комментариев...');
                                }
                              }),
                        ),
                        const SizedBox(
                          height: AppVariables.kEdgeVerticalPadding,
                        ),
                        Container(
                          // height: 100,
                          width: double.infinity,
                          decoration: BoxDecoration(
                            color: AppColors.cardColor,
                            borderRadius: BorderRadius.circular(AppVariables.kBorder / 2),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Row(
                              children: [
                                Expanded(
                                  child: TextField(
                                    style: const TextStyle(color: Colors.white),
                                    controller: _commentController,
                                    decoration: InputDecoration(
                                        hintText: 'Напишите сообщение...', border: InputBorder.none, hintStyle: Theme.of(context).textTheme.bodyText1),
                                  ),
                                ),
                                GestureDetector(
                                    child: Container(
                                        decoration: BoxDecoration(
                                          color: AppColors.orangeColor,
                                          borderRadius: BorderRadius.circular(8),
                                        ),
                                        child: const Padding(
                                          padding: EdgeInsets.all(6),
                                          child: Icon(
                                            Icons.send,
                                            color: Colors.white,
                                          ),
                                        )),
                                    onTap: () async {
                                      await sl.get<FirestoreRepository>().sendComment(_commentController.text, currentUser.displayName, currentUser.uid, entity.id!);
                                      _commentController.clear();
                                    }),
                              ],
                            ),
                          ),
                        )
                      ])),
                ],
              ),
            );
          } else {
            return Center(
              child: Text(
                'Ошибка загрузки новости..',
                style: Theme.of(context).textTheme.headline2!.copyWith(fontSize: 16),
              ),
            );
          }
        },
      ),
    );
  }

  void _showFavoriteUsersModal(List<UserModel>? users) => showMaterialModalBottomSheet(
      context: context,
      backgroundColor: AppColors.cardColor,
      builder: (context) => SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            controller: ModalScrollController.of(context),
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: AppVariables.kEdgeVerticalPadding, horizontal: AppVariables.kEdgeHorizontalPadding / 2),
              child: Column(mainAxisAlignment: MainAxisAlignment.start, crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(
                  'Пользователи, оценившие новость: ',
                  style: Theme.of(context).textTheme.headline2,
                ),
                const SizedBox(
                  height: 15,
                ),
                ListView.separated(
                    padding: EdgeInsets.zero,
                    physics: const NeverScrollableScrollPhysics(),
                    shrinkWrap: true,
                    scrollDirection: Axis.vertical,
                    itemBuilder: (context, index) => Row(
                          children: [
                            Container(
                              width: 40,
                              height: 40,
                              decoration: BoxDecoration(
                                border: Border.all(color: AppColors.orangeColor, width: 2),
                                borderRadius: BorderRadius.circular(99),
                              ),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(99),
                                child: CachedNetworkImage(
                                  imageUrl: users?[index].photoUrl ?? '',
                                ),
                              ),
                            ),
                            const SizedBox(
                              width: AppVariables.kEdgeHorizontalPadding / 2,
                            ),
                            Text(
                              users?[index].displayName ?? '',
                              style: Theme.of(context).textTheme.bodyText2,
                            )
                          ],
                        ),
                    separatorBuilder: (context, index) => const SizedBox(
                          height: 10,
                        ),
                    itemCount: users?.length ?? 0),
              ]),
            ),
          ));

  void _deleteConfirmDialog(String doc, BuildContext context) {
    showMaterialModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Padding(
        padding: const EdgeInsets.symmetric(vertical: AppVariables.kEdgeVerticalPadding, horizontal: AppVariables.kEdgeHorizontalPadding),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            Container(
              width: double.infinity,
              height: 90,
              decoration: BoxDecoration(borderRadius: BorderRadius.circular(AppVariables.kBorder), color: AppColors.cardColor),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text(
                    'Вы действительно хотите удалить новость?',
                    style: Theme.of(context).textTheme.bodyText1!.copyWith(fontSize: 14, fontWeight: FontWeight.w400),
                  ),
                  const Divider(),
                  GestureDetector(
                    onTap: () async {
                      await sl.get<FirestoreRepository>().deleteNews(doc);
                      BotToastNotification.showInfo('Новость успешно удалена');
                      Navigator.pushAndRemoveUntil(context, createRouteAnimFromBottom(const NewsScreen()), (route) => false);
                    },
                    child: Container(
                      color: Colors.transparent,
                      width: double.infinity,
                      child: Center(
                          child: Text(
                        'Удалить',
                        style: Theme.of(context).textTheme.headline2!.copyWith(color: Colors.red),
                      )),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(
              height: AppVariables.kEdgeVerticalPadding / 2,
            ),
            Center(
              child: GestureDetector(
                onTap: () => Navigator.of(context).pop(),
                child: Container(
                  width: double.infinity,
                  height: 60,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(AppVariables.kBorder),
                    color: AppColors.cardColor,
                  ),
                  child: Center(
                    child: Text(
                      'Отменить',
                      style: Theme.of(context).textTheme.headline2!.copyWith(color: AppColors.orangeColor),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
