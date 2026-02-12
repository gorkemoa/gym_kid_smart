class ChatRoomModel {
  final int? id;
  final ChatParticipantModel? sender;
  final ChatParticipantModel? recipient;
  final String? dateAdded;
  final int? status;

  ChatRoomModel({
    this.id,
    this.sender,
    this.recipient,
    this.dateAdded,
    this.status,
  });

  factory ChatRoomModel.fromJson(Map<String, dynamic> json) {
    return ChatRoomModel(
      id: _toInt(json['id']),
      sender: json['sender'] != null
          ? ChatParticipantModel.fromJson(json['sender'])
          : null,
      recipient: json['recipient'] != null
          ? ChatParticipantModel.fromJson(json['recipient'])
          : null,
      dateAdded: json['date_added'],
      status: _toInt(json['status']),
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
      'sender': sender?.toJson(),
      'recipient': recipient?.toJson(),
      'date_added': dateAdded,
      'status': status,
    };
  }
}

class ChatParticipantModel {
  final ChatParticipantDataModel? data;
  final String? path;

  ChatParticipantModel({this.data, this.path});

  factory ChatParticipantModel.fromJson(Map<String, dynamic> json) {
    return ChatParticipantModel(
      data: json['data'] != null && json['data'] is Map<String, dynamic>
          ? ChatParticipantDataModel.fromJson(json['data'])
          : null,
      path: json['path'],
    );
  }

  Map<String, dynamic> toJson() {
    return {'data': data?.toJson(), 'path': path};
  }

  String get fullImageUrl {
    if (data?.image == null || path == null) return '';
    if (path!.endsWith('/')) {
      return '$path${data!.image}';
    }
    return '$path/${data!.image}';
  }
}

class ChatParticipantDataModel {
  final int? id;
  final String? name;
  final String? surname;
  final String? role;
  final String? image;

  ChatParticipantDataModel({
    this.id,
    this.name,
    this.surname,
    this.role,
    this.image,
  });

  factory ChatParticipantDataModel.fromJson(Map<String, dynamic> json) {
    return ChatParticipantDataModel(
      id: _toInt(json['id']),
      name: json['name'],
      surname: json['surname'],
      role: json['role'],
      image: json['image'],
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
      'name': name,
      'surname': surname,
      'role': role,
      'image': image,
    };
  }

  String get fullName => '${name ?? ''} ${surname ?? ''}'.trim();
}
