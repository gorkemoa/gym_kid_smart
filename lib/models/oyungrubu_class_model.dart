class OyunGrubuClassModel {
  final int? id;
  final String? groupName;
  final String? postponementMode;
  final int? status;
  final String? createdAt;

  OyunGrubuClassModel({
    this.id,
    this.groupName,
    this.postponementMode,
    this.status,
    this.createdAt,
  });

  factory OyunGrubuClassModel.fromJson(Map<String, dynamic> json) {
    return OyunGrubuClassModel(
      id: json['id'] as int?,
      groupName: json['group_name'] as String?,
      postponementMode: json['postponement_mode'] as String?,
      status: json['status'] as int?,
      createdAt: json['created_at'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'group_name': groupName,
      'postponement_mode': postponementMode,
      'status': status,
      'created_at': createdAt,
    };
  }
}
