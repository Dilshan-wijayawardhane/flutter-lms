enum SubmissionStatus { pending, submitted, resubmissionRequired, graded }

class Submission {
  const Submission({
    required this.id,
    required this.assignmentId,
    required this.assignmentTitle,
    required this.studentId,
    required this.status,
    this.textContent,
    this.fileName,
    this.fileUrl,
    this.submittedAt,
    this.score,
    this.maxPoints,
    this.feedback,
    this.gradedAt,
    this.resubmissionRequestedAt,
  });

  final String id;
  final String assignmentId;
  final String assignmentTitle;
  final String studentId;
  final SubmissionStatus status;
  final String? textContent;
  final String? fileName;
  final String? fileUrl;
  final DateTime? submittedAt;
  final int? score;
  final int? maxPoints;
  final String? feedback;
  final DateTime? gradedAt;
  final DateTime? resubmissionRequestedAt;

  bool get isEditable =>
      status == SubmissionStatus.pending ||
          status == SubmissionStatus.resubmissionRequired;

  factory Submission.fromJson(Map<String, dynamic> json) {
    final data = (json['data'] as Map<String, dynamic>?) ?? json;
    final assignmentJson =
    data['assignment'] as Map<String, dynamic>?;

    final statusStr =
    ((data['status'] ?? 'PENDING') as String).toUpperCase();

    return Submission(
      id: (data['id'] ?? data['_id'] ?? '').toString(),
      assignmentId:
      (data['assignmentId'] ?? assignmentJson?['id'] ?? '')
          .toString(),
      assignmentTitle: (data['assignmentTitle'] ??
          assignmentJson?['title'] ??
          '')
          .toString(),
      studentId:
      (data['studentId'] ?? data['student']?['id'] ?? '').toString(),
      status: SubmissionStatus.values.firstWhere(
            (s) => s.name.toUpperCase() == statusStr,
        orElse: () => SubmissionStatus.pending,
      ),
      textContent: data['textContent']?.toString(),
      fileName: data['fileName']?.toString(),
      fileUrl: data['fileUrl']?.toString(),
      submittedAt: _parseDate(data['submittedAt']),
      score: (data['score'] as num?)?.toInt(),
      maxPoints: (data['maxPoints'] as num?)?.toInt(),
      feedback: data['feedback']?.toString(),
      gradedAt: _parseDate(data['gradedAt']),
      resubmissionRequestedAt:
      _parseDate(data['resubmissionRequestedAt']),
    );
  }

  static DateTime? _parseDate(dynamic v) {
    if (v is String && v.isNotEmpty) return DateTime.tryParse(v);
    return null;
  }
}