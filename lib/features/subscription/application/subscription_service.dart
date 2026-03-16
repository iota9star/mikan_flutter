import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:riverpod/experimental/mutation.dart';

import 'package:mikan/core/api/mikan_api.dart';
import 'package:mikan/core/common/extension.dart';
import 'package:mikan/features/home/application/index_provider.dart';
import 'package:mikan/features/season/application/season_list_provider.dart';
import 'package:mikan/features/season/application/season_provider.dart';
import 'package:mikan/features/subscription/application/subscribed_provider.dart';
import 'package:mikan/features/subscription/application/subscribed_season_provider.dart';

/// Mutation for tracking subscription state per bangumi.
///
/// Usage:
/// - Watch state: `ref.watch(subscribeMutation(bangumiId))`
/// - Trigger: `subscribeMutation(bangumiId).run(ref, () => ...)`
final subscribeMutation = Mutation<String>();

/// Helper function to subscribe or unsubscribe from a bangumi.
///
/// If [subscribed] is true, the bangumi will be unsubscribed.
/// If [subscribed] is false, the bangumi will be subscribed.
Future<void> subscribeBangumi(WidgetRef ref, String bangumiId, bool subscribed, {String? subgroupId}) async {
  if (bangumiId.isNullOrBlank) {
    '番组id为空，忽略当前订阅'.toast();
    return;
  }

  await subscribeMutation(bangumiId).run(ref, (_) async {
    if (subscribed) {
      await MikanApi.unsubscribeBangumi(bangumiId, subtitleGroupId: subgroupId);
    } else {
      await MikanApi.subscribeBangumi(bangumiId, subtitleGroupId: subgroupId);
    }
    return bangumiId;
  });

  ref.invalidate(indexProvider);
  ref.invalidate(seasonProvider);
  ref.invalidate(seasonListProvider);
  ref.invalidate(subscribedBangumisProvider);
  ref.invalidate(subscribedSeasonProvider);
}
