import 'package:image_picker/image_picker.dart';

/// Bucket names — kept as constants so call sites don't drift.
abstract final class ImageBuckets {
  static const avatars = 'avatars';
  static const sources = 'sources';
  static const cars = 'cars';
  static const pets = 'pets';
}

/// Result of a pick+upload operation. Either holds a URL string (remote)
/// or a local file path (mock mode), or null if user cancelled / failed.
class ImageUploadResult {
  /// Remote URL or local file path (depending on backend).
  final String url;
  final bool isLocal;

  const ImageUploadResult({required this.url, this.isLocal = false});
}

/// Abstract image upload pipeline. Two impls:
///  - [MockImageUploadService] — current default. Returns local file paths.
///  - [SupabaseImageUploadService] — scaffolded, dormant. Wire when going live.
abstract class ImageUploadService {
  /// Picks an image from [source] and "uploads" it to [bucket]/[path].
  /// Returns null if the user cancelled or an error occurred.
  Future<ImageUploadResult?> pickAndUpload({
    required String bucket,
    required String path,
    ImageSource source = ImageSource.gallery,
  });

  /// Removes a previously uploaded image (no-op in mock).
  Future<void> remove({required String bucket, required String path});
}

class MockImageUploadService implements ImageUploadService {
  final ImagePicker _picker = ImagePicker();

  @override
  Future<ImageUploadResult?> pickAndUpload({
    required String bucket,
    required String path,
    ImageSource source = ImageSource.gallery,
  }) async {
    final picked = await _picker.pickImage(
      source: source,
      maxWidth: 1024,
      maxHeight: 1024,
      imageQuality: 85,
    );
    if (picked == null) return null;
    // Mock mode: return the local file path. CachedNetworkImage falls back
    // to a regular Image.file for non-http paths via wrapper widgets.
    return ImageUploadResult(url: picked.path, isLocal: true);
  }

  @override
  Future<void> remove({required String bucket, required String path}) async {
    // No-op in mock mode.
  }
}

/// Scaffolded real impl. NOT wired in dependencies yet — flip when going live.
/// Requires Supabase storage buckets `avatars`, `sources`, `cars`, `pets`
/// with RLS allowing authenticated upsert and public read.
class SupabaseImageUploadService implements ImageUploadService {
  final ImagePicker _picker = ImagePicker();

  @override
  Future<ImageUploadResult?> pickAndUpload({
    required String bucket,
    required String path,
    ImageSource source = ImageSource.gallery,
  }) async {
    final picked = await _picker.pickImage(
      source: source,
      maxWidth: 1024,
      maxHeight: 1024,
      imageQuality: 85,
    );
    if (picked == null) return null;
    // TODO(supabase): real upload
    // final bytes = await picked.readAsBytes();
    // await Supabase.instance.client.storage.from(bucket).uploadBinary(
    //   path, bytes,
    //   fileOptions: const FileOptions(upsert: true, contentType: 'image/jpeg'),
    // );
    // final url =
    //     Supabase.instance.client.storage.from(bucket).getPublicUrl(path);
    // return ImageUploadResult(url: url, isLocal: false);
    throw UnimplementedError(
      'SupabaseImageUploadService not wired — using MockImageUploadService.',
    );
  }

  @override
  Future<void> remove({required String bucket, required String path}) async {
    // TODO(supabase): real delete
    // await Supabase.instance.client.storage.from(bucket).remove([path]);
    throw UnimplementedError();
  }
}
