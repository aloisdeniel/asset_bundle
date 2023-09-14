import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:asset_bundle/src/bundle.dart';
import 'package:asset_bundle/src/metadata.dart';
import 'package:asset_bundle/src/mutable_bundle.dart';

class BinaryAssetBundle extends AssetBundle {
  BinaryAssetBundle(this._data);

  /// Load the bundle from the given [bytes].
  factory BinaryAssetBundle.fromBytes(Uint8List bytes) {
    return BinaryAssetBundle(ByteData.sublistView(bytes));
  }

  /// Converts the given [bundle] to a [BinaryAssetBundle].
  factory BinaryAssetBundle.fromBundle(AssetBundle bundle) {
    final assets = <Asset>[];

    var offset = 0;
    for (var asset in bundle.metadata.assets) {
      final bytes = bundle.load(asset.id);
      assets.add((id: offset, name: asset.name, data: bytes));
      offset += 8; // Size at the beginning
      offset += bytes.lengthInBytes; // Data
    }

    return BinaryAssetBundle._fromAssets(assets);
  }

  /// Bundle all the given [files] into a single binary bundle.
  static Future<BinaryAssetBundle> fromFiles(List<File> files) async {
    final assets = <Asset>[];

    var offset = 0;
    for (var file in files) {
      final bytes = await file.readAsBytes();
      offset += bytes.lengthInBytes;
      assets.add(
        (
          id: offset,
          name: file.path,
          data: bytes,
        ),
      );
    }

    return BinaryAssetBundle._fromAssets(assets);
  }

  /// Writes all the the given [assets] to a single binary bundle.
  factory BinaryAssetBundle._fromAssets(List<Asset> assets) {
    final metadata = <ByteData>[];

    var totalMetadataSize = 0;
    var totalDataSize = 0;

    // Metadata
    for (var asset in assets) {
      // Id
      final id = ByteData(8);
      id.setInt64(0, asset.id);
      metadata.add(id);
      totalMetadataSize += 8;

      const utf8Encoder = Utf8Encoder();
      final nameBytes = utf8Encoder.convert(asset.name);

      // Name character count
      final characterCount = ByteData(4);
      characterCount.setInt32(0, nameBytes.lengthInBytes);
      metadata.add(characterCount);
      totalMetadataSize += 4;

      // Name character data
      metadata.add(ByteData.sublistView(nameBytes));
      totalMetadataSize += nameBytes.lengthInBytes;
      totalDataSize += 8; // Size at the beginning
      totalDataSize += asset.data.lengthInBytes; // Data
    }

    // Asset count
    final assetCountData = ByteData(8);
    totalMetadataSize += 8;
    assetCountData.setInt64(0, assets.length);
    metadata.insert(0, assetCountData);

    // Total metadata size
    final totalMetadataSizeData = ByteData(8);
    totalMetadataSize += 8;
    totalMetadataSizeData.setInt64(0, totalMetadataSize);
    metadata.insert(0, totalMetadataSizeData);

    // Appending everything
    var offset = 0;
    final data = Uint8List(totalMetadataSize + totalDataSize);
    for (var item in metadata) {
      final end = offset + item.lengthInBytes;
      data.setRange(
        offset,
        end,
        item.buffer.asUint8List(0, item.lengthInBytes),
      );
      offset = end;
    }

    for (var asset in assets) {
      final assetLengthData = ByteData(8);
      assetLengthData.setInt64(0, asset.data.lengthInBytes);
      data.setRange(
        offset,
        offset + 8,
        assetLengthData.buffer.asUint8List(0, assetLengthData.lengthInBytes),
      );
      offset += 8;

      final end = offset + asset.data.lengthInBytes;
      data.setRange(
        offset,
        end,
        asset.data.buffer.asUint8List(0, asset.data.lengthInBytes),
      );
      offset = end;
    }

    return BinaryAssetBundle(ByteData.sublistView(data));
  }

  /// Size of the bundle in bytes.
  int get size => _data.lengthInBytes;

  final ByteData _data;

  /// Get the bytes of the bundle.
  ///
  /// If [skipMetadata], then the metadata is kept empty at the beginning of the
  /// data, but the data is still accessible through [load] if the [identifiers]
  /// are known.
  Uint8List asBytes({bool skipMetadata = false}) {
    if (!skipMetadata) {
      return _data.buffer.asUint8List(0, _data.lengthInBytes);
    }

    // We indicate a metadata size of `0`.
    final data = _data.buffer.asUint8List(
      _startOffset,
      _data.lengthInBytes - _startOffset,
    );
    final result = Uint8List(data.lengthInBytes + 8);
    final totalSizeData = ByteData(8);
    totalSizeData.setInt64(0, 0);
    result.addAll(totalSizeData.buffer.asUint8List());
    result.addAll(data);
    return result;
  }

  @override
  Uint8List load(int assetId) {
    var offset = _startOffset + assetId;
    final size = _data.getInt64(offset);
    offset += 8;
    return Uint8List.sublistView(_data, offset, offset + size);
  }

  late final int _startOffset = () {
    final metadataSize = _data.getInt64(0);
    return metadataSize;
  }();

  @override
  late final AssetMetadata metadata = () {
    // If metadata isn't available in bundle we return an empty list.
    if (_startOffset == 0) {
      return const AssetMetadata(assets: []);
    }
    final identifiers = <AssetIdentifier>[];
    var offset = 8; // skip size
    final assetCount = _data.getInt64(offset);
    offset += 8;
    for (var i = 0; i < assetCount; i++) {
      final id = _data.getInt64(offset);
      offset += 8;
      final nameSize = _data.getInt32(offset);
      offset += 4;
      final characters = _data.buffer.asUint8List(
        offset,
        nameSize,
      );
      offset += nameSize;
      const utf8Decoder = Utf8Decoder(allowMalformed: true);
      final name = utf8Decoder.convert(characters);
      identifiers.add((id: id, name: name));
    }
    return AssetMetadata(
      assets: identifiers,
    );
  }();
}
