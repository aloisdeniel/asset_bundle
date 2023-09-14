import 'dart:typed_data';

import 'package:asset_bundle/asset_bundle.dart';

void main() {
  final bundle = MutableAssetBundle();
  bundle.addAsset('e1', Uint8List.fromList([1, 2, 3]));
  bundle.addAsset('e2', Uint8List.fromList([4, 5]));
  bundle.addAsset('e3', Uint8List.fromList([6]));
  var id1 = bundle.metadata.assetId('e1');
  var id2 = bundle.metadata.assetId('e2');
  var id3 = bundle.metadata.assetId('e3');

  print('');
  print('Mutable ids:');
  print('1 : $id1');
  print('2 : $id2');
  print('3 : $id3');

  final binaryBundle = BinaryAssetBundle.fromBundle(bundle);
  id1 = binaryBundle.metadata.assetId('e1');
  id2 = binaryBundle.metadata.assetId('e2');
  id3 = binaryBundle.metadata.assetId('e3');
  print('');
  print('Binary ids:');
  print('1 : $id1');
  print('2 : $id2');
  print('3 : $id3');

  final bytes = binaryBundle.asBytes();

  final deserialized = AssetBundle.fromBytes(bytes);

  final example1 = deserialized.load(AssetIndex.e1.id);
  final example2 = deserialized.load(AssetIndex.e2.id);
  final example3 = deserialized.load(AssetIndex.e3.id);
  print('');
  print('Data:');
  print(example1);
  print(example2);
  print(example3);

  print('');
  print('Dart:');
  print(deserialized.metadata.toDart());

  print('');
  print('Json:');
  print(deserialized.metadata.toJson());
}

enum AssetIndex {
  e1('e1', 0),
  e2('e2', 11),
  e3('e3', 21);

  const AssetIndex(this.name, this.id);
  final String name;
  final int id;
}
