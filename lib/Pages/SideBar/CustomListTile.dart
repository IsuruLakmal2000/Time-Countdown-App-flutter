import 'package:flutter/material.dart';
import 'package:timecountdown/Theme/AppColors.dart';

class CustomListTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final VoidCallback onTap;
  final bool isPremiumFeature;

  const CustomListTile({
    Key? key,
    required this.icon,
    required this.title,
    required this.onTap,
    this.isPremiumFeature = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final bool isBuyPremium = title == 'Buy Premium';

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      child: Material(
        color: Colors.transparent,
        borderRadius: AppRadius.mdAll,
        child: InkWell(
          onTap: onTap,
          borderRadius: AppRadius.mdAll,
          splashColor: AppColors.glass,
          highlightColor: AppColors.glass,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            decoration: BoxDecoration(
              borderRadius: AppRadius.mdAll,
              border: isBuyPremium
                  ? Border.all(
                      color: AppColors.accentPrimary.withOpacity(0.3), width: 1)
                  : null,
              gradient: isBuyPremium
                  ? LinearGradient(
                      colors: [
                        AppColors.accentPrimary.withOpacity(0.1),
                        AppColors.accentSecondary.withOpacity(0.05),
                      ],
                    )
                  : null,
            ),
            child: Row(
              children: [
                // Icon Container
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: isBuyPremium
                        ? AppColors.accentPrimary.withOpacity(0.2)
                        : AppColors.surfaceLight,
                    borderRadius: AppRadius.smAll,
                  ),
                  child: Icon(
                    icon,
                    color: isBuyPremium
                        ? AppColors.accentPrimary
                        : AppColors.textSecondary,
                    size: 22,
                  ),
                ),
                const SizedBox(width: 16),

                // Title
                Expanded(
                  child: Text(
                    title,
                    style: TextStyle(
                      color: isBuyPremium
                          ? AppColors.accentPrimary
                          : AppColors.textPrimary,
                      fontSize: 16,
                      fontWeight:
                          isBuyPremium ? FontWeight.w600 : FontWeight.w500,
                    ),
                  ),
                ),

                // Pro Badge
                if (isPremiumFeature) ...[
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      gradient: AppColors.accentGradient,
                      borderRadius: AppRadius.xsAll,
                    ),
                    child: const Text(
                      'PRO',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ),
                ],

                // Arrow for non-premium items
                if (!isPremiumFeature && !isBuyPremium)
                  Icon(
                    Icons.chevron_right_rounded,
                    color: AppColors.textTertiary,
                    size: 20,
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
