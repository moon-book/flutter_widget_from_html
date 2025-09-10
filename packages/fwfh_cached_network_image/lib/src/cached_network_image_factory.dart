// TODO: remove ignore for file when our minimum core version >= 1.0
// ignore_for_file: deprecated_member_use

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:flutter_widget_from_html_core/flutter_widget_from_html_core.dart';

/// A mixin that can render IMG with `cached_network_image` plugin.
mixin CachedNetworkImageFactory on WidgetFactory {
  /// Uses a custom cache manager.
  BaseCacheManager? get cacheManager => null;

  @override
  Widget? buildImageWidget(BuildMetadata meta, ImageSource src) {
    final url = src.url;
    if (!url.startsWith(RegExp('https?://'))) {
      return super.buildImageWidget(meta, src);
    }

    if (url.contains('new-latex')) {
      return _LatexImageWidget(
        url: url,
        cacheManager: cacheManager,
        errorBuilder: (context, url, error) =>
            onErrorBuilder(context, meta, error, src) ?? widget0,
        meta: meta,
        src: src,
        widget0: widget0,
      );
    }

    return CachedNetworkImage(
      cacheManager: cacheManager,
      errorWidget: (context, _, error) =>
          onErrorBuilder(context, meta, error, src) ?? widget0,
      fit: BoxFit.scaleDown,
      filterQuality: FilterQuality.none,
      imageUrl: url,
      progressIndicatorBuilder: (context, _, progress) =>
          const Text('⏳', style: TextStyle(fontSize: 16)),
    );
  }
}

class _LatexImageWidget extends StatefulWidget {
  final String url;
  final BaseCacheManager? cacheManager;
  final Widget? Function(BuildContext, String, dynamic) errorBuilder;
  final BuildMetadata meta;
  final ImageSource src;
  final Widget widget0;

  const _LatexImageWidget({
    required this.url,
    this.cacheManager,
    required this.errorBuilder,
    required this.meta,
    required this.src,
    required this.widget0,
  });

  @override
  State<_LatexImageWidget> createState() => _LatexImageWidgetState();
}

class _LatexImageWidgetState extends State<_LatexImageWidget> {
  late final CachedNetworkImage _cachedNetworkImage;
  Size _size = Size.zero;

  @override
  void initState() {
    super.initState();
    _cachedNetworkImage = CachedNetworkImage(
      cacheManager: widget.cacheManager,
      errorWidget: (context, url, error) =>
          widget.errorBuilder(context, url, error) ?? widget.widget0,
      fit: BoxFit.scaleDown,
      imageUrl: widget.url,
      progressIndicatorBuilder: (context, url, progress) =>
          const Text('⏳', style: TextStyle(fontSize: 16)),
      imageBuilder: (context, imageProvider) {
        Image(image: imageProvider)
            .image
            .resolve(ImageConfiguration())
            .addListener(
          ImageStreamListener((ImageInfo info, bool sync) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              if (mounted) {
                setState(() {
                  _size = Size(info.image.width / 2.5, info.image.height / 2.5);
                });
              }
            });
          }),
        );
        return Image(image: imageProvider, fit: BoxFit.scaleDown);
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: _size.width,
      height: _size.height,
      child: _cachedNetworkImage,
    );
  }
}
