class Comment {
  final int id;
  final String name;
  final String date;
  final String comment;
  final int likeCount;

  Comment({
    required this.id,
    required this.name,
    required this.date,
    required this.comment,
    required this.likeCount,
  });

  factory Comment.fromJson(Map<String, dynamic> json) {
    return Comment(
      id: json['id'],
      name: json['name'],
      date: json['date'],
      comment: json['comment'],
      likeCount: json['likeCount'],
    );
  }
}
