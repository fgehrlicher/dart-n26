class Statement {
  String id;
  String url;
  int visibleTS;
  int month;
  int year;

  Statement.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    url = json['url'];
    visibleTS = json['visibleTS'];
    month = json['month'];
    year = json['year'];
  }
}
