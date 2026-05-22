import 'package:flutter/material.dart';

class FuturexSubjectCard extends StatelessWidget {
  const FuturexSubjectCard({
    super.key,
    required this.title,
    this.subtitle,
    this.progress,
    this.imageUrl,
    this.leadingIcon,
    this.iconColor,
    this.onTap,
  });

  final String title;
  final String? subtitle;
  final double? progress;
  final String? imageUrl;
  final IconData? leadingIcon;
  final Color? iconColor;
  final VoidCallback? onTap;

  static IconData iconForSubject(String name) {
    final n = name.toLowerCase();
    if (n.contains('math')) return Icons.calculate;
    if (n.contains('english')) return Icons.menu_book;
    if (n.contains('physics')) return Icons.science;
    if (n.contains('chemistry')) return Icons.auto_awesome;
    if (n.contains('biology')) return Icons.eco;
    if (n.contains('geography')) return Icons.public;
    if (n.contains('history')) return Icons.history;
    return Icons.school;
  }

  static Color colorForSubject(String name) {
    final n = name.toLowerCase();
    if (n.contains('math')) return Colors.blue;
    if (n.contains('english')) return Colors.purple;
    if (n.contains('physics')) return Colors.green;
    if (n.contains('chemistry')) return Colors.orange;
    if (n.contains('biology')) return Colors.pink;
    if (n.contains('geography')) return Colors.teal;
    if (n.contains('history')) return Colors.brown;
    return Colors.blue;
  }

  @override
  Widget build(BuildContext context) {
    final ic = leadingIcon ?? iconForSubject(title);
    final col = iconColor ?? colorForSubject(title);

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            ClipRRect(
              borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
              child: imageUrl != null && imageUrl!.isNotEmpty
                  ? Image.network(
                      imageUrl!,
                      height: 120,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => _heroPlaceholder(ic, col),
                    )
                  : _heroPlaceholder(ic, col),
            ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Container(
                    width: 56,
                    height: 56,
                    decoration: BoxDecoration(
                      color: col.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(ic, color: col, size: 28),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          title,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF212121),
                          ),
                        ),
                        if (subtitle != null) ...[
                          const SizedBox(height: 4),
                          Text(
                            subtitle!,
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey.shade700,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                        if (progress != null) ...[
                          const SizedBox(height: 8),
                          ClipRRect(
                            borderRadius: BorderRadius.circular(4),
                            child: LinearProgressIndicator(
                              value: (progress!.clamp(0, 100)) / 100,
                              minHeight: 6,
                              backgroundColor: Colors.grey.shade200,
                              color: const Color(0xFF388E3C),
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '${progress!.toStringAsFixed(0)}% complete',
                            style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                          ),
                        ],
                      ],
                    ),
                  ),
                  Icon(Icons.chevron_right, color: Colors.grey.shade400),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _heroPlaceholder(IconData ic, Color col) {
    return Container(
      height: 120,
      color: col.withValues(alpha: 0.1),
      child: Icon(ic, color: col, size: 48),
    );
  }
}

class FuturexSimpleListCard extends StatelessWidget {
  const FuturexSimpleListCard({
    super.key,
    required this.title,
    this.subtitle,
    this.trailing,
    this.onTap,
  });

  final String title;
  final Widget? subtitle;
  final Widget? trailing;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF0D47A1),
                      ),
                    ),
                    if (subtitle != null) ...[
                      const SizedBox(height: 6),
                      subtitle!,
                    ],
                  ],
                ),
              ),
              trailing ?? Icon(Icons.chevron_right, color: Colors.grey.shade400),
            ],
          ),
        ),
      ),
    );
  }
}
