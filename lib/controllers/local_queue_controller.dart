import 'dart:async';

import 'package:blossom_upload_queue_shim_for_ndk/blossom_upload_queue_shim_for_ndk.dart';
import 'package:broadcast_queue_shim_for_ndk/broadcast_queue_shim_for_ndk.dart';
import 'package:get/get.dart';

class LocalQueueController extends GetxController {
  final OfflineBroadcast _broadcastQueue = Get.find<OfflineBroadcast>();
  final OfflineBlossomUpload _uploadQueue = Get.find<OfflineBlossomUpload>();

  final RxList<QueuedBroadcast> pendingBroadcasts = <QueuedBroadcast>[].obs;
  final RxList<QueuedBlobUpload> pendingUploads = <QueuedBlobUpload>[].obs;
  final RxBool isRetrying = false.obs;
  final RxnString expandedItemId = RxnString();

  StreamSubscription<List<QueuedBroadcast>>? _broadcastSub;
  StreamSubscription<List<QueuedBlobUpload>>? _uploadSub;

  int get totalCount => pendingBroadcasts.length + pendingUploads.length;
  bool get hasPending => totalCount > 0;

  int get totalSucceeded {
    var sum = 0;
    for (final b in pendingBroadcasts) {
      sum += b.ackedRelays.length;
    }
    for (final u in pendingUploads) {
      sum += u.ackedServers.length;
    }
    return sum;
  }

  int get totalFailed {
    var sum = 0;
    for (final b in pendingBroadcasts) {
      sum += b.lastErrors.length;
    }
    for (final u in pendingUploads) {
      sum += u.lastErrors.length;
    }
    return sum;
  }

  @override
  void onInit() {
    super.onInit();
    _broadcastSub = _broadcastQueue.watchPending().listen(
      pendingBroadcasts.assignAll,
    );
    _uploadSub = _uploadQueue.watchPending().listen(pendingUploads.assignAll);
  }

  @override
  void onClose() {
    _broadcastSub?.cancel();
    _uploadSub?.cancel();
    super.onClose();
  }

  void toggleExpanded(String id) {
    expandedItemId.value = expandedItemId.value == id ? null : id;
  }

  Future<void> retryAll() async {
    if (isRetrying.value) return;
    isRetrying.value = true;
    try {
      await Future.wait([_broadcastQueue.retryNow(), _uploadQueue.retryNow()]);
    } finally {
      isRetrying.value = false;
    }
  }

  Future<void> rebroadcastEvent(String eventId) =>
      _broadcastQueue.rebroadcast(eventId);

  Future<void> reuploadBlob(String sha256) => _uploadQueue.reupload(sha256);
}
