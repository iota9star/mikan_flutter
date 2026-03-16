import 'package:riverpod_annotation/riverpod_annotation.dart';

import 'package:mikan/core/api/mikan_api.dart';
import 'package:mikan/core/common/extension.dart';
import 'package:mikan/core/models/season.dart';
import 'package:mikan/core/models/season_bangumi_rows.dart';
import 'package:mikan/core/models/year_season.dart';

part 'season_list_provider.g.dart';

@riverpod
class SeasonList extends _$SeasonList {
  @override
  AsyncValue<SeasonListState> build(List<YearSeason> years) {
    final seasons = years.map((e) => e.seasons).expand((element) => element).toList();
    return AsyncValue.data(SeasonListState(years: years, seasons: seasons));
  }

  Future<void> refresh([SeasonListState? current]) async {
    final newState = await AsyncValue.guard(() async {
      final currentState = current ?? state.value ?? const SeasonListState();
      final resetState = currentState.copyWith(loadIndex: 0);
      return _loadBangumis(resetState);
    });
    setIfMounted(ref, newState);
  }

  Future<void> loadMore() async {
    final currentState = state.value;
    if (currentState == null) {
      return;
    }

    final newState = await AsyncValue.guard(() => _loadBangumis(currentState));
    setIfMounted(ref, newState);
  }

  Future<SeasonListState> _loadBangumis(SeasonListState currentState) async {
    if (currentState.loadIndex >= currentState.seasons.length) {
      return currentState;
    }

    final season = currentState.seasons[currentState.loadIndex];
    final bangumiRows = await MikanApi.season(season.year, season.season);
    final seasonBangumis = SeasonBangumis(season: season, bangumiRows: bangumiRows);

    final newBangumis = currentState.loadIndex == 0 ? [seasonBangumis] : [...currentState.bangumis, seasonBangumis];

    return currentState.copyWith(bangumis: newBangumis, loadIndex: currentState.loadIndex + 1);
  }
}

class SeasonListState {
  const SeasonListState({this.seasons = const [], this.loadIndex = 0, this.years = const [], this.bangumis = const []});
  final List<Season> seasons;
  final int loadIndex;
  final List<YearSeason> years;
  final List<SeasonBangumis> bangumis;

  SeasonListState copyWith({
    List<Season>? seasons,
    int? loadIndex,
    List<YearSeason>? years,
    List<SeasonBangumis>? bangumis,
  }) {
    return SeasonListState(
      seasons: seasons ?? this.seasons,
      loadIndex: loadIndex ?? this.loadIndex,
      years: years ?? this.years,
      bangumis: bangumis ?? this.bangumis,
    );
  }
}
