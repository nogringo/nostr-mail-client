typedef UnifiedPushDistributorChecker = Future<bool> Function();

enum Distribution { standard, foss, zapstore }

class DistributionConfig {
  const DistributionConfig({
    required this.distribution,
    this.privacyPolicyUrl,
    this.hasUnifiedPushDistributor,
    String? unifiedPushDistributorInstallUrl,
  }) : unifiedPushDistributorInstallUrl =
           unifiedPushDistributorInstallUrl ??
           defaultUnifiedPushDistributorInstallUrl;

  static const defaultUnifiedPushDistributorInstallUrl =
      'https://f-droid.org/packages/org.unifiedpush.distributor.sunup/';

  final Distribution distribution;
  final String? privacyPolicyUrl;
  final UnifiedPushDistributorChecker? hasUnifiedPushDistributor;
  final String unifiedPushDistributorInstallUrl;

  bool get hasPrivacyPolicyUrl =>
      privacyPolicyUrl != null && privacyPolicyUrl!.isNotEmpty;

  bool get canCheckUnifiedPushDistributor => hasUnifiedPushDistributor != null;
}
