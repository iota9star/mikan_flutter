import 'package:easy_refresh/easy_refresh.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import 'package:mikan/core/api/mikan_api.dart';
import 'package:mikan/core/common/extension.dart';
import 'package:mikan/core/models/season.dart';
import 'package:mikan/core/models/season_gallery.dart';
import 'package:mikan/core/models/year_season.dart';

part 'subscribed_season_provider.g.dart';

class SubscribedSeasonState {
  SubscribedSeasonState({
    this.seasons = const [],
    this.loadIndex = 0,
    this.years = const [],
    this.galleries = const [],
  });
  final List<Season> seasons;
  final int loadIndex;
  final List<YearSeason> years;
  final List<SeasonGallery> galleries;

  SubscribedSeasonState copyWith({
    List<Season>? seasons,
    int? loadIndex,
    List<YearSeason>? years,
    List<SeasonGallery>? galleries,
  }) {
    return SubscribedSeasonState(
      seasons: seasons ?? this.seasons,
      loadIndex: loadIndex ?? this.loadIndex,
      years: years ?? this.years,
      galleries: galleries ?? this.galleries,
    );
  }
}

@riverpod
class SubscribedSeason extends _$SubscribedSeason {
  @override
  SubscribedSeasonState build(List<YearSeason> years, List<SeasonGallery> galleries) {
    final seasons = years.map((e) => e.seasons).expand((element) => element).toList();
    return SubscribedSeasonState(
      years: years,
      seasons: seasons,
      galleries: galleries,
      loadIndex: _resolveNextLoadIndex(seasons, galleries),
    );
  }

  Future<IndicatorResult> _loadBangumis() async {
    if (state.loadIndex >= state.seasons.length) {
      return IndicatorResult.noMore;
    }
    final season = state.seasons[state.loadIndex];
    try {
      final bangumis = await MikanApi.mySubscribedSeasonBangumi(season.year, season.season);
      final seasonGallery = SeasonGallery(
        year: season.year,
        season: season.season,
        title: season.title,
        active: season.active,
        bangumis: bangumis,
      );
      if (state.loadIndex == 0) {
        updateIfMounted(
          ref,
          (current) => current.copyWith(galleries: [seasonGallery], loadIndex: current.loadIndex + 1),
        );
      } else {
        updateIfMounted(
          ref,
          (current) =>
              current.copyWith(galleries: [...current.galleries, seasonGallery], loadIndex: current.loadIndex + 1),
        );
      }
      return IndicatorResult.success;
    } catch (e) {
      '获取 ${season.title} 订阅失败 $e'.toast();
      return IndicatorResult.fail;
    }
  }

  Future<IndicatorResult> refresh() async {
    final currentState = state;
    if (currentState.galleries.isEmpty) {
      state = currentState.copyWith(loadIndex: 0, galleries: const []);
      return _loadBangumis();
    }

    try {
      final refreshedGalleries = await Future.wait(
        currentState.galleries.map((gallery) async {
          final bangumis = await MikanApi.mySubscribedSeasonBangumi(gallery.year, gallery.season);
          return SeasonGallery(
            year: gallery.year,
            season: gallery.season,
            title: gallery.title,
            active: gallery.active,
            bangumis: bangumis,
          );
        }),
      );

      if (!ref.mounted) {
        return IndicatorResult.fail;
      }

      state = currentState.copyWith(
        galleries: refreshedGalleries,
        loadIndex: _resolveNextLoadIndex(currentState.seasons, refreshedGalleries),
      );
      return IndicatorResult.success;
    } catch (e) {
      '刷新季度订阅失败 $e'.toast();
      return IndicatorResult.fail;
    }
  }

  Future<IndicatorResult> loadMore() {
    return _loadBangumis();
  }

  int _resolveNextLoadIndex(List<Season> seasons, List<SeasonGallery> galleries) {
    if (galleries.isEmpty) {
      return 0;
    }

    final loadedKeys = galleries.map((gallery) => '${gallery.year}-${gallery.season}').toSet();
    var maxIndex = -1;

    for (var index = 0; index < seasons.length; index++) {
      final season = seasons[index];
      if (loadedKeys.contains('${season.year}-${season.season}')) {
        maxIndex = index;
      }
    }

    return maxIndex + 1;
  }
}
