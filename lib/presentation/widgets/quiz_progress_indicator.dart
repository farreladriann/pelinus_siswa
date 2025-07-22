// lib/presentation/widgets/quiz_progress_indicator.dart
import 'package:flutter/material.dart';
import '../../domain/entities/quiz_result.dart';

class QuizProgressIndicator extends StatelessWidget {
  final PelajaranProgress? progress;
  final bool showLabel;
  final bool showScore;
  final double? height;

  const QuizProgressIndicator({
    super.key,
    this.progress,
    this.showLabel = true,
    this.showScore = true,
    this.height,
  });

  @override
  Widget build(BuildContext context) {
    if (progress == null) {
      return SizedBox.shrink();
    }

    final progressValue = progress!.totalKuis > 0 
        ? progress!.completedKuis / progress!.totalKuis 
        : 0.0;
    
    final progressColor = progress!.isCompleted 
        ? Colors.green 
        : progress!.completedKuis > 0 
            ? Colors.orange 
            : Colors.grey;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        if (showLabel) ...[
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Progress Kuis',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: Colors.grey.shade700,
                ),
              ),
              Text(
                '${progress!.completedKuis}/${progress!.totalKuis}',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: progressColor,
                ),
              ),
            ],
          ),
          SizedBox(height: 4),
        ],
        
        LinearProgressIndicator(
          value: progressValue,
          backgroundColor: Colors.grey.shade300,
          valueColor: AlwaysStoppedAnimation<Color>(progressColor),
          minHeight: height ?? 4,
        ),
        
        if (showScore && progress!.completedKuis > 0) ...[
          SizedBox(height: 4),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Skor: ${progress!.score.toStringAsFixed(1)}%',
                style: TextStyle(
                  fontSize: 11,
                  color: progressColor,
                  fontWeight: FontWeight.w500,
                ),
              ),
              if (progress!.isCompleted)
                Row(
                  children: [
                    Icon(
                      Icons.check_circle,
                      color: Colors.green,
                      size: 14,
                    ),
                    SizedBox(width: 2),
                    Text(
                      'Selesai',
                      style: TextStyle(
                        fontSize: 11,
                        color: Colors.green,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
            ],
          ),
        ],
      ],
    );
  }
}

class QuizProgressCard extends StatelessWidget {
  final PelajaranProgress progress;
  final String pelajaranName;
  final VoidCallback? onTap;
  final VoidCallback? onReset;

  const QuizProgressCard({
    super.key,
    required this.progress,
    required this.pelajaranName,
    this.onTap,
    this.onReset,
  });

  @override
  Widget build(BuildContext context) {
    final progressValue = progress.totalKuis > 0 
        ? progress.completedKuis / progress.totalKuis 
        : 0.0;
    
    final progressColor = progress.isCompleted 
        ? Colors.green 
        : progress.completedKuis > 0 
            ? Colors.orange 
            : Colors.grey;

    return Card(
      margin: EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      pelajaranName,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                      overflow: TextOverflow.ellipsis,
                      maxLines: 2,
                    ),
                  ),
                  if (progress.isCompleted)
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.green.shade100,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.check_circle, color: Colors.green, size: 16),
                          SizedBox(width: 4),
                          Text(
                            'Selesai',
                            style: TextStyle(
                              color: Colors.green.shade800,
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                ],
              ),
              SizedBox(height: 12),
              
              LinearProgressIndicator(
                value: progressValue,
                backgroundColor: Colors.grey.shade300,
                valueColor: AlwaysStoppedAnimation<Color>(progressColor),
                minHeight: 6,
              ),
              SizedBox(height: 8),
              
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Kuis: ${progress.completedKuis}/${progress.totalKuis}',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey.shade600,
                        ),
                      ),
                      if (progress.completedKuis > 0)
                        Text(
                          'Benar: ${progress.correctAnswers}/${progress.completedKuis}',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey.shade600,
                          ),
                        ),
                    ],
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        'Skor: ${progress.score.toStringAsFixed(1)}%',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: progressColor,
                        ),
                      ),
                      if (progress.lastAttemptAt != null)
                        Text(
                          _formatDateTime(progress.lastAttemptAt!),
                          style: TextStyle(
                            fontSize: 10,
                            color: Colors.grey.shade500,
                          ),
                        ),
                    ],
                  ),
                ],
              ),
              
              if (progress.completedKuis > 0) ...[
                SizedBox(height: 12),
                Row(
                  children: [
                    if (onReset != null)
                      TextButton.icon(
                        onPressed: onReset,
                        icon: Icon(Icons.refresh, size: 16, color: Colors.orange),
                        label: Text(
                          'Reset',
                          style: TextStyle(color: Colors.orange),
                        ),
                        style: TextButton.styleFrom(
                          padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          minimumSize: Size(0, 0),
                        ),
                      ),
                    Spacer(),
                    ElevatedButton.icon(
                      onPressed: onTap,
                      icon: Icon(Icons.quiz, size: 16),
                      label: Text(
                        progress.isCompleted ? 'Review' : 'Lanjutkan',
                        style: TextStyle(fontSize: 12),
                      ),
                      style: ElevatedButton.styleFrom(
                        padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        minimumSize: Size(0, 0),
                      ),
                    ),
                  ],
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  String _formatDateTime(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);
    
    if (difference.inDays > 0) {
      return '${difference.inDays} hari lalu';
    } else if (difference.inHours > 0) {
      return '${difference.inHours} jam lalu';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes} menit lalu';
    } else {
      return 'Baru saja';
    }
  }
}
