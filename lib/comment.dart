import 'item.dart';

class Comment extends Item {
  @override
  final int id;
  final int authorId;
  final String name;
  final String date;
  final String comment;
  int likeCount;
  bool isLiked;

  Comment({
    required this.id,
    required this.authorId,
    required this.name,
    required this.date,
    required this.comment,
    required this.likeCount,
    required this.isLiked,
  }) : super(
          id: id,
        );

  factory Comment.fromJson(Map<String, dynamic> json, String currentNickname) {
    List<int> dateParts = List<int>.from(json['createdAt']);
    String formattedDate =
        "${dateParts[0]}/${dateParts[1]}/${dateParts[2]} ${dateParts[3].toString().padLeft(2, '0')}:${dateParts[4].toString().padLeft(2, '0')}:${dateParts[5].toString().padLeft(2, '0')}";

    List<dynamic> likeResponses = json['likeResponses'] ?? [];
    bool isLiked = likeResponses
        .any((response) => response['nickname'] == currentNickname);

    return Comment(
      id: json['id'],
      authorId: json['authorId'],
      name: json['nickname'],
      date: formattedDate,
      comment: json['content'],
      likeCount: json['likeResponses']?.length ?? 0,
      isLiked: isLiked,
    );
  }
}
