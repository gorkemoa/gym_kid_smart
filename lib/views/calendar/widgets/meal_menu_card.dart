import 'package:flutter/material.dart';
import '../../../core/responsive/size_tokens.dart';
import '../../../models/meal_menu_model.dart';
import '../../../core/utils/time_utils.dart';

class MealMenuCard extends StatelessWidget {
  final MealMenuModel meal;
  final bool isAuthorized;
  final VoidCallback onDelete;
  final String locale;

  const MealMenuCard({
    super.key,
    required this.meal,
    required this.isAuthorized,
    required this.onDelete,
    required this.locale,
  });

  @override
  Widget build(BuildContext context) {
    final primaryColor = Theme.of(context).primaryColor;

    return Container(
      margin: EdgeInsets.only(bottom: SizeTokens.p16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(SizeTokens.r16),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: EdgeInsets.all(SizeTokens.p12),
            decoration: BoxDecoration(
              color: primaryColor.withOpacity(0.05),
              borderRadius: BorderRadius.vertical(
                top: Radius.circular(SizeTokens.r16),
              ),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.restaurant_rounded,
                  color: primaryColor,
                  size: SizeTokens.i20,
                ),
                SizedBox(width: SizeTokens.p12),
                Expanded(
                  child: Text(
                    meal.title ?? "",
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: SizeTokens.f16,
                      color: primaryColor,
                    ),
                  ),
                ),
                if (meal.time != null)
                  Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: SizeTokens.p8,
                      vertical: SizeTokens.p4,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(SizeTokens.r8),
                    ),
                    child: Text(
                      TimeUtils.formatTime(meal.time),
                      style: TextStyle(
                        color: Colors.grey[700],
                        fontSize: SizeTokens.f12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                if (isAuthorized) ...[
                  SizedBox(width: SizeTokens.p8),
                  IconButton(
                    icon: Icon(
                      Icons.delete_outline_rounded,
                      color: Colors.red[400],
                      size: SizeTokens.i20,
                    ),
                    onPressed: onDelete,
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                  ),
                ],
              ],
            ),
          ),
          Padding(
            padding: EdgeInsets.all(SizeTokens.p16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  meal.menu ?? "",
                  style: TextStyle(
                    color: Colors.grey[800],
                    fontSize: SizeTokens.f14,
                    height: 1.5,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
