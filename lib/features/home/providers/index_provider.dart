import 'package:collection/collection.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../../mikan_api.dart';
import '../../../../../shared/internal/extension.dart';
import '../../../../../shared/models/announcement.dart';
import '../../../../../shared/models/bangumi_row.dart';
import '../../../../../shared/models/carousel.dart';
import '../../../../../shared/models/index.dart' as model;
import '../../../../../shared/models/record_item.dart';
import '../../../../../shared/models/season.dart';
import '../../../../../shared/models/user.dart';
import '../../../../../shared/models/year_season.dart';

part 'index_provider.g.dart';

class IndexData {
  const IndexData({
    this.years = const [],
    this.bangumiRows = const [],
    this.ovas = const [],
    this.carousels = const [],
    this.selectedSeason,
    this.user,
    this.announcements,
    this.selectedBangumiRow,
  });

  final List<YearSeason> years;
  final List<BangumiRow> bangumiRows;
  final List<RecordItem> ovas;
  final List<Carousel> carousels;
  final Season? selectedSeason;
  final User? user;
  final List<Announcement>? announcements;
  final BangumiRow? selectedBangumiRow;

  IndexData copyWith({
    List<YearSeason>? years,
    List<BangumiRow>? bangumiRows,
    List<RecordItem>? ovas,
    List<Carousel>? carousels,
    Season? selectedSeason,
    User? user,
    List<Announcement>? announcements,
    BangumiRow? selectedBangumiRow,
  }) {
    return IndexData(
      years: years ?? this.years,
      bangumiRows: bangumiRows ?? this.bangumiRows,
      ovas: ovas ?? this.ovas,
      carousels: carousels ?? this.carousels,
      selectedSeason: selectedSeason ?? this.selectedSeason,
      user: user ?? this.user,
      announcements: announcements ?? this.announcements,
      selectedBangumiRow: selectedBangumiRow ?? this.selectedBangumiRow,
    );
  }
}

@riverpod
class Index extends _$Index {
  int _requestToken = 0;

  @override
  Future<IndexData> build() async {
    final results = await Future.wait([_loadIndex(), _loadOVA()]);
    return results[0];
  }

  void selectBangumiRow(BangumiRow? value) {
    final currentData = state.value;
    if (currentData != null) {
      state = AsyncValue.data(currentData.copyWith(selectedBangumiRow: value));
    }
  }

  Future<void> refresh() async {
    final newState = await AsyncValue.guard(() async {
      final results = await Future.wait([_loadIndex(), _loadOVA()]);
      return results[0];
    });
    setIfMounted(ref, newState);
  }

  Future<void> selectSeason(Season season) async {
    final currentState = state.value;
    if (currentState == null) {
      return;
    }

    final currentToken = ++_requestToken;

    state = const AsyncValue.loading();

    final newState = await AsyncValue.guard(() async {
      final bangumiRows = await MikanApi.season(season.year, season.season);

      if (currentToken != _requestToken) {
        throw Exception('Request cancelled by newer request');
      }

      final latestState = state.value ?? currentState;
      return latestState.copyWith(selectedSeason: season, bangumiRows: bangumiRows);
    });

    if (currentToken == _requestToken) {
      setIfMounted(ref, newState);
    }
  }

  Future<IndexData> _loadIndex() async {
    final index = await MikanApi.index();
    final currentData = state.value ?? const IndexData();
    return _buildIndexData(index, currentData.ovas);
  }

  Future<IndexData> _loadOVA() async {
    final data = await MikanApi.day(-1, -1);
    final currentData = state.value ?? const IndexData();
    return currentData.copyWith(ovas: data);
  }

  IndexData _buildIndexData(model.Index? index, List<RecordItem> ovas) {
    if (index == null) {
      return IndexData(ovas: ovas);
    }

    Season? selectedSeason;
    if (!index.years.isNullOrEmpty) {
      for (final year in index.years) {
        selectedSeason = year.seasons.firstWhereOrNull((element) => element.active);
        if (selectedSeason != null) {
          break;
        }
      }
    }

    selectedSeason ??= index.years.firstOrNull?.seasons.firstOrNull;

    return IndexData(
      years: index.years,
      bangumiRows: index.bangumiRows,
      selectedBangumiRow: index.bangumiRows.firstOrNull,
      carousels: index.carousels,
      user: index.user,
      announcements: index.announcements,
      selectedSeason: selectedSeason,
      ovas: ovas,
    );
  }
}

@riverpod
Season? selectedSeason(Ref ref) {
  return ref.watch(indexProvider).value?.selectedSeason;
}

@riverpod
List<YearSeason> years(Ref ref) {
  return ref.watch(indexProvider).value?.years ?? [];
}
