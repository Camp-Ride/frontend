
import 'item.dart';

class Post extends Item {
  @override
  final int id;
  final int authorId;
  final String name;
  final String date;
  final String title;
  final String contents;
  int commentCount;
  int likeCount;
  final List<String> images;
  bool isLiked;

  Post({
    required this.id,
    required this.authorId,
    required this.name,
    required this.date,
    required this.title,
    required this.contents,
    required this.commentCount,
    required this.likeCount,
    required this.images,
    required this.isLiked,
  }) : super(
          id: id,
        );

  factory Post.fromJson(Map<String, dynamic> json, String currentNickname) {
    // Parsing the date from JSON array to string
    List<int> dateParts = List<int>.from(json['createdAt']);
    String formattedDate =
        "${dateParts[0]}-${dateParts[1].toString().padLeft(2, '0')}-${dateParts[2].toString().padLeft(2, '0')}";

    List<dynamic> likeResponses = json['likeResponses'] ?? [];
    bool isLiked = likeResponses
        .any((response) => response['nickname'] == currentNickname);

    print(likeResponses.toString());
    print(currentNickname);

    return Post(
      id: json['id'],
      authorId: json['authorId'],
      name: json['name'],
      date: formattedDate,
      title: json['title'],
      contents: json['contents'] ?? '',
      commentCount: json['commentResponses']?.length ?? 0,
      likeCount: json['likeResponses']?.length ?? 0,
      images: List<String>.from(json['imageNames']),
      isLiked: isLiked,
    );
  }
}
