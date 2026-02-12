class ChatMessageModel {
  final int? id;
  final int? messageId;
  final int? sendUser;
  final String? description;
  final String? dateAdded;

  ChatMessageModel({
    this.id,
    this.messageId,
    this.sendUser,
    this.description,
    this.dateAdded,
  });

  factory ChatMessageModel.fromJson(Map<String, dynamic> json) {
    return ChatMessageModel(
      id: _toInt(json['id']),
      messageId: _toInt(json['message_id']),
      sendUser: _toInt(json['send_user']),
      description: json['description'],
      dateAdded: json['date_added'],
    );
  }

  static int? _toInt(dynamic value) {
    if (value == null) return null;
    if (value is int) return value;
    if (value is String) return int.tryParse(value);
    return null;
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'message_id': messageId,
      'send_user': sendUser,
      'description': description,
      'date_added': dateAdded,
    };
  }
}
