import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';

class NewsScreen extends StatelessWidget {
  const NewsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final List<_NewsItem> newsItems = [
      _NewsItem(
        title: 'Market Update: 2024 Trends',
        message: 'The real estate market is expected to grow by 5% in 2024. Keep an eye on suburban areas for the best deals.',
        icon: Icons.trending_up,
        color: Colors.blue,
        gradient: LinearGradient(colors: [Colors.blue[700]!, Colors.blue[300]!]),
      ),
      _NewsItem(
        title: 'Tip: Diversify Your Portfolio',
        message: 'Investing in different property types (residential, commercial, land) can help reduce risk and maximize returns.',
        icon: Icons.lightbulb,
        color: Colors.amber,
        gradient: LinearGradient(colors: [Colors.amber[700]!, Colors.amber[300]!]),
      ),
      _NewsItem(
        title: 'News: New Tax Incentives',
        message: 'The government has introduced new tax incentives for first-time home buyers. Check eligibility before your next purchase.',
        icon: Icons.new_releases,
        color: Colors.green,
        gradient: LinearGradient(colors: [Colors.green[700]!, Colors.green[300]!]),
      ),
      _NewsItem(
        title: 'Tip: Location Matters',
        message: 'Properties near schools, parks, and public transport tend to appreciate faster and attract more tenants.',
        icon: Icons.location_on,
        color: Colors.purple,
        gradient: LinearGradient(colors: [Colors.purple[700]!, Colors.purple[300]!]),
      ),
      _NewsItem(
        title: 'Message: Stay Informed',
        message: 'Follow trusted real estate news sources and consult with professionals before making big investment decisions.',
        icon: Icons.info,
        color: Colors.red,
        gradient: LinearGradient(colors: [Colors.red[700]!, Colors.red[300]!]),
      ),
    ];

    return Scaffold(
      backgroundColor: AppTheme.backgroundSecondary,
      appBar: AppBar(
        title: Text('Real Estate News & Tips', style: AppTheme.headingMedium),
        backgroundColor: AppTheme.background,
        elevation: 0,
      ),
      body: ListView.separated(
        padding: const EdgeInsets.all(16),
        itemCount: newsItems.length,
        separatorBuilder: (_, __) => const SizedBox(height: 20),
        itemBuilder: (context, index) {
          final item = newsItems[index];
          return _ModernNewsCard(item: item, isLeft: index % 2 == 0);
        },
      ),
    );
  }
}

class _ModernNewsCard extends StatelessWidget {
  final _NewsItem item;
  final bool isLeft;
  const _ModernNewsCard({required this.item, required this.isLeft});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: item.gradient,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: item.color.withOpacity(0.18),
            blurRadius: 16,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (isLeft) ...[
              _Avatar(icon: item.icon, color: item.color),
              const SizedBox(width: 18),
            ],
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.title,
                    style: const TextStyle(
                      fontFamily: 'Montserrat',
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    item.message,
                    style: TextStyle(
                      fontFamily: 'Montserrat',
                      fontSize: 15,
                      color: Colors.white.withOpacity(0.95),
                    ),
                  ),
                ],
              ),
            ),
            if (!isLeft) ...[
              const SizedBox(width: 18),
              _Avatar(icon: item.icon, color: item.color),
            ],
          ],
        ),
      ),
    );
  }
}

class _Avatar extends StatelessWidget {
  final IconData icon;
  final Color color;
  const _Avatar({required this.icon, required this.color});

  @override
  Widget build(BuildContext context) {
    return CircleAvatar(
      radius: 28,
      backgroundColor: Colors.white,
      child: CircleAvatar(
        radius: 24,
        backgroundColor: color,
        child: Icon(icon, color: Colors.white, size: 28),
      ),
    );
  }
}

class _NewsItem {
  final String title;
  final String message;
  final IconData icon;
  final Color color;
  final Gradient gradient;
  const _NewsItem({
    required this.title,
    required this.message,
    required this.icon,
    required this.color,
    required this.gradient,
  });
} 