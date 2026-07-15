import 'package:kache_connectivity_plus/kache_connectivity_plus.dart';

import 'package:mikan/core/cache/kache_bindings.dart';
import 'package:mikan/core/models/bangumi.dart';
import 'package:mikan/core/models/bangumi_details.dart';
import 'package:mikan/core/models/fonts.dart';
import 'package:mikan/core/models/index.dart';
import 'package:mikan/core/models/record_item.dart';
import 'package:mikan/core/models/record_details.dart';
import 'package:mikan/core/models/search.dart';
import 'package:mikan/core/models/season_data.dart';
import 'package:mikan/core/models/season_gallery.dart';

/// Central initialization for the Kache caching layer.
///
/// Wires together three Kache integrations:
/// - [HiveKacheStore] (our custom [KachePersistenceBackend] backed by Hive CE)
///   for cross-restart persistence, reusing every already-registered Hive
///   [TypeAdapter].
/// - [ConnectivityPlusNetwork] for automatic reconnect revalidation.
/// - Typed [KachePersistenceBinding]s for every model that needs persisted
///   caching.
///
/// Call [init] once during app bootstrap, after [MyHive.init] (which registers
/// the generated Hive adapters and opens the Hive data directory) and
/// [registerKacheAdapters] (which registers the hand-written adapters).
class KacheInit {
  const KacheInit._();

  static late final KacheClient client;
  static late final HiveKacheStore store;

  // --- Bindings (one per persisted model type) -----------------------------
  //
  // Each binding is created from [store] and carries a stable fingerprint.
  // The fingerprint must change if the serialization format changes.

  static late final KachePersistenceBinding<Index> indexBinding;
  static late final KachePersistenceBinding<List<RecordItem>> recordListBinding;
  static late final KachePersistenceBinding<RecordDetail> recordDetailBinding;
  static late final KachePersistenceBinding<List<SeasonGallery>> seasonGalleryListBinding;
  static late final KachePersistenceBinding<SeasonData> seasonDataBinding;
  static late final KachePersistenceBinding<BangumiDetail> bangumiDetailBinding;
  static late final KachePersistenceBinding<List<Bangumi>> bangumiListBinding;
  static late final KachePersistenceBinding<SearchResult> searchResultBinding;
  static late final KachePersistenceBinding<List<Font>> fontListBinding;

  static bool _initialized = false;

  /// Initializes the Kache client, persistence store, network source, and all
  /// model bindings. Idempotent — safe to call multiple times.
  static Future<void> init() async {
    if (_initialized) {
      return;
    }

    store = await HiveKacheStore.open(boxName: 'kache-cache');

    // Each binding's fingerprint identifies the storage format. Bump the
    // version suffix if a model's fields change incompatibly.
    indexBinding = _Binding(store, 'mikan-index:v1');
    recordListBinding = _Binding(store, 'mikan-record-list:v1');
    recordDetailBinding = _Binding(store, 'mikan-record-detail:v1');
    seasonGalleryListBinding = _Binding(store, 'mikan-season-gallery-list:v1');
    seasonDataBinding = _Binding(store, 'mikan-season-data:v1');
    bangumiDetailBinding = _Binding(store, 'mikan-bangumi-detail:v1');
    bangumiListBinding = _Binding(store, 'mikan-bangumi-list:v1');
    searchResultBinding = _Binding(store, 'mikan-search-result:v1');
    fontListBinding = _Binding(store, 'mikan-font-list:v1');

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

/// A simple [KachePersistenceBinding] that binds a type to a [HiveKacheStore]
/// with a stable fingerprint string.
///
/// The fingerprint must be unique per storage interpretation. Changing a
/// model's serialized fields requires a new fingerprint (e.g. bump the
/// version suffix).
class _Binding<T> extends KachePersistenceBinding<T> {
  _Binding(HiveKacheStore backend, String fingerprint)
      : super(backend: backend, fingerprint: fingerprint);
}
