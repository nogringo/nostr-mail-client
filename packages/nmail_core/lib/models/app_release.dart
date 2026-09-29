class AppRelease {
  const AppRelease({required this.version, required this.url});

  factory AppRelease.fromGithubJson(Map<String, dynamic> json) => AppRelease(
    version: (json['tag_name'] as String).replaceFirst(RegExp('^v'), ''),
    url: json['html_url'] as String,
  );

  final String version;
  final String url;
}
