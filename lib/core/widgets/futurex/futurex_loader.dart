import 'package:finalyearproject/core/constants/futurex_colors.dart';
import 'package:flutter/material.dart';

export 'futurex_states.dart';

class FutureXInlineLoader extends StatelessWidget {
  const FutureXInlineLoader({super.key, this.size = 48, this.message});

  final double size;
  final String? message;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox(
          width: size,
          height: size,
          child: const CircularProgressIndicator(
            strokeWidth: 3,
            color: FuturexColors.primary,
          ),
        ),
        if (message != null) ...[
          const SizedBox(height: 12),
          Text(
            message!,
            style: const TextStyle(color: FuturexColors.textSecondary, fontSize: 14),
          ),
        ],
      ],
    );
  }
}
