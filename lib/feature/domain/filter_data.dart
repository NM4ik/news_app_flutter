import 'package:flutter/material.dart';

class FilterItems {
  static const List<MenuItem> filterItems = [filterDateAsc, filterDateDesc, filterFavoriteAsc, filterFavoriteDesc];

  static const filterDateDesc = MenuItem(text: 'Отфильтровать по дате', icon: Icons.arrow_downward_rounded);
  static const filterDateAsc = MenuItem(text: 'Отфильтровать по дате', icon: Icons.arrow_upward_rounded);
  static const filterFavoriteDesc = MenuItem(text: 'Отфильтровать по популярности', icon: Icons.arrow_downward_rounded);
  static const filterFavoriteAsc = MenuItem(text: 'Отфильтровать по популярности', icon: Icons.arrow_upward_rounded);
}

class MenuItem {
  final String text;
  final IconData icon;

  const MenuItem({required this.text, required this.icon});
}
