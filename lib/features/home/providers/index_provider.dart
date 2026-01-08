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

/// Immutable data class for index state
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
  @override
  Future<IndexData> build() async {
    // Load initial data on first build
    final results = await Future.wait([_loadIndex(), _loadOVA()]);
    return results[0];
  }

  /// Select a bangumi row
  void selectBangumiRow(BangumiRow? value) {
    final currentData = state.value;
    if (currentData != null) {
      state = AsyncValue.data(currentData.copyWith(selectedBangumiRow: value));
    }
  }

  /// Refresh all index data
  Future<void> refresh() async {
    final newState = await AsyncValue.guard(() async {
      final results = await Future.wait([_loadIndex(), _loadOVA()]);
      return results[0];
    });
    setIfMounted(ref, newState);
  }

  /// Select a season and load its bangumi rows
  Future<void> selectSeason(Season season) async {
    final previousState = state.value;
    if (previousState == null) {
      return;
    }

    state = AsyncValue.data(previousState.copyWith(selectedSeason: season));

    final newState = await AsyncValue.guard(() async {
      final bangumiRows = await MikanApi.season(season.year, season.season);
      return previousState.copyWith(selectedSeason: season, bangumiRows: bangumiRows);
    });
    setIfMounted(ref, newState);
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

/// Derived provider: 当前选中的季度
/// 从 indexProvider 中提取 selectedSeason
@riverpod
Season? selectedSeason(Ref ref) {
  return ref.watch(indexProvider).value?.selectedSeason;
}

/// Derived provider: 年份季度列表
/// 从 indexProvider 中提取 years
@riverpod
List<YearSeason> years(Ref ref) {
  return ref.watch(indexProvider).value?.years ?? [];
}
