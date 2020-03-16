class Paging {
  int previous;
  int next;
  int totalResults;

  Paging.fromJson(Map<String, dynamic> json) {
    previous = json['previous'];
    next = json['next'];
    totalResults = json['totalResults'];
  }
}
