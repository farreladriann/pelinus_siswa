// lib/presentation/widgets/enhanced_progress_indicator.dart
import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_dimensions.dart';
import '../../domain/entities/quiz_result.dart';

class CircularProgressCard extends StatefulWidget {
  final PelajaranProgress? progress;
  final double size;
  final double strokeWidth;
  final bool showLabel;
  final Color? primaryColor;

  const CircularProgressCard({
    super.key,
    this.progress,
    this.size = 80.0,
    this.strokeWidth = 6.0,
    this.showLabel = true,
    this.primaryColor,
  });

  @override
  State<CircularProgressCard> createState() => _CircularProgressCardState();
}

class _CircularProgressCardState extends State<CircularProgressCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: Duration(milliseconds: 1500),
      vsync: this,
    );
    _animation = Tween<double>(
      begin: 0.0,
      end: widget.progress?.totalKuis != null && widget.progress!.totalKuis > 0
          ? widget.progress!.completedKuis / widget.progress!.totalKuis
          : 0.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.progress == null) {
      return SizedBox(
        width: widget.size,
        height: widget.size,
      );
    }

    final progress = widget.progress!;
    final progressColor = widget.primaryColor ??
        (progress.isCompleted
            ? AppColors.success
            : progress.completedKuis > 0
                ? AppColors.warning
                : AppColors.textHint);

    return SizedBox(
      width: widget.size,
      height: widget.size,
      child: Stack(
        children: [
          // Background circle
          Container(
            width: widget.size,
            height: widget.size,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: progressColor.withOpacity(0.1),
            ),
          ),
          // Progress circle
          AnimatedBuilder(
            animation: _animation,
            builder: (context, child) {
              return SizedBox(
                width: widget.size,
                height: widget.size,
                child: CircularProgressIndicator(
                  value: _animation.value,
                  strokeWidth: widget.strokeWidth,
                  backgroundColor: progressColor.withOpacity(0.2),
                  valueColor: AlwaysStoppedAnimation<Color>(progressColor),
                ),
              );
            },
          ),
          // Center content
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (progress.isCompleted)
                  Icon(
                    Icons.check_circle,
                    color: progressColor,
                    size: widget.size * 0.3,
                  )
                else
                  Text(
                    '${progress.completedKuis}',
                    style: TextStyle(
                      fontSize: widget.size * 0.25,
                      fontWeight: FontWeight.bold,
                      color: progressColor,
                    ),
                  ),
                if (widget.showLabel && !progress.isCompleted)
                  Text(
                    '/${progress.totalKuis}',
                    style: TextStyle(
                      fontSize: widget.size * 0.15,
                      color: AppColors.textSecondary,
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

class LinearProgressCard extends StatefulWidget {
  final PelajaranProgress? progress;
  final double height;
  final bool showLabel;
  final bool showPercentage;
  final Color? primaryColor;

  const LinearProgressCard({
    super.key,
    this.progress,
    this.height = 8.0,
    this.showLabel = true,
    this.showPercentage = true,
    this.primaryColor,
  });

  @override
  State<LinearProgressCard> createState() => _LinearProgressCardState();
}

class _LinearProgressCardState extends State<LinearProgressCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: Duration(milliseconds: 1200),
      vsync: this,
    );
    _animation = Tween<double>(
      begin: 0.0,
      end: widget.progress?.totalKuis != null && widget.progress!.totalKuis > 0
          ? widget.progress!.completedKuis / widget.progress!.totalKuis
          : 0.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.progress == null) {
      return SizedBox.shrink();
    }

    final progress = widget.progress!;
    final progressColor = widget.primaryColor ??
        (progress.isCompleted
            ? AppColors.success
            : progress.completedKuis > 0
                ? AppColors.warning
                : AppColors.textHint);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        if (widget.showLabel) ...[
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Progress Kuis',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: AppColors.textSecondary,
                ),
              ),
              Row(
                children: [
                  Text(
                    '${progress.completedKuis}/${progress.totalKuis}',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: progressColor,
                    ),
                  ),
                  if (widget.showPercentage) ...[
                    SizedBox(width: AppDimensions.spacing8),
                    Text(
                      '${(progress.totalKuis > 0 ? (progress.completedKuis / progress.totalKuis * 100) : 0).toStringAsFixed(0)}%',
                      style: TextStyle(
                        fontSize: 11,
                        color: AppColors.textHint,
                      ),
                    ),
                  ],
                ],
              ),
            ],
          ),
          SizedBox(height: AppDimensions.spacing8),
        ],
        Container(
          height: widget.height,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(widget.height / 2),
            color: progressColor.withOpacity(0.2),
          ),
          child: AnimatedBuilder(
            animation: _animation,
            builder: (context, child) {
              return LinearProgressIndicator(
                value: _animation.value,
                backgroundColor: Colors.transparent,
                valueColor: AlwaysStoppedAnimation<Color>(progressColor),
                borderRadius: BorderRadius.circular(widget.height / 2),
              );
            },
          ),
        ),
        if (progress.completedKuis > 0 && widget.showLabel) ...[
          SizedBox(height: AppDimensions.spacing4),
          Text(
            'Skor: ${progress.score.toStringAsFixed(1)}%',
            style: TextStyle(
              fontSize: 11,
              color: progressColor,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ],
    );
  }
}
