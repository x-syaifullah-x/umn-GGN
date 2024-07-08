abstract class SignType {}

class SignTypeGoogle implements SignType {
  const SignTypeGoogle();
}

class SignTypeEmail implements SignType {
  final String username;
  final String email;
  final String password;
  final bool termsAndPrivacyPolicy;

  const SignTypeEmail({
    required this.username,
    required this.email,
    required this.password,
    required this.termsAndPrivacyPolicy,
  });
}
