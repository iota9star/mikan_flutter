import 'package:flutter/material.dart';
import 'package:pixa/pixa.dart';

import 'package:mikan/res/assets.gen.dart';

/// Application-level network image built on the pixa pipeline.
///
/// This is a thin wrapper over [PixaImage.network] that centralizes the app's
/// image contract:
/// - **Decode size** is fully delegated to `PixaImage`, which derives the
///   physical decode target from the parent `BoxConstraints` × device pixel
///   ratio. Callers must NOT pass explicit sizes — just place this widget in a
///   bounded parent (`SizedBox`, `AspectRatio`, `Positioned.fill`, a grid cell,
///   …) and pixa decodes to exactly what's needed.
/// - **Loading / error placeholders** are unified to the mikan logo so every
///   cover, avatar, and banner looks consistent and can be restyled in one
///   place.
/// - **Clipping** (`borderRadius` / `circle`) is forwarded to pixa.
///
/// For `DecorationImage` / raw `ImageProvider` contexts (e.g. full-bleed
/// header backgrounds inside a `BoxDecoration`), use [pixaNetworkProvider].
class AppNetworkImage extends StatelessWidget {
  const AppNetworkImage(
    this.url, {
    super.key,
    this.width,
    this.height,
    this.fit = BoxFit.cover,
    this.alignment = Alignment.center,
    this.semanticLabel,
    this.gaplessPlayback = false,
    this.borderRadius,
    this.circle = false,
    this.headers,
    this.placeholder,
    this.errorBuilder,
    this.filterQuality = FilterQuality.medium,
  });

  /// Remote image URL. An empty url renders the error placeholder.
  final String url;

  /// Optional layout width (logical pixels). Pass it for fixed-size images
  /// (avatars, fixed-width covers); omit it when the parent already constrains
  /// the size (grid cell, Positioned.fill, SizedBox.expand). pixa derives the
  /// physical decode target from this × device pixel ratio.
  final double? width;

  /// Optional layout height (logical pixels). See [width].
  final double? height;

  /// Box fit applied to the decoded image.
  final BoxFit fit;

  /// Alignment of the image within its bounds (also the cover focus point).
  final AlignmentGeometry alignment;

  /// Semantic label for accessibility.
  final String? semanticLabel;

  /// Keep showing the previous frame while a new one loads.
  final bool gaplessPlayback;

  /// Optional rounded corners; pixa clips the image to this radius.
  final BorderRadius? borderRadius;

  /// Crop the image into a circle.
  final bool circle;

  /// Optional HTTP headers.
  final Map<String, String>? headers;

  /// Optional loading placeholder override. Defaults to a centered mikan logo.
  final PixaPlaceholder? placeholder;

  /// Optional error UI override. Defaults to a greyed mikan logo.
  final PixaErrorBuilder? errorBuilder;

  /// Filter quality for the rendered image.
  final FilterQuality filterQuality;

  @override
  Widget build(BuildContext context) {
    if (url.isEmpty) {
      return _errorPlaceholder();
    }
    // When no explicit size is given, expand to fill the parent so BoxFit
    // has tight constraints to work against. PixaImage's internal LayoutBuilder
    // then derives the decode target from these tight bounds.
    final image = PixaImage.network(
      url,
      width: width,
      height: height,
      fit: fit,
      alignment: alignment,
      semanticLabel: semanticLabel,
      gaplessPlayback: gaplessPlayback,
      filterQuality: filterQuality,
      borderRadius: borderRadius,
      circle: circle,
      headers: headers ?? const <String, String>{},
      placeholder: placeholder ?? _loadingPlaceholder(),
      errorBuilder: errorBuilder ?? (_, __, ___) => _errorPlaceholder(),
    );
    if (width == null && height == null) {
      return SizedBox.expand(child: image);
    }
    return image;
  }

  PixaPlaceholder _loadingPlaceholder() => const PixaPlaceholder.widget(_MikanPlaceholder());

  Widget _errorPlaceholder() => const _MikanPlaceholder(grey: true);
}

/// Default loading/error placeholder: the mikan logo, optionally greyed.
class _MikanPlaceholder extends StatelessWidget {
  const _MikanPlaceholder({this.grey = false});

  final bool grey;

  @override
  Widget build(BuildContext context) {
    final logo = Assets.mikan.image(width: 48.0);
    if (!grey) {
      return Center(child: logo);
    }
    return Center(
      child: ColorFiltered(colorFilter: const ColorFilter.mode(Color(0xFF9E9E9E), BlendMode.color), child: logo),
    );
  }
}

/// Builds a [PixaProvider] for a network image, for use inside
/// `DecorationImage` or anywhere a raw [ImageProvider] is required (e.g.
/// full-bleed header backgrounds that live in a `BoxDecoration`).
///
/// pixa decodes to [targetWidth]/[targetHeight] inside the Rust pipeline, so
/// callers should NOT additionally wrap the result in [ResizeImage]. Pass an
/// explicit [targetWidth] only when the image sits in an unbounded parent
/// (no layout size to derive from) and a decode cap is needed to avoid OOM.
ImageProvider<Object> pixaNetworkProvider(String url, {int? targetWidth, int? targetHeight}) {
  if (url.isEmpty) {
    return Assets.mikan.provider();
  }
  return PixaProvider.network(url, targetWidth: targetWidth, targetHeight: targetHeight);
}
