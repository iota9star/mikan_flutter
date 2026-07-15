import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kache/kache.dart';
import 'package:kache_riverpod/kache_riverpod.dart';

import 'package:mikan/core/cache/kache_init.dart';

/// Provides the application-wide [KacheClient].
///
/// The client is created during bootstrap ([KacheInit.init]) and lives for the
/// entire application lifetime.
final kacheClientProvider = Provider<KacheClient>((ref) {
  return KacheInit.client;
});
