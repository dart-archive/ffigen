import 'package:ffigen/src/config_provider/config_types.dart';
import 'package:logging/logging.dart';
import 'package:yaml/yaml.dart';

final _logger = Logger('ffigen.config_provider.config');

class SchemaNode<E> {
  final List<String> path;
  final E value;

  SchemaNode({required this.path, required this.value});
  SchemaNode<T> withValue<T>(T value) {
    return SchemaNode<T>(path: path, value: value);
  }

  String get pathString => path.join(" -> ");
  bool checkType<T>({bool log = true}) {
    if (value is! T) {
      if (log) {
        _logger.severe(
            "Expected value of key '$pathString' to be of type '$T' (Got ${value.runtimeType}).");
      }
      return false;
    }
    return true;
  }
}

SchemaNode extractOrRaw<E>(
    dynamic Function(SchemaNode<E> value)? extractor, SchemaNode<E> rawValue) {
  if (extractor != null) {
    return rawValue.withValue(extractor.call(rawValue));
  }
  return rawValue;
}

class SchemaExtractionError extends Error {
  SchemaNode? item;
  String message;
  SchemaExtractionError(this.item, [this.message = "Invalid Schema"]);

  @override
  String toString() {
    if (item != null) {
      return "$runtimeType: $message @ ${item!.pathString}";
    }
    return "$runtimeType: $message";
  }
}

abstract class Schema<E> {
  dynamic Function(SchemaNode<E> node)? extractor;
  Schema({required this.extractor});

  bool validateSchema(SchemaNode o, {bool log = true});

  SchemaNode extract(SchemaNode o);
}

class FixedMapSchema<CE> extends Schema<Map<String, CE>> {
  final Map<String, Schema> keys;
  final List<String> requiredKeys;

  FixedMapSchema({
    required this.keys,
    this.requiredKeys = const [],
    super.extractor,
  }) {
    final unknownKeys =
        requiredKeys.where((element) => !keys.containsKey(element)).toList();
    if (unknownKeys.isNotEmpty) {
      throw ArgumentError(
          "Invalid requiredKeys: $unknownKeys, requiredKeys must be a subset of keys");
    }
  }

  @override
  bool validateSchema(SchemaNode o, {bool log = true}) {
    if (!o.checkType<YamlMap>(log: log)) {
      return false;
    }

    var result = true;
    final inputMap = (o.value as YamlMap).cast<String, dynamic>();

    for (final MapEntry(key: key, value: value) in keys.entries) {
      final path = [...o.path, key];
      if (!inputMap.containsKey(key)) {
        if (log) {
          _logger.severe("Unknown key - '${[...o.path, key].join(' -> ')}'.");
        }
        continue;
      }
      final schemaNode = SchemaNode(path: path, value: inputMap[key]);
      if (!value.validateSchema(schemaNode, log: log)) {
        result = false;
        continue;
      }
    }

    for (final requiredKey in requiredKeys) {
      if (!inputMap.containsKey(requiredKey)) {
        _logger.severe(
            "Key '${[...o.path, requiredKey].join(' -> ')}' is required.");
        result = false;
      }
    }

    return result;
  }

  @override
  SchemaNode extract(SchemaNode o) {
    if (!o.checkType<YamlMap>(log: false)) {
      throw SchemaExtractionError(o);
    }

    final inputMap = (o.value as YamlMap).cast<String, dynamic>();
    final childExtracts = <String, CE>{};

    for (final MapEntry(key: key, value: value) in keys.entries) {
      final path = [...o.path, key];
      if (!inputMap.containsKey(key)) {
        continue;
      }
      final schemaNode = SchemaNode(path: path, value: inputMap[key]);
      if (!value.validateSchema(schemaNode, log: false)) {
        throw SchemaExtractionError(schemaNode);
      }
      childExtracts[key] = value.extract(schemaNode).value as CE;
    }
    for (final requiredKey in requiredKeys) {
      if (!inputMap.containsKey(requiredKey)) {
        throw SchemaExtractionError(
            null, "Invalid schema, missing required key - $requiredKey.");
      }
    }

    return extractOrRaw<Map<String, CE>>(extractor, o.withValue(childExtracts));
  }
}

class DynamicMapSchema<CE> extends Schema<Map<String, CE>> {
  final Schema valueSchema;

  DynamicMapSchema({
    required this.valueSchema,
    super.extractor,
  });

  @override
  bool validateSchema(SchemaNode o, {bool log = true}) {
    if (!o.checkType<YamlMap>(log: log)) {
      return false;
    }

    var result = true;
    final inputMap = (o.value as YamlMap).cast<String, dynamic>();

    for (final MapEntry(key: key, value: value) in inputMap.entries) {
      final schemaNode = SchemaNode(path: [...o.path, key], value: value);
      if (!valueSchema.validateSchema(schemaNode, log: log)) {
        result = false;
        continue;
      }
    }

    return result;
  }

  @override
  SchemaNode extract(SchemaNode o) {
    if (!o.checkType<YamlMap>(log: false)) {
      throw SchemaExtractionError(o);
    }

    final inputMap = (o.value as YamlMap).cast<String, dynamic>();
    final childExtracts = <String, CE>{};
    for (final MapEntry(key: key, value: value) in inputMap.entries) {
      final schemaNode = SchemaNode(path: [...o.path, key], value: value);
      if (!valueSchema.validateSchema(schemaNode, log: false)) {
        throw SchemaExtractionError(schemaNode);
      }
      childExtracts[key] = valueSchema.extract(schemaNode) as CE;
    }

    return extractOrRaw(extractor, o.withValue(childExtracts));
  }
}

class ListSchema<CE> extends Schema<List<CE>> {
  final Schema childSchema;

  ListSchema({
    required this.childSchema,
    super.extractor,
  });

  @override
  bool validateSchema(SchemaNode o, {bool log = true}) {
    if (!o.checkType<YamlList>(log: log)) {
      return false;
    }
    final inputList = (o.value as YamlList).cast<dynamic>();
    var result = true;
    for (final (i, input) in inputList.indexed) {
      final schemaNode = SchemaNode(path: [...o.path, "[$i]"], value: input);
      if (!childSchema.validateSchema(schemaNode, log: log)) {
        result = false;
        continue;
      }
    }

    return result;
  }

  @override
  SchemaNode extract(SchemaNode o) {
    if (!o.checkType<YamlList>(log: false)) {
      throw SchemaExtractionError(o);
    }
    final inputList = (o.value as YamlList).cast<dynamic>();
    final childExtracts = <CE>[];
    for (final (i, input) in inputList.indexed) {
      final schemaNode =
          SchemaNode(path: [...o.path, i.toString()], value: input);
      if (!childSchema.validateSchema(schemaNode, log: false)) {
        throw SchemaExtractionError(schemaNode);
      }
      childExtracts.add(childSchema.extract(schemaNode).value as CE);
    }
    return extractOrRaw(extractor, o.withValue(childExtracts));
  }
}

class StringSchema extends Schema<String> {
  StringSchema({
    super.extractor,
  });

  @override
  bool validateSchema(SchemaNode o, {bool log = true}) {
    if (!o.checkType<String>(log: log)) {
      return false;
    }
    return true;
  }

  @override
  SchemaNode extract(SchemaNode o) {
    if (!o.checkType<String>(log: false)) {
      throw SchemaExtractionError(o);
    }
    return extractOrRaw(extractor, o.withValue(o.value as String));
  }
}

class BooleanSchema extends Schema<bool> {
  BooleanSchema({
    super.extractor,
  });

  @override
  bool validateSchema(SchemaNode o, {bool log = true}) {
    if (!o.checkType<bool>(log: log)) {
      return false;
    }
    return true;
  }

  @override
  SchemaNode extract(SchemaNode o) {
    if (!o.checkType<bool>(log: false)) {
      throw SchemaExtractionError(o);
    }
    return extractOrRaw(extractor, o.withValue(o.value as bool));
  }
}

class OneOfSchema<E> extends Schema<E> {
  final List<Schema> children;

  OneOfSchema({
    required this.children,
    super.extractor,
  });

  @override
  bool validateSchema(SchemaNode o, {bool log = true}) {
    for (final schema in children) {
      if (schema.validateSchema(o, log: log)) {
        return true;
      }
    }
    return false;
  }

  @override
  SchemaNode extract(SchemaNode o) {
    for (final schema in children) {
      if (schema.validateSchema(o, log: false)) {
        return extractOrRaw(extractor, o.withValue(schema.extract(o) as E));
      }
    }
    throw SchemaExtractionError(o);
  }
}

void main() {
  final extractMap = <String, dynamic>{};
  final testSchema = FixedMapSchema<dynamic>(
    keys: {
      "name": StringSchema(
        extractor: (node) => extractMap[node.pathString] = node.value,
      ),
      "description": StringSchema(
        extractor: (node) => extractMap[node.pathString] = node.value,
      ),
      "output": OneOfSchema(
        children: [
          StringSchema(
            extractor: (node) => extractMap[node.pathString] = node.value,
          ),
          FixedMapSchema(
            keys: {
              "bindings": StringSchema(),
              "symbol-file": FixedMapSchema<dynamic>(keys: {
                "output": StringSchema(),
                "import-path": StringSchema(),
              })
            },
            requiredKeys: ["bindings"],
            extractor: (node) =>
                OutputConfig(node.value["bindings"] as String, null),
          )
        ],
      ),
      "headers": FixedMapSchema<List<String>>(
        keys: {
          "entry-points": ListSchema<String>(childSchema: StringSchema()),
          "include-directives": ListSchema<String>(childSchema: StringSchema()),
        },
        extractor: (node) => extractMap[node.pathString] = node.value,
      ),
    },
  );
  _logger.onRecord.listen((event) => print(event));
  final yaml = loadYaml("""
name: NativeLibrary
description: Bindings to `headers/example.h`.
output: 'generated_bindings.dart'
headers:
  entry-points:
    - 'headers/example.h'
""");

  print(testSchema.validateSchema(SchemaNode(path: [], value: yaml)));
  print(testSchema.extract(SchemaNode(path: [], value: yaml)).value);
  print(extractMap);
}
