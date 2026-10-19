import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';

class ArtworkImage extends StatelessWidget {
  const ArtworkImage({
    super.key,
    required this.artworkUri,
    this.size,
    this.borderRadius = 8,
    this.iconSize = 24,
    this.fallbackIcon = Icons.music_note,
  });

  final String? artworkUri;
  final double? size;
  final double borderRadius;
  final double iconSize;
  final IconData fallbackIcon;

  @override
  Widget build(BuildContext context) {
    Widget content;
    final uri = artworkUri;

    if (uri != null && uri.isNotEmpty) {
      if (!kIsWeb && File(uri).existsSync()) {
        content = Image.file(
          File(uri),
          width: size,
          height: size,
          fit: BoxFit.cover,
          errorBuilder: (_, __, ___) => _buildFallback(),
        );
      } else if (uri.startsWith('http://') || uri.startsWith('https://')) {
        content = Image.network(
          uri,
          width: size,
          height: size,
          fit: BoxFit.cover,
          errorBuilder: (_, __, ___) => _buildFallback(),
        );
      } else {
        content = _buildFallback();
      }
    } else {
      content = _buildFallback();
    }

    return ClipRRect(
      borderRadius: BorderRadius.circular(borderRadius),
      child: content,
    );
  }

  Widget _buildFallback() {
    return Container(
      width: size,
      height: size,
      decoration: const BoxDecoration(
        color: AppColors.surfaceCard,
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColors.surfaceCard,
            AppColors.surfaceHighlight,
          ],
        ),
      ),
      child: Center(
        child:
            Icon(fallbackIcon, size: iconSize, color: AppColors.textTertiary),
      ),
    );
  }
}
