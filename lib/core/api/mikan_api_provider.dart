import 'package:hooks_riverpod/hooks_riverpod.dart';

import 'package:mikan/core/api/mikan_api.dart';
import 'package:mikan/core/models/bangumi.dart';
import 'package:mikan/core/models/bangumi_details.dart';
import 'package:mikan/core/models/bangumi_row.dart';
import 'package:mikan/core/models/index.dart';
import 'package:mikan/core/models/record_details.dart';
import 'package:mikan/core/models/record_item.dart';
import 'package:mikan/core/models/search.dart';
import 'package:mikan/core/models/season_gallery.dart';
import 'package:mikan/core/models/user.dart';

/// Provides the [MikanApiService] via Riverpod for dependency injection.
///
/// Usage: `ref.read(mikanApiProvider).index(year, season)`
/// Override in tests: `mikanApiProvider.overrideWithValue(mockApi)`
final mikanApiProvider = Provider<MikanApiService>((ref) {
  return MikanApiService._();
});

/// Thin wrapper around static [MikanApi] methods for Riverpod DI.
///
/// All methods delegate to the underlying static implementation.
/// This wrapper enables provider-level dependency injection and test mocking.
class MikanApiService {
  MikanApiService._();

  // ==================== Data APIs ====================

  Future<Index> index([String? year, String? seasonStr]) => MikanApi.index(year, seasonStr);

  Future<List<BangumiRow>> season(String year, String seasonStr) => MikanApi.season(year, seasonStr);

  Future<List<RecordItem>> day([int predate = 0, int enddate = 1]) => MikanApi.day(predate, enddate);

  Future<SearchResult> search(String searchstr, {String? subgroupid, int page = 1}) =>
      MikanApi.search(searchstr, subgroupid: subgroupid, page: page);

  Future<List<RecordItem>> list([int page = 1]) => MikanApi.list(page);

  Future<List<SeasonGallery>> subgroup(String subgroupId) => MikanApi.subgroup(subgroupId);

  Future<BangumiDetail> bangumi(String bangumiId) => MikanApi.bangumi(bangumiId);

  Future<List<RecordItem>> bangumiMore(String bangumiId, String subtitleGroupId, {int take = 65}) =>
      MikanApi.bangumiMore(bangumiId, subtitleGroupId, take: take);

  Future<RecordDetail> details(String episodeId) => MikanApi.details(episodeId);

  Future<List<RecordItem>> ova() => MikanApi.ova();

  // ==================== Subscription APIs ====================

  Future<List<Bangumi>> mySubscribed() => MikanApi.mySubscribed();

  Future<List<Bangumi>> mySubscribedSeasonBangumi(String year, String seasonStr) =>
      MikanApi.mySubscribedSeasonBangumi(year, seasonStr);

  Future<String> subscribeBangumi(String bangumiId, {String? subtitleGroupId}) =>
      MikanApi.subscribeBangumi(bangumiId, subtitleGroupId: subtitleGroupId);

  Future<String> unsubscribeBangumi(String bangumiId, {String? subtitleGroupId}) =>
      MikanApi.unsubscribeBangumi(bangumiId, subtitleGroupId: subtitleGroupId);

  // ==================== Auth APIs ====================

  Future<User?> getUser() => MikanApi.getUser();

  Future<String> login(String userName, String password, {String? returnUrl}) =>
      MikanApi.login(userName, password, returnUrl: returnUrl);

  Future<void> logout() => MikanApi.logout();

  Future<void> clearCookies() => MikanApi.clearCookies();

  Future<String> register(
    String userName,
    String email,
    String password,
    String confirmPassword, {
    String? qq,
  }) =>
      MikanApi.register(userName, email, password, confirmPassword, qq: qq);

  Future<String> forgotPassword(String email) => MikanApi.forgotPassword(email);

  // ==================== Other APIs ====================

  Future<dynamic> release() => MikanApi.release();

  Future<List<dynamic>> fonts() => MikanApi.fonts();
}
