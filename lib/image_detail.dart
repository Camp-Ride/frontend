import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

import 'main.dart';

class ImageDetailPage extends StatelessWidget {
  final String imageUrl;

  const ImageDetailPage({super.key, required this.imageUrl});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        navigatorKey.currentState?.pop();
      },
      child: Scaffold(
        body: Center(
          child: IgnorePointer(
            child: CachedNetworkImage(
              imageUrl: imageUrl,
              progressIndicatorBuilder: (context, url, downloadProgress) =>
                  CircularProgressIndicator(value: downloadProgress.progress),
              errorWidget: (context, url, error) => const Icon(Icons.error),
            ),
          ),
        ),
      ),
    );
  }
}
