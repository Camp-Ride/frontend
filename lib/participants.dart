
class Participant {
  final int id;
  final String socialLoginId;
  final String nickname;
  final String role;
  final int lastSeenMessageScore;

  Participant({
    required this.id,
    required this.socialLoginId,
    required this.nickname,
    required this.role,
    required this.lastSeenMessageScore,
  });

  // JSON 데이터를 Dart 객체로 변환하는 factory 생성자
  factory Participant.fromJson(Map<String, dynamic> json) {
    return Participant(
      id: json['id'],
      socialLoginId: json['socialLoginId'],
      nickname: json['nickname'],
      role: json['role'],
      lastSeenMessageScore: json['lastSeenMessageScore'],
    );
  }

  // Dart 객체를 JSON으로 변환하는 메서드
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'socialLoginId': socialLoginId,
      'nickname': nickname,
      'role': role,
      'lastSeenMessageScore': lastSeenMessageScore,
    };
  }
}