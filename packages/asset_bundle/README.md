# asset_bundle

Bundle multiple assets into one single file.

## Usage

### Create a bundle manually

```dart
  final bundle = MutableAssetBundle();
  bundle.addAsset('example/file1.png', Uint8List.fromList([1, 2, 3]));
  bundle.addAsset('other.svg', Uint8List.fromList([4, 5]));

  final binary = BinaryAssetBundle.fromBundle(bundle);
  final bytes = binaryBundle.asBytes();
```

### Create a bundle from multiple files

```dart
  final binary = await AssetBundle.fromFiles([
    File('example/file1.png'),
    File('other.svg'),
  ]);
  final bytes = binaryBundle.asBytes();
```


### Read a bundle

```dart
final bundle = AssetBundle.fromBytes(bytes);
final example1 = bundle.load(AssetIndex.e1.id);
final example2 = bundle.load(AssetIndex.e2.id);
final example3 = bundle.load(AssetIndex.e3.id);
```

### Use a generated index

```dart
/// First generate the code containing all the metadata and include the 
// generated code in your project.
print(bundle.toDart('AssetIndex'));
```

```dart
final bundle = AssetBundle.fromBytes(bytes);
final example1 = bundle.load(AssetIndex.e1.id);
final example2 = bundle.load(AssetIndex.e2.id);
```