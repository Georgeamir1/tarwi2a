import 'dart:io';
import 'package:dartz/dartz.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../domain/failures/failure.dart';
import '../logger/app_logger.dart';

/// Service for uploading product images to Supabase Storage.
class ImageUploadService {
  final SupabaseClient _client = Supabase.instance.client;

  static const _bucket = 'product-images';

  /// Uploads a file to Supabase Storage and returns the public URL.
  Future<Either<Failure, String>> uploadImage(File file) async {
    try {
      final ext = file.path.split('.').last.toLowerCase();
      final fileName =
          '${DateTime.now().millisecondsSinceEpoch}_${file.hashCode}.$ext';
      final path = 'products/$fileName';

      await _client.storage.from(_bucket).upload(
            path,
            file,
            fileOptions: const FileOptions(
              cacheControl: '3600',
              upsert: false,
            ),
          );

      final publicUrl = _client.storage.from(_bucket).getPublicUrl(path);
      appLogger.d('Image uploaded: $publicUrl');
      return right(publicUrl);
    } catch (e, s) {
      appLogger.e('Image upload failed', error: e, stackTrace: s);
      return left(Failure.unexpected(message: 'فشل رفع الصورة: $e'));
    }
  }

  /// Deletes an image from Supabase Storage by its public URL.
  Future<void> deleteImage(String publicUrl) async {
    try {
      final uri = Uri.parse(publicUrl);
      final segments = uri.pathSegments;
      // URL format: .../storage/v1/object/public/product-images/products/filename.ext
      final bucketIndex = segments.indexOf(_bucket);
      if (bucketIndex >= 0 && bucketIndex + 1 < segments.length) {
        final path = segments.sublist(bucketIndex + 1).join('/');
        await _client.storage.from(_bucket).remove([path]);
        appLogger.d('Image deleted: $path');
      }
    } catch (e) {
      appLogger.w('Failed to delete image: $e');
    }
  }
}
