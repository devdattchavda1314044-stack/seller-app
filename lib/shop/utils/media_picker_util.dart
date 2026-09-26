import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:file_picker/file_picker.dart';
import '../../core/theme/app_colors.dart';

class MediaPickerUtil {
  static final ImagePicker _picker = ImagePicker();

  /// Shows a bottom sheet asking the user to choose 'Gallery' or 'Files'.
  /// Returns the selected file path, or null if cancelled/failed.
  static Future<String?> pickVideo(BuildContext context) async {
    final source = await _showSourcePickerSheet(context);
    if (source == null) return null;

    if (source == 'gallery') {
      try {
        final XFile? file = await _picker.pickVideo(source: ImageSource.gallery);
        if (file != null) {
          debugPrint('Picked gallery video path: ${file.path}');
          return file.path;
        }
      } catch (e) {
        debugPrint('Error picking video from gallery: $e');
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Could not access gallery video: $e')),
          );
        }
        return null;
      }
    } else if (source == 'files') {
      try {
        final List<PlatformFile> result = await FilePicker.pickFiles(
          type: FileType.video,
        );
        if (result.isNotEmpty) {
          final path = result.first.path;
          if (path != null && path.isNotEmpty) {
            debugPrint('Picked file manager video path: $path');
            return path;
          }
        }
      } catch (e) {
        debugPrint('Error picking video from files: $e');
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Could not access file video: $e')),
          );
        }
        return null;
      }
    }
    return null;
  }

  /// Shows a bottom sheet and picks multiple images.
  /// Returns a list of file paths.
  static Future<List<String>> pickImages(BuildContext context) async {
    final source = await _showSourcePickerSheet(context);
    if (source == null) return [];

    if (source == 'gallery') {
      try {
        final List<XFile> files = await _picker.pickMultiImage();
        if (files.isNotEmpty) {
          debugPrint('Picked ${files.length} gallery images.');
          return files.map((f) => f.path).toList();
        }
      } catch (e) {
        debugPrint('Error picking images from gallery: $e');
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Could not access gallery images: $e')),
          );
        }
      }
    } else if (source == 'files') {
      try {
        final List<PlatformFile> result = await FilePicker.pickFiles(
          type: FileType.image,
          allowMultiple: true,
        );
        if (result.isNotEmpty) {
          debugPrint('Picked ${result.length} file images.');
          return result
              .map((f) => f.path)
              .where((p) => p != null && p.isNotEmpty)
              .cast<String>()
              .toList();
        }
      } catch (e) {
        debugPrint('Error picking images from files: $e');
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Could not access file images: $e')),
          );
        }
      }
    }
    return [];
  }

  static Future<String?> _showSourcePickerSheet(BuildContext context) async {
    return showModalBottomSheet<String>(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        return Container(
          padding: const EdgeInsets.all(24),
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: const Color(0xFFE5E7EB),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 24),
              const Text(
                'Select Media Source',
                style: TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: AppColors.primaryText,
                ),
              ),
              const SizedBox(height: 16),
              _SourceTile(
                icon: Icons.photo_library_outlined,
                title: 'Gallery',
                subtitle: 'Choose from your device photos and videos',
                onTap: () => Navigator.pop(ctx, 'gallery'),
              ),
              const SizedBox(height: 12),
              _SourceTile(
                icon: Icons.folder_open_outlined,
                title: 'Files',
                subtitle: 'Browse files and folders on your device',
                onTap: () => Navigator.pop(ctx, 'files'),
              ),
              const SizedBox(height: 24),
            ],
          ),
        );
      },
    );
  }
}

class _SourceTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  const _SourceTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          border: Border.all(color: const Color(0xFFE5E7EB)),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: AppColors.primary, size: 24),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: AppColors.primaryText,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: const TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 13,
                      color: Color(0xFF6B7280),
                    ),
                  ),
                ],
              ),
            ),
            const Icon(Icons.chevron_right, color: Color(0xFF9CA3AF)),
          ],
        ),
      ),
    );
  }
}
