import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:telegram_frontend/ui/core/themes/colors.dart';

class CircleNetworkAvartar extends StatelessWidget {
  const CircleNetworkAvartar({
    required this.imageUrl,
    super.key,
    this.height,
    this.width,
  });

  final double? height;
  final double? width;
  final String imageUrl;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width,
      height: height,
      child: ClipOval(
        child: CachedNetworkImage(
          imageUrl: imageUrl,
          fit: BoxFit.cover,
          placeholder: (context, url) => const Center(
            child: CupertinoActivityIndicator(),
          ),
          errorWidget: (context, url, error) => const Icon(
            Icons.error,
            color: AppColors.telegramBlue,
          ),
        ),
      ),
    );
  }
}
