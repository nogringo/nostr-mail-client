class DistributionConfig {
  const DistributionConfig({this.privacyPolicyUrl});

  final String? privacyPolicyUrl;

  bool get hasPrivacyPolicyUrl =>
      privacyPolicyUrl != null && privacyPolicyUrl!.isNotEmpty;
}
