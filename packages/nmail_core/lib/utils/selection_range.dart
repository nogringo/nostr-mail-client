/// Ids between [anchorId] and [targetId] in [orderedIds], bounds included.
/// Empty when either id is absent from the list.
List<String> idsInRange(
  List<String> orderedIds,
  String anchorId,
  String targetId,
) {
  final anchor = orderedIds.indexOf(anchorId);
  final target = orderedIds.indexOf(targetId);
  if (anchor == -1 || target == -1) return const [];

  final start = anchor < target ? anchor : target;
  final end = anchor < target ? target : anchor;
  return orderedIds.sublist(start, end + 1);
}
