class OyunGrubuAnnouncementModel {
  final int? id;
  final String? title;
  final String? content;
  final int? status;
  final String? createdAt;
  final dynamic pollOptionA;
  final dynamic pollOptionB;
  final int? isPoll;
  final String? type;

  OyunGrubuAnnouncementModel({
    this.id,
    this.title,
    this.content,
    this.status,
    this.createdAt,
    this.pollOptionA,
    this.pollOptionB,
    this.isPoll,
    this.type,
  });

  factory OyunGrubuAnnouncementModel.fromJson(Map<String, dynamic> json) {
    return OyunGrubuAnnouncementModel(
      id: json['id'] is int
          ? json['id'] as int?
          : int.tryParse(json['id'].toString()),
      title: json['title'] as String?,
      content: json['content'] as String?,
      status: json['status'] is int
          ? json['status'] as int?
          : int.tryParse(json['status'].toString()),
      createdAt: json['created_at'] as String?,
      pollOptionA: json['poll_option_a'],
      pollOptionB: json['poll_option_b'],
      isPoll: json['is_poll'] is int
          ? json['is_poll'] as int?
          : int.tryParse(json['is_poll'].toString()),
      type: json['type'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'content': content,
      'status': status,
      'created_at': createdAt,
      'poll_option_a': pollOptionA,
      'poll_option_b': pollOptionB,
      'is_poll': isPoll,
      'type': type,
    };
  }

  String? get pollOptionAText {
    if (pollOptionA == null) return null;
    final s = pollOptionA.toString().trim();
    return s.isEmpty ? null : s;
  }

  String? get pollOptionBText {
    if (pollOptionB == null) return null;
    final s = pollOptionB.toString().trim();
    return s.isEmpty ? null : s;
  }
}
