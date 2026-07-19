import 'package:hive_ce/hive.dart';
import 'package:kache_connectivity_plus/kache_connectivity_plus.dart';
import 'package:kache_hive_ce/kache_hive_ce.dart';

import 'package:mikan/core/models/bangumi_details.dart';
import 'package:mikan/core/models/cached_list.dart';
import 'package:mikan/core/models/index.dart';
import 'package:mikan/core/models/record_details.dart';
import 'package:mikan/core/models/search.dart';
import 'package:mikan/core/models/season_data.dart';

/// Central initialization for the Kache caching layer.
///
/// Wires together three Kache integrations:
/// - [HiveCeKacheStore] with `bindAdapter` for cross-restart persistence,
///   reusing every already-registered Hive [TypeAdapter].
/// - [ConnectivityPlusNetwork] for automatic reconnect revalidation.
/// - Typed bindings for every model that needs persisted caching.
///
/// Call [init] once during app bootstrap, after [Hive.registerAdapters].
class KacheInit {
  const KacheInit._();

  static late final KacheClient client;
  static late final HiveCeKacheStore store;

  // --- Bindings (one per persisted model type) -----------------------------

  static late final HiveCeAdapterBinding<Index> indexBinding;
  static late final HiveCeAdapterBinding<RecordDetail> recordDetailBinding;
  static late final HiveCeAdapterBinding<SeasonData> seasonDataBinding;
  static late final HiveCeAdapterBinding<BangumiDetail> bangumiDetailBinding;
  static late final HiveCeAdapterBinding<SearchResult> searchResultBinding;
  static late final HiveCeAdapterBinding<CachedRecordList> recordListBinding;
  static late final HiveCeAdapterBinding<CachedSeasonGalleryList> seasonGalleryListBinding;
  static late final HiveCeAdapterBinding<CachedBangumiList> bangumiListBinding;
  static late final HiveCeAdapterBinding<CachedFontList> fontListBinding;

  static bool _initialized = false;

  /// Initializes the Kache client, persistence store, network source, and all
  /// model bindings. Idempotent.
  static Future<void> init() async {
    if (_initialized) {
      return;
    }

    // Open the kache persistence box.
    //
    // Uses a versioned box name ('kache-cache-v2') so old data from previous
    // kache integration versions (which used incompatible envelope formats)
    // is simply ignored — the old box stays on disk harmlessly and the new
    // one starts fresh. If the new box itself becomes corrupted, crash
    // recovery deletes and recreates it. If that still fails, we fall back to
    // a non-persistent in-memory box so the app can boot (cache is rebuilt
    // from network) instead of crashing on startup.
    const boxName = 'kache-cache-v2';
    HiveCeKacheStore? opened;
    try {
      opened = await HiveCeKacheStore.open(boxName: boxName);
    } on Object {
      try {
        await Hive.deleteBoxFromDisk(boxName);
        opened = await HiveCeKacheStore.open(boxName: boxName);
      } on Object {
        // Disk is unusable; degrade to an ephemeral in-memory store.
        final memBox = await Hive.openBox<Object?>('$boxName-mem');
        opened = HiveCeKacheStore.fromBox(memBox, ownership: HiveCeBoxOwnership.owned);
      }
    }
    store = opened;

    indexBinding = store.bindAdapter<Index>(IndexAdapter());
    recordDetailBinding = store.bindAdapter<RecordDetail>(RecordDetailAdapter());
    seasonDataBinding = store.bindAdapter<SeasonData>(SeasonDataAdapter());
    bangumiDetailBinding = store.bindAdapter<BangumiDetail>(BangumiDetailAdapter());
    searchResultBinding = store.bindAdapter<SearchResult>(SearchResultAdapter());
    recordListBinding = store.bindAdapter<CachedRecordList>(CachedRecordListAdapter());
    seasonGalleryListBinding = store.bindAdapter<CachedSeasonGalleryList>(CachedSeasonGalleryListAdapter());
    bangumiListBinding = store.bindAdapter<CachedBangumiList>(CachedBangumiListAdapter());
    fontListBinding = store.bindAdapter<CachedFontList>(CachedFontListAdapter());

    final network = ConnectivityPlusNetwork();

    client = KacheClient(
      persistence: store,
      persistenceOwnership: KachePersistenceOwnership.owned,
      network: network,
      networkOwnership: KacheNetworkOwnership.owned,
    );

    _initialized = true;
  }
}
