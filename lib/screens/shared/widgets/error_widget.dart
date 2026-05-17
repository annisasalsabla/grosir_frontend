import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../theme/app_colors.dart';
import 'custom_button.dart';

class ErrorDisplay extends StatelessWidget {
  final String message;
  final VoidCallback? onRetry;
  final bool showLogout;

  const ErrorDisplay({
    super.key,
    required this.message,
    this.onRetry,
    this.showLogout = false,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: AppColors.error.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.error_outline,
                size: 50,
                color: AppColors.error,
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              'Terjadi Kesalahan',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              message,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 14,
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: 24),
            if (onRetry != null)
              CustomButton(
                text: 'Coba Lagi',
                onPressed: onRetry!,
                icon: Icons.refresh,
                width: 200,
              ),
            if (showLogout)
              const SizedBox(height: 12),
            if (showLogout)
              CustomButton(
                text: 'Logout',
                onPressed: () {
                  Provider.of<AuthProvider>(context, listen: false).logout();
                },
                isOutlined: true,
                isDanger: true,
                width: 200,
              ),
          ],
        ),
      ),
    );
  }
}