class IyzicoPackageModel {
  final int? id;
  final String? name;
  final int? days;
  final int? lessonCount;
  final dynamic price;
  final int? status;
  final String? createdAt;
  final String? updatedAt;

  IyzicoPackageModel({
    this.id,
    this.name,
    this.days,
    this.lessonCount,
    this.price,
    this.status,
    this.createdAt,
    this.updatedAt,
  });

  factory IyzicoPackageModel.fromJson(Map<String, dynamic> json) {
    return IyzicoPackageModel(
      id: json['id'],
      name: json['name'],
      days: json['days'],
      lessonCount: json['lesson_count'],
      price: json['price'],
      status: json['status'],
      createdAt: json['created_at'],
      updatedAt: json['updated_at'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'days': days,
      'lesson_count': lessonCount,
      'price': price,
      'status': status,
      'created_at': createdAt,
      'updated_at': updatedAt,
    };
  }
}
