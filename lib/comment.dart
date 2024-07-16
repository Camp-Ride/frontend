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
    List<int> dateParts = List<int>.from(json['createdAt']);
    String formattedDate =
        "${dateParts[0]}/${dateParts[1]}/${dateParts[2]} ${dateParts[3]}:${dateParts[4]}:${dateParts[5]}";

    return Comment(
      id: json['id'],
      name: json['nickname'],
      date: formattedDate,
      comment: json['content'],
      likeCount: json['likeResponses']?.length ?? 0,
    );
  }
}
