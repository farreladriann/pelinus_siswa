// lib/presentation/widgets/enhanced_card.dart
import 'package:flutter/material.dart';
import '../themes/app_colors.dart';

class EnhancedCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final VoidCallback? onTap;
  final Color? backgroundColor;
  final double? elevation;
  final BorderRadius? borderRadius;
  final List<BoxShadow>? customShadow;
  final bool isSelected;
  final Widget? trailing;

  const EnhancedCard({
    super.key,
    required this.child,
    this.padding,
    this.margin,
    this.onTap,
    this.backgroundColor,
    this.elevation,
    this.borderRadius,
    this.customShadow,
    this.isSelected = false,
    this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: margin ?? EdgeInsets.symmetric(vertical: AppSizes.xs),
      decoration: BoxDecoration(
        borderRadius: borderRadius ?? BorderRadius.circular(AppSizes.radiusMedium),
        boxShadow: customShadow ?? [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: AppSizes.elevationMedium,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        borderRadius: borderRadius ?? BorderRadius.circular(AppSizes.radiusMedium),
        color: backgroundColor ?? AppColors.card,
        elevation: elevation ?? 0,
        child: InkWell(
          onTap: onTap,
          borderRadius: borderRadius ?? BorderRadius.circular(AppSizes.radiusMedium),
          child: Container(
            padding: padding ?? EdgeInsets.all(AppSizes.md),
            decoration: isSelected ? BoxDecoration(
              borderRadius: borderRadius ?? BorderRadius.circular(AppSizes.radiusMedium),
              border: Border.all(color: AppColors.primary, width: 2),
            ) : null,
            child: Row(
              children: [
                Expanded(child: child),
                if (trailing != null) ...[
                  SizedBox(width: AppSizes.sm),
                  trailing!,
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class PelajaranCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final Widget? leading;
  final Widget? trailing;
  final VoidCallback? onTap;
  final Widget? progressWidget;
  final Color? accentColor;

  const PelajaranCard({
    super.key,
    required this.title,
    required this.subtitle,
    this.leading,
    this.trailing,
    this.onTap,
    this.progressWidget,
    this.accentColor,
  });

  @override
  Widget build(BuildContext context) {
    return EnhancedCard(
      onTap: onTap,
      margin: EdgeInsets.symmetric(
        horizontal: AppSizes.md, 
        vertical: AppSizes.xs,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              if (leading != null) ...[
                Container(
                  padding: EdgeInsets.all(AppSizes.sm),
                  decoration: BoxDecoration(
                    color: (accentColor ?? AppColors.primary).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(AppSizes.radiusSmall),
                  ),
                  child: leading!,
                ),
                SizedBox(width: AppSizes.md),
              ],
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    SizedBox(height: AppSizes.xs),
                    Text(
                      subtitle,
                      style: TextStyle(
                        fontSize: 14,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              if (trailing != null) trailing!,
            ],
          ),
          if (progressWidget != null) ...[
            SizedBox(height: AppSizes.md),
            progressWidget!,
          ],
        ],
      ),
    );
  }
}
