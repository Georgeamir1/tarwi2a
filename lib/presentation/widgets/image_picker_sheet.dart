import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../../app/theme/app_theme.dart';

/// Result from the image picker sheet.
class ImagePickerResult {
  /// The file picked from camera or gallery.
  final File? file;

  /// The URL entered manually.
  final String? url;

  const ImagePickerResult({this.file, this.url});

  bool get hasFile => file != null;
  bool get hasUrl => url != null && url!.isNotEmpty;
  bool get isEmpty => !hasFile && !hasUrl;
}

/// Bottom sheet offering Camera, Gallery, or URL input for images.
class ImagePickerSheet extends StatelessWidget {
  const ImagePickerSheet({super.key});

  static Future<ImagePickerResult?> show(BuildContext context) {
    return showModalBottomSheet<ImagePickerResult>(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (_) => const ImagePickerSheet(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.vertical(top: Radius.circular(AppRadius.xl)),
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Drag handle
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: AppColors.outlineVariant,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 16),

              Text(
                'إضافة صورة المنتج',
                style: AppTypography.headline.copyWith(
                  fontWeight: FontWeight.w700,
                  fontSize: 18,
                ),
              ),
              const SizedBox(height: 20),

              // Camera option
              _PickerOption(
                icon: Icons.camera_alt_rounded,
                label: 'التقاط صورة',
                subtitle: 'استخدم الكاميرا',
                color: const Color(0xFF3B82F6),
                onTap: () => _pickFromCamera(context),
              ),
              const SizedBox(height: 10),

              // Gallery option
              _PickerOption(
                icon: Icons.photo_library_rounded,
                label: 'اختيار من المعرض',
                subtitle: 'صورة من الجهاز',
                color: const Color(0xFF22C55E),
                onTap: () => _pickFromGallery(context),
              ),
              const SizedBox(height: 10),

              // URL option
              _PickerOption(
                icon: Icons.link_rounded,
                label: 'رابط صورة',
                subtitle: 'ادخل رابط URL',
                color: const Color(0xFF8B5CF6),
                onTap: () => _enterUrl(context),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _pickFromCamera(BuildContext context) async {
    final picker = ImagePicker();
    final xFile = await picker.pickImage(
      source: ImageSource.camera,
      maxWidth: 1200,
      maxHeight: 1200,
      imageQuality: 85,
    );
    if (xFile != null && context.mounted) {
      Navigator.pop(
        context,
        ImagePickerResult(file: File(xFile.path)),
      );
    }
  }

  Future<void> _pickFromGallery(BuildContext context) async {
    final picker = ImagePicker();
    final xFile = await picker.pickImage(
      source: ImageSource.gallery,
      maxWidth: 1200,
      maxHeight: 1200,
      imageQuality: 85,
    );
    if (xFile != null && context.mounted) {
      Navigator.pop(
        context,
        ImagePickerResult(file: File(xFile.path)),
      );
    }
  }

  void _enterUrl(BuildContext context) {
    final controller = TextEditingController();
    showDialog(
      context: context,
      builder: (dialogCtx) => AlertDialog(
        title: const Text('رابط الصورة'),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(
            hintText: 'https://...',
          ),
          textDirection: TextDirection.ltr,
          keyboardType: TextInputType.url,
          autofocus: true,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogCtx),
            child: const Text('إلغاء'),
          ),
          FilledButton(
            onPressed: () {
              final url = controller.text.trim();
              Navigator.pop(dialogCtx);
              if (url.isNotEmpty) {
                Navigator.pop(context, ImagePickerResult(url: url));
              }
            },
            child: const Text('تأكيد'),
          ),
        ],
      ),
    );
  }
}

class _PickerOption extends StatelessWidget {
  final IconData icon;
  final String label;
  final String subtitle;
  final Color color;
  final VoidCallback onTap;

  const _PickerOption({
    required this.icon,
    required this.label,
    required this.subtitle,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.06),
            borderRadius: BorderRadius.circular(AppRadius.lg),
            border: Border.all(color: color.withValues(alpha: 0.15)),
          ),
          child: Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(AppRadius.md),
                ),
                child: Icon(icon, color: color, size: 22),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      label,
                      style: AppTypography.callout.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Text(
                      subtitle,
                      style: AppTypography.footnote.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.chevron_right_rounded,
                color: AppColors.textMuted,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
