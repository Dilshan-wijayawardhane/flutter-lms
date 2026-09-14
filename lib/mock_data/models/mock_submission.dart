/// Submission status — matches backend values.
enum SubmissionStatus {
  pending,
  submitted,
  resubmissionRequired,
  graded;

  String get wireValue {
    switch (this) {
      case SubmissionStatus.pending:
        return 'PENDING';
      case SubmissionStatus.submitted:
        return 'SUBMITTED';
      case SubmissionStatus.resubmissionRequired:
        return 'RESUBMISSION_REQUIRED';
      case SubmissionStatus.graded:
        return 'GRADED';
    }
  }

  String get label {
    switch (this) {
      case SubmissionStatus.pending:
        return 'Pending';
      case SubmissionStatus.submitted:
        return 'Submitted';
      case SubmissionStatus.resubmissionRequired:
        return 'Resubmission Required';
      case SubmissionStatus.graded:
        return 'Graded';
    }
  }
}

class MockSubmission {
  const MockSubmission({
    required this.id,
    required this.assignmentId,
    required this.assignmentTitle,
    required this.studentId,
    required this.studentName,
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
  final String studentName;
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

  MockSubmission copyWith({
    SubmissionStatus? status,
    String? textContent,
    String? fileName,
    String? fileUrl,
    DateTime? submittedAt,
    int? score,
    String? feedback,
    DateTime? gradedAt,
    DateTime? resubmissionRequestedAt,
  }) {
    return MockSubmission(
      id: id,
      assignmentId: assignmentId,
      assignmentTitle: assignmentTitle,
      studentId: studentId,
      studentName: studentName,
      status: status ?? this.status,
      textContent: textContent ?? this.textContent,
      fileName: fileName ?? this.fileName,
      fileUrl: fileUrl ?? this.fileUrl,
      submittedAt: submittedAt ?? this.submittedAt,
      score: score ?? this.score,
      maxPoints: maxPoints,
      feedback: feedback ?? this.feedback,
      gradedAt: gradedAt ?? this.gradedAt,
      resubmissionRequestedAt:
      resubmissionRequestedAt ?? this.resubmissionRequestedAt,
    );
  }

  factory MockSubmission.fromJson(Map<String, dynamic> json) {
    throw UnimplementedError('MockSubmission.fromJson');
  }

  Map<String, dynamic> toJson() {
    throw UnimplementedError('MockSubmission.toJson');
  }
}