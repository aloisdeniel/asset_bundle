import 'dart:io';
import 'dart:typed_data';

import 'package:asset_bundle/src/metadata.dart';
import 'binary_bundle.dart';

/// A bindle containing various binary assets.
abstract class AssetBundle {
  /// Creates an empty bundle.
  const AssetBundle();

  /// Load the binary bundle from the given [bytes].
  factory AssetBundle.fromBytes(Uint8List bytes) = BinaryAssetBundle.fromBytes;

  /// Bundle all the given [files] into a single binary bundle.
  static Future<AssetBundle> fromFiles(List<File> files) {
    return BinaryAssetBundle.fromFiles(files);
  }

  /// Gets the list of all assets in the bundle, along with their ids.
  AssetMetadata get metadata;

  /// Loads the data of the asset with the given [assetId].
  Uint8List load(int assetId);
}
