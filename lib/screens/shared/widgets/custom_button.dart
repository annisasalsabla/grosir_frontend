import 'package:flutter/material.dart';
import 'package:grosir_tiga_bersaudara/theme/app_colors.dart';


class CustomButton extends StatelessWidget {
  final String text;
  final VoidCallback onPressed;
  final bool isLoading;
  final bool isOutlined;
  final bool isDanger;
  final IconData? icon;
  final Color? backgroundColor;
  final double? width;
  final double? height;

  const CustomButton({
    super.key,
    required this.text,
    required this.onPressed,
    this.isLoading = false,
    this.isOutlined = false,
    this.isDanger = false,
    this.icon,
    this.backgroundColor,
    this.width,
    this.height,
  });

  @override
  Widget build(BuildContext context) {
    final buttonStyle = isOutlined
        ? OutlinedButton.styleFrom(
      foregroundColor: isDanger ? AppColors.error : AppColors.primary,
      side: BorderSide(
        color: isDanger ? AppColors.error : AppColors.primary,
        width: 1.5,
      ),
      minimumSize: Size(width ?? double.infinity, height ?? 48),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
    )
        : ElevatedButton.styleFrom(
      backgroundColor: backgroundColor ??
          (isDanger ? AppColors.error : AppColors.primary),
      foregroundColor: Colors.white,
      minimumSize: Size(width ?? double.infinity, height ?? 48),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
    );

    final child = isLoading
        ? const SizedBox(
      width: 20,
      height: 20,
      child: CircularProgressIndicator(
        strokeWidth: 2,
        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
      ),
    )
        : (icon != null
        ? Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(icon, size: 20),
        const SizedBox(width: 8),
        Text(text),
      ],
    )
        : Text(text));

    return SizedBox(
      width: width ?? double.infinity,
      height: height ?? 48,
      child: isOutlined
          ? OutlinedButton(onPressed: isLoading ? null : onPressed, child: child)
          : ElevatedButton(onPressed: isLoading ? null : onPressed, child: child),
    );
  }
}