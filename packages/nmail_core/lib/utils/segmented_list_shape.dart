import 'package:flutter/material.dart';

/// Vertical gap between two rows of a segmented list.
/// Material 3 `ListTokens.SegmentedGap`.
const segmentedListGap = 2.0;

/// Shape for one row of a Material 3 segmented list, ported from Compose's
/// `ListItemDefaults.segmentedShapes(index, count)`.
///
/// Rows sit at `CornerExtraSmall`, and two things step up to `CornerLarge`: the
/// outer edges of the group, and the selected row on all four corners, so the
/// selection detaches itself from the group instead of relying on colour alone.
///
/// Hand-rolled because Flutter ships no segmented-list component; 3.44 has only
/// `DynamicSchemeVariant.expressive`, which is about colour, not shape.
RoundedRectangleBorder segmentedListShape({
  required int index,
  required int count,
  bool isSelected = false,
}) {
  const large = Radius.circular(16);
  const extraSmall = Radius.circular(4);

  if (isSelected) {
    return const RoundedRectangleBorder(borderRadius: BorderRadius.all(large));
  }

  final isFirst = index == 0;
  final isLast = index == count - 1;

  return RoundedRectangleBorder(
    borderRadius: BorderRadius.only(
      topLeft: isFirst ? large : extraSmall,
      topRight: isFirst ? large : extraSmall,
      bottomLeft: isLast ? large : extraSmall,
      bottomRight: isLast ? large : extraSmall,
    ),
  );
}
