import 'dart:async';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';
import 'package:news/common/app_colors.dart';
import 'package:news/common/app_variables.dart';
import 'package:news/core/toast_notifications.dart';
import 'package:news/feature/data/models/news_model.dart';
import 'package:news/feature/data/repository/authentication_repository.dart';
import 'package:news/feature/data/repository/firestore_repository.dart';
import 'package:news/feature/presentation/screens/news_detail_screen.dart';
import 'package:news/feature/presentation/state/authentication_state.dart';
import 'package:news/feature/presentation/widgets/app_bar_widget.dart';
import 'package:news/feature/presentation/widgets/default_button_widget.dart';
import 'package:news/feature/presentation/widgets/loading_widget.dart';
import 'package:news/feature/presentation/widgets/route_animation.dart';
import 'package:news/locator_service.dart';
import 'package:provider/provider.dart';

import 'login_screen.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final currentUser = Provider.of<AuthenticationState>(context).currentUser;
    DateFormat dateFormat = DateFormat.yMMMEd('ru');

    return Scaffold(
      backgroundColor: AppColors.scaffoldBackgroundColor,
      appBar: const PreferredSize(
          preferredSize: Size.fromHeight(60),
          child: AppBarWidget(
            title: 'Профиль',
          )),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: SafeArea(
          minimum: const EdgeInsets.symmetric(vertical: AppVariables.kEdgeVerticalPadding, horizontal: AppVariables.kEdgeHorizontalPadding),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(
                height: AppVariables.kEdgeVerticalPadding * 2.5,
              ),
              Container(
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(99),
                  border: Border.all(color: Colors.white, width: 4),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(99),
                  child: CachedNetworkImage(
                    imageUrl: currentUser!.photoUrl,
                    errorWidget: (context, url, index) => Image.asset('assets/avatar.png'),
                    progressIndicatorBuilder: (context, url, downloadProgress) => CircularProgressIndicator(
                      value: downloadProgress.progress,
                    ),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: AppVariables.kEdgeVerticalPadding / 2),
                child: Column(
                  children: [
                    Text(
                      currentUser.displayName,
                      style: Theme.of(context).textTheme.headline2,
                    ),
                    const SizedBox(
                      height: AppVariables.kEdgeVerticalPadding / 10,
                    ),
                    Text(
                      currentUser.email,
                      style: Theme.of(context).textTheme.bodyText2,
                    ),
                  ],
                ),
              ),
              DefaultButtonWidget(function: () => _logoutModal(context), title: 'Выйти'),
              const SizedBox(
                height: AppVariables.kEdgeVerticalPadding * 2,
              ),
              Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'Понравившиеся записи:',
                  style: Theme.of(context).textTheme.headline2!.copyWith(fontSize: 16),
                ),
              ),
              const SizedBox(
                height: AppVariables.kEdgeVerticalPadding / 2,
              ),
              FutureBuilder(
                  future: sl.get<FirestoreRepository>().getFavoriteNews(currentUser.uid),
                  builder: (context, AsyncSnapshot<List<NewsModel>> snapshot) {
                    if (!snapshot.hasData) {
                      return Text(
                        'Записей нет...',
                        style: Theme.of(context).textTheme.bodyText2,
                      );
                    }
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const LoadingWidget();
                    }
                    if (snapshot.hasData && snapshot.connectionState == ConnectionState.done) {
                      return ListView.separated(
                        physics: const NeverScrollableScrollPhysics(),
                        itemBuilder: (context, index) => GestureDetector(
                          onTap: () =>
                              Navigator.of(context).push(createRouteAnimFromBottom(NewsDetailScreen(doc: snapshot.data![index].id!, userUid: currentUser.uid))),
                          child: Container(
                            width: double.infinity,
                            decoration: BoxDecoration(color: AppColors.cardColor, borderRadius: BorderRadius.circular(AppVariables.kBorder)),
                            child: Padding(
                              padding: const EdgeInsets.symmetric(
                                  vertical: AppVariables.kEdgeVerticalPadding * 0.75, horizontal: AppVariables.kEdgeHorizontalPadding / 2),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    snapshot.data![index].title,
                                    style: Theme.of(context).textTheme.headline2,
                                  ),
                                  const SizedBox(
                                    height: AppVariables.kEdgeVerticalPadding / 2,
                                  ),
                                  Text(
                                    dateFormat.format(snapshot.data![index].dateTime!).toString(),
                                    style: Theme.of(context).textTheme.bodyText2,
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                        separatorBuilder: (context, index) => const SizedBox(
                          height: 10,
                        ),
                        itemCount: snapshot.data?.length ?? 0,
                        shrinkWrap: true,
                      );
                    } else {
                      return Text(
                        'Ошибка...',
                        style: Theme.of(context).textTheme.bodyText2,
                      );
                    }
                  }),
            ],
          ),
        ),
      ),
    );
  }

  void _logoutModal(BuildContext context) {
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
                    'Вы действительно хотите выйти?',
                    style: Theme.of(context).textTheme.bodyText1!.copyWith(fontSize: 14, fontWeight: FontWeight.w400),
                  ),
                  const Divider(),
                  GestureDetector(
                    onTap: () async {
                      try {
                        Timer(const Duration(milliseconds: 400), () => sl.get<AuthenticationRepository>().logOut());
                        Navigator.of(context).pushAndRemoveUntil(createRouteAnimFromBottom(const LoginScreen()), (route) => false);
                      }catch(e){
                        BotToastNotification.showError('Ошибка выхода из аккаунта');
                      }
                    },
                    child: Container(
                      color: Colors.transparent,
                      width: double.infinity,
                      child: Center(
                          child: Text(
                        'Выйти',
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
