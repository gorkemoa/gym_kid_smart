import 'package:flutter/material.dart';
import '../../../core/responsive/size_tokens.dart';
import '../../../models/calendar_detail_model.dart';

class GalleryGridItem extends StatelessWidget {
  final GalleryItem item;
  final VoidCallback onTap;
  final VoidCallback? onDelete;
  final bool isAuthorized;

  const GalleryGridItem({
    super.key,
    required this.item,
    required this.onTap,
    this.onDelete,
    this.isAuthorized = false,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(SizeTokens.r12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(SizeTokens.r12),
          child: Stack(
            fit: StackFit.expand,
            children: [
              Image.network(
                item.image ?? "",
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) => Container(
                  color: Colors.grey[200],
                  child: const Icon(Icons.broken_image, color: Colors.grey),
                ),
              ),
              if (isAuthorized && onDelete != null)
                Positioned(
                  top: SizeTokens.p4,
                  right: SizeTokens.p4,
                  child: GestureDetector(
                    onTap: onDelete,
                    child: Container(
                      padding: EdgeInsets.all(SizeTokens.p4),
                      decoration: const BoxDecoration(
                        color: Colors.black54,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.close,
                        color: Colors.white,
                        size: SizeTokens.i16,
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
