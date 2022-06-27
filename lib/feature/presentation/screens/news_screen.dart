import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:news/common/app_colors.dart';
import 'package:news/common/app_variables.dart';
import 'package:news/feature/data/repository/firestore_repository.dart';
import 'package:news/feature/domain/filter_data.dart';
import 'package:news/feature/presentation/screens/create_screen.dart';
import 'package:news/feature/presentation/screens/news_detail_screen.dart';
import 'package:news/feature/presentation/screens/profile_screen.dart';
import 'package:news/feature/presentation/state/authentication_state.dart';
import 'package:news/feature/presentation/widgets/route_animation.dart';
import 'package:news/locator_service.dart';
import 'package:provider/provider.dart';

import '../../data/models/news_model.dart';

class NewsScreen extends StatefulWidget {
  const NewsScreen({Key? key}) : super(key: key);

  @override
  State<NewsScreen> createState() => _NewsScreenState();
}

class _NewsScreenState extends State<NewsScreen> {
  List<NewsModel> _allResults = [];
  Future? _future;

  void _onSelectedFilterItem(BuildContext context, MenuItem item) {
    switch (item) {
      case FilterItems.filterDateAsc:
        setState(() => _allResults.sort((a, b) => b.dateTime!.compareTo(a.dateTime!)));
        break;
      case FilterItems.filterDateDesc:
        setState(() => _allResults.sort((a, b) => a.dateTime!.compareTo(b.dateTime!)));
        break;
      case FilterItems.filterFavoriteAsc:
        setState(() => _allResults.sort((a, b) => b.favorite!.length.compareTo(a.favorite!.length)));
        break;
      case FilterItems.filterFavoriteDesc:
        setState(() => _allResults.sort((a, b) => a.favorite!.length.compareTo(b.favorite!.length)));
        break;
    }
  }

  Future<dynamic> _getNews() async {
    final data = await sl.get<FirestoreRepository>().getAllNews();
    setState(() {
      _allResults = data;
    });
    return data;
  }

  @override
  void initState() {
    super.initState();
    _getNews();
  }

  @override
  Widget build(BuildContext context) {
    final currentUser = Provider.of<AuthenticationState>(context).currentUser;

    return Scaffold(
      backgroundColor: AppColors.scaffoldBackgroundColor,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: AppColors.appBarColor,
        leading:
            GestureDetector(onTap: () => Navigator.of(context).push(createRouteAnimFromBottom(const ProfileScreen())), child: Image.asset('assets/avatar.png')),
        title: Text(
          'Привет, ${currentUser?.displayName}!',
          style: Theme.of(context).textTheme.bodyText1,
        ),
        actions: [
          IconButton(
              onPressed: () async {
                Navigator.of(context).push(createRouteAnimFromBottom(const CreateScreen(newsModel: null)));
              },
              icon: const Icon(Icons.add_circle_outline_outlined, color: AppColors.orangeColor))
        ],
      ),
      body: SafeArea(
          minimum: const EdgeInsets.symmetric(vertical: AppVariables.kEdgeVerticalPadding, horizontal: AppVariables.kEdgeHorizontalPadding),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text(
                    'Новости',
                    style: Theme.of(context).textTheme.headline1,
                  ),
                  PopupMenuButton<MenuItem>(
                      icon: const Icon(
                        Icons.filter_list_rounded,
                        color: AppColors.orangeColor,
                      ),
                      color: AppColors.cardColor,
                      onSelected: (item) => _onSelectedFilterItem(context, item),
                      itemBuilder: (context) => [...FilterItems.filterItems.map((e) => _buildItem(context, e)).toList(), const PopupMenuDivider()])
                ],
              ),
              Expanded(
                child: _allResults.isEmpty ? Text('Новостей нет...', style: Theme.of(context).textTheme.headline2,) : ListView.separated(
                  physics: const BouncingScrollPhysics(),
                  itemBuilder: (context, index) => GestureDetector(
                      onTap: () => Navigator.of(context).push(createRouteAnimFromBottom(NewsDetailScreen(
                            doc: _allResults[index].id!,
                            userUid: currentUser!.uid,
                          ))),
                      child: _newsCard(context, index, _allResults[index])),
                  separatorBuilder: (context, index) => const SizedBox(
                    height: 10,
                  ),
                  shrinkWrap: true,
                  itemCount: _allResults.length,
                  // itemCount: snapshot.data!.length,
                ),
              ),
            ],
          )),
    );
  }
}

PopupMenuItem<MenuItem> _buildItem(BuildContext context, MenuItem menuItem) => PopupMenuItem<MenuItem>(
    value: menuItem,
    child: Row(
      children: [
        Icon(
          menuItem.icon,
          color: Colors.white,
        ),
        Flexible(
            child: Text(
          menuItem.text,
          style: Theme.of(context).textTheme.bodyText1,
        ))
      ],
    ));

Widget _newsCard(context, index, NewsModel news) => SizedBox(
      width: double.infinity,
      height: 200,
      child: Stack(children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(AppVariables.kBorder),
          child: CachedNetworkImage(
            width: double.infinity,
            imageUrl: news.image,
            fit: BoxFit.cover,
          ),
        ),
        Container(
          decoration: BoxDecoration(
            color: Colors.black.withOpacity(0.2),
            borderRadius: BorderRadius.circular(AppVariables.kBorder),
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(vertical: AppVariables.kBorder, horizontal: AppVariables.kBorder / 2),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(AppVariables.kBorder)),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 7),
                      child: Text(
                        DateFormat.MMMEd('ru').format(news.dateTime!),
                        style: Theme.of(context).textTheme.bodyText1!.copyWith(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 12),
                      ),
                    ),
                  ),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      const Icon(Icons.favorite, color: Colors.redAccent, size: 15),
                      const SizedBox(
                        width: AppVariables.kEdgeHorizontalPadding / 5,
                      ),
                      Text(news.favorite!.length.toString(), style: Theme.of(context).textTheme.bodyText1),
                    ],
                  )
                ],
              ),
              const Spacer(),
              Text(
                news.title,
                style: Theme.of(context).textTheme.headline2,
              ),
              // const SizedBox(height: 10,),
              Flexible(
                child: Text(
                  news.body,
                  style: Theme.of(context).textTheme.bodyText2!.copyWith(fontSize: 11),
                  maxLines: 4,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),
      ]),
    );
