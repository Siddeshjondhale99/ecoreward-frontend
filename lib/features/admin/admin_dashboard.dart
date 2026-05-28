import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'admin_provider.dart';
import '../../shared/stat_card.dart';
import '../../core/theme.dart';
import 'dart:ui';

class AdminDashboard extends StatelessWidget {
  const AdminDashboard({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<AdminProvider>();
    final stats = provider.categoryStats;

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Core Analytics', style: Theme.of(context).textTheme.headlineMedium),
                  const SizedBox(height: 4),
                  Text('Resource Monitoring', style: Theme.of(context).textTheme.bodyMedium),
                ],
              ),
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: AppTheme.primaryColor.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.bar_chart, color: AppTheme.primaryColor, size: 20),
              ),
            ],
          ),
          const SizedBox(height: 32),
          
          // Primary Stats Row
          Row(
            children: [
              Expanded(
                child: StatCard(
                  title: 'Users',
                  value: '${provider.allUsers.length}',
                  icon: Icons.people_outline,
                  iconColor: AppTheme.primaryColor,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: StatCard(
                  title: 'Waste',
                  value: '${provider.totalWasteCollected.toStringAsFixed(1)}kg',
                  icon: Icons.delete_outline,
                  iconColor: const Color(0xFF10B981),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          StatCard(
            title: 'Credits in Circulation',
            value: '${provider.totalPointsAwarded}',
            icon: Icons.auto_awesome,
            iconColor: const Color(0xFFF59E0B),
          ),
          
          const SizedBox(height: 40),
          
          Text('Activity Distribution', style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 20),
          
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: AppTheme.surfaceColor.withOpacity(0.5),
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: Colors.white.withOpacity(0.05)),
            ),
            child: Column(
              children: [
                _buildStatRow('Plastic Material', stats['plastic'] ?? 0, const Color(0xFFF59E0B)),
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 12),
                  child: Divider(color: Colors.white10),
                ),
                _buildStatRow('Organic / Wet', stats['wet'] ?? 0, const Color(0xFF10B981)),
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 12),
                  child: Divider(color: Colors.white10),
                ),
                _buildStatRow('Dry Recyclables', stats['dry'] ?? 0, AppTheme.accentColor),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatRow(String title, double value, Color color) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            Container(
              width: 12,
              height: 12,
              decoration: BoxDecoration(
                color: color,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(color: color.withOpacity(0.4), blurRadius: 4),
                ],
              ),
            ),
            const SizedBox(width: 16),
            Text(title, style: const TextStyle(fontWeight: FontWeight.w500)),
          ],
        ),
        Text(
          '${value.toStringAsFixed(1)} kg', 
          style: const TextStyle(fontWeight: FontWeight.w700, fontFeatures: [FontFeature.tabularFigures()]),
        ),
      ],
    );
  }
}
