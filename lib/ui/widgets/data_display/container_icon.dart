import 'package:flutter/material.dart';

import 'package:flutter_unraid/config/theme.dart';

/// Displays a container icon from a URL with a fallback to a generic icon.
///
/// Used in both the Docker tab list tiles and the container detail screen.
class ContainerIcon extends StatelessWidget {
  final String? iconUrl;
  final double size;
  final double iconSize;
  final double borderRadius;

  const ContainerIcon({
    super.key,
    this.iconUrl,
    this.size = 32,
    this.iconSize = 18,
    this.borderRadius = 8,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(borderRadius),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(borderRadius),
        child: iconUrl != null
            ? Image.network(
                iconUrl!,
                width: size,
                height: size,
                fit: BoxFit.cover,
                errorBuilder: (_, _, _) => Icon(
                  Icons.inventory_2,
                  color: AppColors.unraidOrange,
                  size: iconSize,
                ),
              )
            : Icon(
                Icons.inventory_2,
                color: AppColors.unraidOrange,
                size: iconSize,
              ),
      ),
    );
  }
}
