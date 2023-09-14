import 'package:recase/recase.dart';

/// The list of all assets in the bundle, along with their ids
class AssetMetadata {
  const AssetMetadata({
    required this.assets,
  });

  /// Gets the list of all assets in the bundle, along with their ids (required
  /// to access its data from the [AssetBundle]).
  final List<AssetIdentifier> assets;

  /// Gets the id of the asset with the given [name].
  int assetId(String name) {
    return assets.firstWhere((x) => x.name == name).id;
  }

  /// Generates a dart enum with all asset ids from the metadata.
  String toDart({String name = 'AssetIndex'}) {
    final result = StringBuffer();

    result.writeln('enum $name {');

    String escapeString(String value) {
      return value.replaceAll('\'', '\\\'').replaceAll('\n', '\\n');
    }

    for (var i = 0; i < assets.length; i++) {
      final asset = assets[i];
      final fieldName = ReCase(asset.name).camelCase;
      result.write('  $fieldName(');
      result.write('\'${escapeString(asset.name)}\'');
      result.write(',');
      result.write('${asset.id}');
      result.write(')');
      result.writeln(i >= assets.length - 1 ? ';' : ',');
    }
    result.writeln('  const $name(this.name,this.id);');
    result.writeln('  final String name;');
    result.writeln('  final int id;');
    result.writeln('}');

    return result.toString();
  }

  /// Generates a json index of the metadata.
  Map<String, int> toJson() {
    return {
      for (var asset in assets) asset.name: asset.id,
    };
  }
}

typedef AssetIdentifier = ({
  int id,
  String name,
});
