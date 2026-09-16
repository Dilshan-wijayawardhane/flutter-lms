class VerifyEmailRequest {
  const VerifyEmailRequest({required this.email, required this.otp});

  final String email;
  final String otp;

  Map<String, dynamic> toJson() => {'email': email, 'otp': otp};
}

class ResendOtpRequest {
  const ResendOtpRequest({required this.email});

  final String email;

  Map<String, dynamic> toJson() => {'email': email};
}