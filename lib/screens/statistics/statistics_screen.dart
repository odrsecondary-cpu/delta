import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';

class StatisticsScreen extends StatelessWidget {
  const StatisticsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: AppColors.background,
      body: Center(
        child: Text(
          'Statistics',
          style: TextStyle(color: AppColors.whiteMuted, fontSize: 16),
        ),
      ),
    );
  }
}
