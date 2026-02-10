class ClassModel {
  final int? id;
  final int? schoolId;
  final String? name;
  final String? image;

  ClassModel({this.id, this.schoolId, this.name, this.image});

  factory ClassModel.fromJson(Map<String, dynamic> json) {
    return ClassModel(
      id: json['id'],
      schoolId: json['school_id'],
      name: json['name'],
      image: json['image'],
    );
  }

  Map<String, dynamic> toJson() {
    return {'id': id, 'school_id': schoolId, 'name': name, 'image': image};
  }
}
