import 'package:flutter/material.dart';
import '../../core/theme.dart';

class AnalyticsScreen extends StatelessWidget {
  const AnalyticsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0xFF10B981).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(Icons.show_chart, color: Color(0xFF10B981), size: 24),
              ),
              const SizedBox(width: 16),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Waste Trends', style: Theme.of(context).textTheme.headlineMedium),
                  Text('Weekly insights and metrics', style: Theme.of(context).textTheme.bodyMedium),
                ],
              ),
            ],
          ),
          const SizedBox(height: 40),
          
          Text('Volumetric Data (kg)', style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 16),
          
          Container(
            height: 300,
            padding: const EdgeInsets.fromLTRB(20, 32, 20, 20),
            decoration: BoxDecoration(
              color: AppTheme.surfaceColor.withOpacity(0.4),
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: Colors.white.withOpacity(0.05)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                _buildBar(context, 'M', 0.4),
                _buildBar(context, 'T', 0.6),
                _buildBar(context, 'W', 0.3),
                _buildBar(context, 'T', 0.8),
                _buildBar(context, 'F', 0.5),
                _buildBar(context, 'S', 0.7),
                _buildBar(context, 'S', 0.4),
              ],
            ),
          ),
          
          const SizedBox(height: 40),
          
          _buildInsightCard(
            context,
            'Efficiency Score',
            'Your network collection efficiency increased by 12% this week.',
            '84%',
            const Color(0xFF10B981),
          ),
          const SizedBox(height: 12),
          _buildInsightCard(
            context,
            'System Health',
            'All intelligent disposal units are active and reporting correctly.',
            'Optimum',
            AppTheme.primaryColor,
          ),
        ],
      ),
    );
  }

  Widget _buildInsightCard(BuildContext context, String title, String desc, String value, Color color) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppTheme.surfaceColor.withOpacity(0.3),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withOpacity(0.03)),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 16)),
                const SizedBox(height: 4),
                Text(desc, style: TextStyle(color: AppTheme.textSecondary, fontSize: 13, height: 1.4)),
              ],
            ),
          ),
          const SizedBox(width: 20),
          Text(value, style: TextStyle(color: color, fontWeight: FontWeight.w800, fontSize: 20)),
        ],
      ),
    );
  }

  Widget _buildBar(BuildContext context, String label, double heightRatio) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        Expanded(
          child: Container(
            width: 14,
            decoration: BoxDecoration(
              color: AppTheme.primaryColor.withOpacity(0.05),
              borderRadius: BorderRadius.circular(20),
            ),
            alignment: Alignment.bottomCenter,
            child: FractionallySizedBox(
              heightFactor: heightRatio,
              child: Container(
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [AppTheme.accentColor, AppTheme.primaryColor],
                  ),
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: AppTheme.primaryColor.withOpacity(0.3),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
        const SizedBox(height: 12),
        Text(label, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 12, color: AppTheme.textSecondary)),
      ],
    );
  }
}

