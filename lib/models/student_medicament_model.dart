class StudentMedicamentModel {
  int? id;
  String? title;
  String? value;
  String? note;
  int? status;

  StudentMedicamentModel({
    this.id,
    this.title,
    this.value,
    this.note,
    this.status,
  });

  StudentMedicamentModel.fromJson(Map<String, dynamic> json) {
    id = int.tryParse(json['id'].toString());
    title = json['title'];
    value = json['value'];
    note = json['note'];
    status = int.tryParse(json['status'].toString());
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['title'] = title;
    data['value'] = value;
    data['note'] = note;
    data['status'] = status;
    return data;
  }
}
