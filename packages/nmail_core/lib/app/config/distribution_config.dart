typedef UnifiedPushDistributorChecker = Future<bool> Function();

class DistributionConfig {
  const DistributionConfig({
    this.privacyPolicyUrl,
    this.hasUnifiedPushDistributor,
    String? unifiedPushDistributorInstallUrl,
  }) : unifiedPushDistributorInstallUrl =
           unifiedPushDistributorInstallUrl ??
           defaultUnifiedPushDistributorInstallUrl;

  static const defaultUnifiedPushDistributorInstallUrl =
      'https://f-droid.org/packages/org.unifiedpush.distributor.sunup/';

  final String? privacyPolicyUrl;
  final UnifiedPushDistributorChecker? hasUnifiedPushDistributor;
  final String unifiedPushDistributorInstallUrl;

  bool get hasPrivacyPolicyUrl =>
      privacyPolicyUrl != null && privacyPolicyUrl!.isNotEmpty;

  bool get canCheckUnifiedPushDistributor => hasUnifiedPushDistributor != null;
}
