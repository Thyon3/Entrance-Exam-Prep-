class SubjectModel {
  SubjectModel({
    required this.id,
    required this.subjectName,
    this.gradeLevel,
    this.stream,
    this.teacherName,
    this.progressPercent,
  });

  final String id;
  final String subjectName;
  final String? gradeLevel;
  final String? stream;
  final String? teacherName;
  final double? progressPercent;

  factory SubjectModel.fromJson(Map<String, dynamic> json) {
    final teacher = json['teacher'];
    String? teacherName;
    if (teacher is Map) {
      teacherName = '${teacher['firstName'] ?? ''} ${teacher['lastName'] ?? ''}'.trim();
    }
    final progress = json['progress'];
    double? pct;
    if (progress is Map) {
      pct = (progress['completionPercentage'] as num?)?.toDouble();
    }
    return SubjectModel(
      id: (json['_id'] ?? json['id'] ?? '').toString(),
      subjectName: json['subjectName']?.toString() ?? 'Subject',
      gradeLevel: json['gradeLevel']?.toString(),
      stream: json['stream']?.toString(),
      teacherName: teacherName,
      progressPercent: pct ?? (json['completionPercentage'] as num?)?.toDouble(),
    );
  }
}

class ChapterModel {
  ChapterModel({
    required this.id,
    required this.chapterName,
    this.subjectId,
    this.completionPercent,
  });

  final String id;
  final String chapterName;
  final String? subjectId;
  final double? completionPercent;

  factory ChapterModel.fromJson(Map<String, dynamic> json) {
    return ChapterModel(
      id: (json['_id'] ?? json['id'] ?? '').toString(),
      chapterName: json['chapterName']?.toString() ?? 'Chapter',
      subjectId: json['subject']?.toString(),
      completionPercent: (json['completionPercentage'] as num?)?.toDouble(),
    );
  }
}

class TopicModel {
  TopicModel({
    required this.id,
    required this.topicName,
    this.chapterId,
    this.objectives,
    this.status,
  });

  final String id;
  final String topicName;
  final String? chapterId;
  final List<String>? objectives;
  final String? status;

  factory TopicModel.fromJson(Map<String, dynamic> json) {
    final objs = json['topicObjectives'];
    return TopicModel(
      id: (json['_id'] ?? json['id'] ?? '').toString(),
      topicName: json['topicName']?.toString() ?? 'Topic',
      chapterId: json['chapter']?.toString(),
      objectives: objs is List ? objs.map((e) => e.toString()).toList() : null,
      status: json['status']?.toString(),
    );
  }
}

List<T> parseList<T>(dynamic data, T Function(Map<String, dynamic>) fromJson) {
  if (data is List) {
    return data
        .whereType<Map>()
        .map((e) => fromJson(Map<String, dynamic>.from(e)))
        .toList();
  }
  return [];
}
