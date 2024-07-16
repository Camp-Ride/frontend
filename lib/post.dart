import 'dart:io';

class Post {
  final int id;
  final String name;
  final String date;
  final String title;
  final String contents;
  final int commentCount;
  final int likeCount;
  final List<String> images;

  Post({
    required this.id,
    required this.name,
    required this.date,
    required this.title,
    required this.contents,
    required this.commentCount,
    required this.likeCount,
    required this.images,
  });

  factory Post.fromJson(Map<String, dynamic> json) {
    // Parsing the date from JSON array to string
    List<int> dateParts = List<int>.from(json['createdAt']);
    String formattedDate = "${dateParts[0]}-${dateParts[1].toString().padLeft(2, '0')}-${dateParts[2].toString().padLeft(2, '0')}";

    return Post(
      id: json['id'],
      name: json['name'],
      date: formattedDate,
      title: json['title'],
      contents: json['contents'] ?? '',
      commentCount: json['commentResponses']?.length ?? 0,
      likeCount: json['likeResponses']?.length ?? 0,
      images: List<String>.from(json['imageNames']),
    );
  }
}
