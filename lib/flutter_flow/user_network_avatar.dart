import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';

/// Loads a user avatar from a URL. On web, prefers the HTML image element when
/// possible so images still decode if the server [Content-Type] does not
/// match the real format (common when PNG bytes were uploaded as JPEG).
Widget userNetworkAvatar({
  required String imageUrl,
  required double width,
  required double height,
  required BoxFit fit,
  Widget? placeholder,
  required Widget Function(BuildContext context, Object error) errorBuilder,
}) {
  final ph = placeholder ??
      Center(
        child: SizedBox(
          width: width * 0.35,
          height: height * 0.35,
          child: const CircularProgressIndicator(strokeWidth: 2),
        ),
      );

  if (kIsWeb) {
    return Image.network(
      imageUrl,
      width: width,
      height: height,
      fit: fit,
      webHtmlElementStrategy: WebHtmlElementStrategy.prefer,
      loadingBuilder: (context, child, loadingProgress) {
        if (loadingProgress == null) {
          return child;
        }
        return ph;
      },
      errorBuilder: (context, error, stackTrace) =>
          errorBuilder(context, error),
    );
  }

  return CachedNetworkImage(
    imageUrl: imageUrl,
    width: width,
    height: height,
    fit: fit,
    placeholder: (context, url) => ph,
    errorWidget: (context, url, error) => errorBuilder(context, error),
  );
}
