class NewsEntity {
  final String? id;
  final DateTime? dateTime;
  final String body;
  final String image;
  final String title;
  final List<String>? favorite;
  final List<Map<String, dynamic>>? comments;
  final String createdBy;

  const NewsEntity(
      {required this.id,
      required this.dateTime,
      required this.body,
      required this.image,
      required this.title,
      this.favorite,
      this.comments,
      required this.createdBy});

  @override
  String toString() {
    return 'NewsEntity{id: $id, dateTime: $dateTime, body: $body, image: $image, title: $title, favorite: $favorite, comments: $comments, createdBy: ${createdBy}}';
  }
}
