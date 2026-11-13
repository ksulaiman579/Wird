// Finds a downloaded ayah MP3 on disk (native only). On web there are no
// downloads, so the lookup always returns null.
export 'local_ayah_file_io.dart'
    if (dart.library.js_interop) 'local_ayah_file_web.dart';
