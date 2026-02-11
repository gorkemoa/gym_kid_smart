import 'meal_menu_model.dart';

class CalendarDetailModel {
  List<TimeTableItem>? timeTable;
  List<MealMenuModel>? mealMenus;
  List<GalleryItem>? gallery;

  CalendarDetailModel({this.timeTable, this.mealMenus, this.gallery});

  CalendarDetailModel.fromJson(Map<String, dynamic> json) {
    if (json['time_table'] != null) {
      timeTable = <TimeTableItem>[];
      json['time_table'].forEach((v) {
        timeTable!.add(TimeTableItem.fromJson(v));
      });
    }
    if (json['meal_menus'] != null) {
      mealMenus = <MealMenuModel>[];
      json['meal_menus'].forEach((v) {
        mealMenus!.add(MealMenuModel.fromJson(v));
      });
    }
    if (json['gallery'] != null) {
      gallery = <GalleryItem>[];
      json['gallery'].forEach((v) {
        gallery!.add(GalleryItem.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    if (timeTable != null) {
      data['time_table'] = timeTable!.map((v) => v.toJson()).toList();
    }
    if (mealMenus != null) {
      data['meal_menus'] = mealMenus!.map((v) => v.toJson()).toList();
    }
    if (gallery != null) {
      data['gallery'] = gallery!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class TimeTableItem {
  LessonModel? lesson;
  String? description;
  String? file;
  String? date;
  String? startTime;
  String? endTime;
  CalendarCreator? creator;

  TimeTableItem({
    this.lesson,
    this.description,
    this.file,
    this.date,
    this.startTime,
    this.endTime,
    this.creator,
  });

  TimeTableItem.fromJson(Map<String, dynamic> json) {
    lesson = json['lesson'] != null
        ? LessonModel.fromJson(json['lesson'])
        : null;
    description = json['description'];
    file = json['file'];
    date = json['date'];
    startTime = json['start_time'];
    endTime = json['end_time'];
    creator = json['creator'] != null
        ? CalendarCreator.fromJson(json['creator'])
        : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    if (lesson != null) {
      data['lesson'] = lesson!.toJson();
    }
    data['description'] = description;
    data['file'] = file;
    data['date'] = date;
    data['start_time'] = startTime;
    data['end_time'] = endTime;
    if (creator != null) {
      data['creator'] = creator!.toJson();
    }
    return data;
  }
}

class LessonModel {
  int? id;
  String? title;

  LessonModel({this.id, this.title});

  LessonModel.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    title = json['title'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['title'] = title;
    return data;
  }
}

class CalendarCreator {
  int? id;
  String? name;
  String? surname;

  CalendarCreator({this.id, this.name, this.surname});

  CalendarCreator.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    name = json['name'];
    surname = json['surname'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['name'] = name;
    data['surname'] = surname;
    return data;
  }
}

class GalleryItem {
  int? id;
  String? image;

  GalleryItem({this.id, this.image});

  GalleryItem.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    image = json['image'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['image'] = image;
    return data;
  }
}
