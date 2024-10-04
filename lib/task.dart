class Task {
  String title;
  bool done;
  String? id;

  Task({required this.title, this.done = false, this.id});

  factory Task.fromJson(Map<String, dynamic> json) {
    return Task(
      title: json['title'] as String,
      done: json['done'] as bool,
      id: json['id'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'done': done,
    };
  }
}
