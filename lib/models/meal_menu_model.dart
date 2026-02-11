class MealMenuModel {
  int? id;
  String? title;
  String? menu;
  String? time;
  String? date;

  MealMenuModel({this.id, this.title, this.menu, this.time, this.date});

  MealMenuModel.fromJson(Map<String, dynamic> json) {
    id = int.tryParse(json['id'].toString());
    title = json['title'];
    menu = json['menu'];
    time = json['time'];
    date = json['date'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['title'] = title;
    data['menu'] = menu;
    data['time'] = time;
    data['date'] = date;
    return data;
  }
}
