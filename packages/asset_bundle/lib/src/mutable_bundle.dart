import 'dart:typed_data';

import '../asset_bundle.dart';

class MutableAssetBundle extends AssetBundle {
  MutableAssetBundle();

  final List<Asset> _assets = [];

  void addAsset(String name, Uint8List data) {
    _assets.add((
      name: name,
      id: _assets.length,
      data: data,
    ));
  }

  @override
  AssetMetadata get metadata {
    return AssetMetadata(
      assets: [
        for (var asset in _assets) (id: asset.id, name: asset.name),
      ],
    );
  }

  @override
  Uint8List load(int assetId) {
    return _assets.firstWhere((x) => x.id == assetId).data;
  }
}

typedef Asset = ({
  String name,
  int id,
  Uint8List data,
});
