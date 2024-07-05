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
    return Post(
      id: json['id'],
      name: json['name'],
      date: json['date'],
      title: json['title'],
      contents: json['contents'],
      commentCount: json['commentCount'],
      likeCount: json['likeCount'],
      images: json['images'],
    );
  }
}
