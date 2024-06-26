import 'dart:math' as math;

import 'package:auto_size_text/auto_size_text.dart';
import 'package:easy_refresh/easy_refresh.dart';
import 'package:ff_annotation_route_core/ff_annotation_route_core.dart';
@FFArgumentImport()
import 'package:flutter/material.dart';
import 'package:flutter_widget_from_html_core/flutter_widget_from_html_core.dart';
import 'package:provider/provider.dart';

import '../../internal/extension.dart';
import '../../internal/image_provider.dart';
import '../../internal/kit.dart';
import '../../model/record_details.dart';
import '../../model/record_item.dart';
import '../../providers/op_model.dart';
import '../../providers/record_detail_model.dart';
import '../../res/assets.gen.dart';
import '../../topvars.dart';
import '../../widget/icon_button.dart';

@immutable
class RecordPage extends StatelessWidget {
  RecordPage({super.key, required this.record});

  final RecordItem record;
  final ValueNotifier<double> _scrollRatio = ValueNotifier(0);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final headerBackgroundColor = ColorTween(
      begin: theme.colorScheme.surface.withOpacity(0.0),
      end: theme.colorScheme.surface,
    );
    return AnnotatedRegion(
      value: context.fitSystemUiOverlayStyle,
      child: ChangeNotifierProvider(
        create: (_) => RecordDetailModel(record),
        child: Builder(
          builder: (context) {
            final model =
                Provider.of<RecordDetailModel>(context, listen: false);
            return Scaffold(
              body: NotificationListener<ScrollUpdateNotification>(
                onNotification: (ScrollUpdateNotification notification) {
                  final double offset = notification.metrics.pixels;
                  if (offset >= 0) {
                    _scrollRatio.value = math.min(1.0, offset / 96);
                  }
                  return true;
                },
                child: Stack(
                  children: [
                    _buildBody(context, theme, model),
                    Positioned(
                      left: 0,
                      right: 0,
                      top: 0,
                      child: ValueListenableBuilder<double>(
                        valueListenable: _scrollRatio,
                        builder: (_, ratio, __) {
                          final bgc = headerBackgroundColor.transform(ratio);
                          return Container(
                            decoration: BoxDecoration(
                              color: bgc,
                              border: ratio > 0.1
                                  ? Border(
                                      bottom: Divider.createBorderSide(
                                        context,
                                        color: theme.colorScheme.outlineVariant,
                                        width: 0.0,
                                      ),
                                    )
                                  : null,
                            ),
                            padding: EdgeInsets.only(
                              top: 12.0 + context.statusBarHeight,
                              left: 12.0,
                              right: 12.0,
                              bottom: 8.0,
                            ),
                            child: Row(
                              children: [
                                const BackIconButton(),
                                sizedBoxW16,
                                if (ratio > 0.88)
                                  Expanded(
                                    child: Selector<RecordDetailModel, String?>(
                                      selector: (_, model) =>
                                          model.recordDetail.name,
                                      shouldRebuild: (pre, next) => pre != next,
                                      builder: (_, value, __) {
                                        if (value == null) {
                                          return sizedBox;
                                        }
                                        return Text(
                                          value,
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                          style: theme.textTheme.titleLarge,
                                        );
                                      },
                                    ),
                                  )
                                else
                                  spacer,
                                sizedBoxW16,
                                IconButton(
                                  onPressed: () {
                                    model.recordDetail.share.share();
                                  },
                                  icon: const Icon(Icons.share_rounded),
                                ),
                                _buildSubscribeBtn(context, theme, model),
                                IconButton(
                                  onPressed: () {
                                    model.recordDetail.magnet
                                        .launchAppAndCopy();
                                  },
                                  icon: const Icon(Icons.downloading_rounded),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildBody(
    BuildContext context,
    ThemeData theme,
    RecordDetailModel model,
  ) {
    final safeArea = MediaQuery.of(context).padding;
    final scale = (64.0 + context.screenWidth) / context.screenWidth;
    return Positioned.fill(
      child: Selector<RecordDetailModel, RecordDetail>(
        selector: (context, model) => model.recordDetail,
        shouldRebuild: (pre, next) => pre != next,
        builder: (context, detail, __) {
          final list = [
            Stack(
              children: [
                if (!detail.cover.endsWith('noimageavailble_icon.png'))
                  Positioned.fill(
                    child: Transform.scale(
                      scale: scale,
                      child: Container(
                        decoration: BoxDecoration(
                          image: DecorationImage(
                            fit: BoxFit.fitWidth,
                            image: CacheImage(detail.cover),
                            alignment: Alignment.topCenter,
                            isAntiAlias: true,
                          ),
                        ),
                        foregroundDecoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              theme.colorScheme.surface.withOpacity(0.64),
                              theme.colorScheme.surface,
                            ],
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            stops: const [0.0, 0.56],
                          ),
                        ),
                      ),
                    ),
                  ),
                Padding(
                  padding: EdgeInsets.only(
                    top: 120.0 + context.statusBarHeight,
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildBangumiCover(context, detail),
                      sizedBoxW16,
                      Expanded(
                        child: SelectionArea(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              sizedBoxH12,
                              AutoSizeText(
                                detail.name,
                                maxLines: 3,
                                style: theme.textTheme.titleLarge!.copyWith(
                                  color: theme.colorScheme.secondary,
                                ),
                              ),
                              sizedBoxH8,
                              ...detail.more.entries.map(
                                (e) => Text(
                                  '${e.key}: ${e.value}',
                                  softWrap: true,
                                  style: theme.textTheme.bodyMedium,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            Transform.scale(
              scale: scale,
              child: Container(
                color: theme.colorScheme.surface,
                height: 36.0,
              ),
            ),
            if (detail.title.isNotBlank)
              SelectionArea(
                child: Text(
                  detail.title,
                  style: theme.textTheme.bodyMedium,
                ),
              ),
            sizedBoxH8,
            if (!detail.tags.isNullOrEmpty)
              SelectionArea(
                child: Wrap(
                  spacing: 6.0,
                  runSpacing: 6.0,
                  children: [
                    if (record.size.isNotBlank)
                      Container(
                        padding: edgeH6V4,
                        decoration: BoxDecoration(
                          color: theme.colorScheme.secondaryContainer,
                          borderRadius: borderRadius8,
                        ),
                        child: Text(
                          record.size,
                          style: theme.textTheme.labelSmall!.copyWith(
                            color: theme.colorScheme.onSecondaryContainer,
                          ),
                        ),
                      ),
                    ...List.generate(
                      detail.tags.length,
                      (index) {
                        return Container(
                          padding: edgeH6V4,
                          decoration: BoxDecoration(
                            color: theme.colorScheme.tertiaryContainer,
                            borderRadius: borderRadius8,
                          ),
                          child: Text(
                            detail.tags[index],
                            style: theme.textTheme.labelMedium!.copyWith(
                              color: theme.colorScheme.onTertiaryContainer,
                            ),
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),
            sizedBoxH24,
            if (detail.intro.isNotEmpty)
              Text(
                '概况简介',
                style: theme.textTheme.titleLarge,
              ),
            sizedBoxH12,
            SelectionArea(
              child: HtmlWidget(
                detail.intro,
                onTapUrl: (url) {
                  url.launchAppAndCopy();
                  return true;
                },
                customWidgetBuilder: (element) {
                  if (element.localName == 'img') {
                    final String? src = element.attributes['src'];
                    if (src.isNotBlank) {
                      return _buildImageWidget(src!);
                    }
                  }
                  return null;
                },
              ),
            ),
          ];
          return EasyRefresh(
            onRefresh: model.refresh,
            refreshOnStart: true,
            header: defaultHeader,
            child: ListView.builder(
              itemBuilder: (context, index) {
                return list[index];
              },
              itemCount: list.length,
              padding: EdgeInsets.only(
                left: 24.0,
                right: 24.0,
                bottom: safeArea.bottom + 36.0,
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildBangumiCover(
    BuildContext context,
    RecordDetail record,
  ) {
    return ClipRRect(
      borderRadius: borderRadius12,
      child: Image(
        image: CacheImage(record.cover),
        width: 136.0,
        loadingBuilder: (_, child, event) {
          return event == null
              ? child
              : AspectRatio(
                  aspectRatio: 3 / 4,
                  child: Container(
                    padding: edge28,
                    child: Center(
                      child: Assets.mikan.image(),
                    ),
                  ),
                );
        },
        errorBuilder: (_, __, ___) {
          return AspectRatio(
            aspectRatio: 3 / 4,
            child: Container(
              decoration: BoxDecoration(
                image: DecorationImage(
                  image: Assets.mikan.provider(),
                  fit: BoxFit.cover,
                  colorFilter: const ColorFilter.mode(
                    Colors.grey,
                    BlendMode.color,
                  ),
                ),
              ),
            ),
          );
        },
        frameBuilder: (_, child, ___, ____) {
          return child;
        },
      ),
    );
  }

  Widget _buildSubscribeBtn(
    BuildContext context,
    ThemeData theme,
    RecordDetailModel model,
  ) {
    return Selector<RecordDetailModel, bool>(
      selector: (_, model) => model.recordDetail.subscribed,
      shouldRebuild: (pre, next) => pre != next,
      builder: (_, subscribed, __) {
        final recordDetail = model.recordDetail;
        return subscribed
            ? IconButton(
                tooltip: '取消订阅',
                icon: Icon(
                  Icons.favorite_rounded,
                  color: theme.colorScheme.error,
                ),
                onPressed: () {
                  context.read<OpModel>().subscribeBangumi(
                    recordDetail.id!,
                    recordDetail.subscribed,
                    onSuccess: () {
                      recordDetail.subscribed = !recordDetail.subscribed;
                      context.read<RecordDetailModel>().subscribeChanged();
                    },
                    onError: (msg) {
                      '订阅失败：$msg'.toast();
                    },
                  );
                },
              )
            : IconButton(
                tooltip: '订阅',
                icon: const Icon(Icons.favorite_border_rounded),
                onPressed: () {
                  context.read<OpModel>().subscribeBangumi(
                    recordDetail.id!,
                    recordDetail.subscribed,
                    onSuccess: () {
                      recordDetail.subscribed = !recordDetail.subscribed;
                      context.read<RecordDetailModel>().subscribeChanged();
                    },
                    onError: (msg) {
                      '订阅失败：$msg'.toast();
                    },
                  );
                },
              );
      },
    );
  }

  Widget _buildImageWidget(String url) {
    final placeholder = AspectRatio(
      aspectRatio: 16 / 9,
      child: Container(
        width: double.infinity,
        color: Colors.grey.withOpacity(0.24),
        child: Center(
          child: Image.asset(
            Assets.mikan.path,
            width: 56.0,
          ),
        ),
      ),
    );
    return ClipRRect(
      borderRadius: borderRadius12,
      child: Image(
        image: CacheImage(url),
        loadingBuilder: (_, child, event) {
          return event == null ? child : placeholder;
        },
        errorBuilder: (_, __, ___) {
          return placeholder;
        },
      ),
    );
  }
}
