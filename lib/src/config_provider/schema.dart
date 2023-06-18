import 'dart:convert';

import 'package:ffigen/src/config_provider/config_types.dart';
import 'package:logging/logging.dart';
import 'package:yaml/yaml.dart';

final _logger = Logger('ffigen.config_provider.config');

/// A Schema Node is a container for the [path] and the [value] of schema.
///
/// During validation, [value] is always the raw underlying object.
/// During extraction. [value] can either be the raw underlying object or
/// the value retuned by the Schema extractor.
///

/// A container object for a Schema Object.
class SchemaNode<E> {
  /// The path to this node.
  ///
  /// E.g - ["path", "to", "arr", "[1]", "item"]
  final List<String> path;

  /// Get a string representation for path.
  ///
  /// E.g - "path -> to -> arr -> [1] -> item"
  String get pathString => path.join(" -> ");

  final E value;

  SchemaNode({required this.path, required this.value});

  /// Copy object with a different value.
  SchemaNode<T> withValue<T>(T value) {
    return SchemaNode<T>(path: path, value: value);
  }

  /// Transforms this SchemaNode with a nullable [extractor] or return itself.
  SchemaNode extractOrThis(dynamic Function(SchemaNode<E> value)? extractor) {
    if (extractor != null) {
      return this.withValue(extractor.call(this));
    }
    return this;
  }

  /// Returns true if [value] is of Type [T].
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

class SchemaExtractionError extends Error {
  final SchemaNode? item;
  final String message;
  SchemaExtractionError(this.item, [this.message = "Invalid Schema"]);

  @override
  String toString() {
    if (item != null) {
      return "$runtimeType: $message @ ${item!.pathString}";
    }
    return "$runtimeType: $message";
  }
}

/// Base class for all Schemas to extend.
abstract class Schema<E> {
  String? defName;
  dynamic Function(SchemaNode<E> node)? extractor;
  Schema({required this.extractor, this.defName});

  bool validateNode(SchemaNode o, {bool log = true});

  SchemaNode extractNode(SchemaNode o);

  Map<String, dynamic> getRefOrSchema(Map<String, dynamic> defs) {
    if (defName == null) {
      return generateJsonSchema(defs);
    }
    defs.putIfAbsent(defName!, () => generateJsonSchema(defs));
    return {r"$ref": "#/\$defs/$defName"};
  }

  Map<String, dynamic> generateJsonSchema(Map<String, dynamic> defs);

  /// Run validation on an object [value].
  bool validate(dynamic value) {
    return validateNode(SchemaNode(path: [], value: value));
  }

  /// Extract SchemaNode from [value]. This will call the [extractor] for all
  /// underlying Schemas if valid.
  /// Should ideally only be called if [validate] returns True. Throws
  /// [SchemaExtractionError] if any validation fails.
  SchemaNode extract(dynamic value) {
    return extractNode(SchemaNode(path: [], value: value));
  }
}

/// Schema for a Map which has a fixed set of known keys.
class FixedMapSchema<CE> extends Schema<Map<dynamic, CE>> {
  final Map<dynamic, Schema> keys;
  final List<String> requiredKeys;

  FixedMapSchema({
    required this.keys,
    this.requiredKeys = const [],
    super.extractor,
    super.defName,
  }) {
    final unknownKeys =
        requiredKeys.where((element) => !keys.containsKey(element)).toList();
    if (unknownKeys.isNotEmpty) {
      throw ArgumentError(
          "Invalid requiredKeys: $unknownKeys, requiredKeys must be a subset of keys");
    }
  }

  @override
  bool validateNode(SchemaNode o, {bool log = true}) {
    if (!o.checkType<YamlMap>(log: log)) {
      return false;
    }

    var result = true;
    final inputMap = (o.value as YamlMap);

    for (final requiredKey in requiredKeys) {
      if (!inputMap.containsKey(requiredKey)) {
        _logger.severe(
            "Key '${[...o.path, requiredKey].join(' -> ')}' is required.");
        result = false;
      }
    }

    for (final MapEntry(key: key, value: value) in keys.entries) {
      final path = [...o.path, key.toString()];
      if (!inputMap.containsKey(key)) {
        continue;
      }
      final schemaNode = SchemaNode(path: path, value: inputMap[key]);
      if (!value.validateNode(schemaNode, log: log)) {
        result = false;
        continue;
      }
    }

    for (final key in inputMap.keys) {
      if (!keys.containsKey(key)) {
        if (log) {
          _logger.severe("Unknown key - '${[...o.path, key].join(' -> ')}'.");
        }
      }
    }

    return result;
  }

  @override
  SchemaNode extractNode(SchemaNode o) {
    if (!o.checkType<YamlMap>(log: false)) {
      throw SchemaExtractionError(o);
    }

    final inputMap = (o.value as YamlMap);
    final childExtracts = <dynamic, CE>{};

    for (final requiredKey in requiredKeys) {
      if (!inputMap.containsKey(requiredKey)) {
        throw SchemaExtractionError(
            null, "Invalid schema, missing required key - $requiredKey.");
      }
    }

    for (final MapEntry(key: key, value: value) in keys.entries) {
      final path = [...o.path, key.toString()];
      if (!inputMap.containsKey(key)) {
        continue;
      }
      final schemaNode = SchemaNode(path: path, value: inputMap[key]);
      if (!value.validateNode(schemaNode, log: false)) {
        throw SchemaExtractionError(schemaNode);
      }
      childExtracts[key] = value.extractNode(schemaNode).value as CE;
    }
    return o.withValue(childExtracts).extractOrThis(extractor);
  }

  @override
  Map<String, dynamic> generateJsonSchema(Map<String, dynamic> defs) {
    return {
      "type": "object",
      if (keys.isNotEmpty)
        "properties": {
          for (final kv in keys.entries) kv.key: kv.value.getRefOrSchema(defs)
        },
      if (requiredKeys.isNotEmpty) "required": requiredKeys,
    };
  }
}

/// Schema for a Map that can have any number of keys.
class DynamicMapSchema<CE> extends Schema<Map<dynamic, CE>> {
  /// [keyRegexp] will convert it's input to a String before matching.
  final List<({String keyRegexp, Schema valueSchema})> keyValueSchemas;

  DynamicMapSchema({
    required this.keyValueSchemas,
    super.extractor,
    super.defName,
  });

  @override
  bool validateNode(SchemaNode o, {bool log = true}) {
    if (!o.checkType<YamlMap>(log: log)) {
      return false;
    }

    var result = true;
    final inputMap = (o.value as YamlMap);

    for (final MapEntry(key: key, value: value) in inputMap.entries) {
      final schemaNode =
          SchemaNode(path: [...o.path, key.toString()], value: value);
      var keyValueMatch = false;

      /// Running first time with no logs.
      for (final (keyRegexp: keyRegexp, valueSchema: valueSchema)
          in keyValueSchemas) {
        if (RegExp(keyRegexp, dotAll: true).hasMatch(key.toString()) &&
            valueSchema.validateNode(schemaNode, log: false)) {
          keyValueMatch = true;
          break;
        }
      }
      if (!keyValueMatch) {
        result = false;
        // No schema matched, running again to print logs this time.
        if (log) {
          _logger.severe(
              "'${schemaNode.pathString}' must match atleast one of the allowed key regex and schema.");
          for (final (keyRegexp: keyRegexp, valueSchema: valueSchema)
              in keyValueSchemas) {
            if (!RegExp(keyRegexp, dotAll: true).hasMatch(key.toString())) {
              _logger.severe(
                  "'${schemaNode.pathString}' does not match regex - '$keyRegexp' (Input - $key)");
              continue;
            }
            if (valueSchema.validateNode(schemaNode, log: log)) {
              continue;
            }
          }
        }
      }
    }

    return result;
  }

  @override
  SchemaNode extractNode(SchemaNode o) {
    if (!o.checkType<YamlMap>(log: false)) {
      throw SchemaExtractionError(o);
    }

    final inputMap = (o.value as YamlMap);
    final childExtracts = <dynamic, CE>{};
    for (final MapEntry(key: key, value: value) in inputMap.entries) {
      final schemaNode =
          SchemaNode(path: [...o.path, key.toString()], value: value);
      var keyValueMatch = false;
      for (final (keyRegexp: keyRegexp, valueSchema: valueSchema)
          in keyValueSchemas) {
        if (RegExp(keyRegexp, dotAll: true).hasMatch(key.toString()) &&
            valueSchema.validateNode(schemaNode, log: false)) {
          childExtracts[key] = valueSchema.extractNode(schemaNode).value as CE;
          keyValueMatch = true;
          break;
        }
      }
      if (!keyValueMatch) {
        throw SchemaExtractionError(schemaNode);
      }
    }

    return o.withValue(childExtracts).extractOrThis(extractor);
  }

  @override
  Map<String, dynamic> generateJsonSchema(Map<String, dynamic> defs) {
    return {
      "type": "object",
      "patternProperties": {
        for (final (keyRegexp: keyRegexp, valueSchema: valueSchema)
            in keyValueSchemas)
          keyRegexp: valueSchema.getRefOrSchema(defs)
      }
    };
  }
}

/// Schema for a List.
class ListSchema<CE> extends Schema<List<CE>> {
  final Schema childSchema;

  ListSchema({
    required this.childSchema,
    super.extractor,
    super.defName,
  });

  @override
  bool validateNode(SchemaNode o, {bool log = true}) {
    if (!o.checkType<YamlList>(log: log)) {
      return false;
    }
    final inputList = (o.value as YamlList).cast<dynamic>();
    var result = true;
    for (final (i, input) in inputList.indexed) {
      final schemaNode = SchemaNode(path: [...o.path, "[$i]"], value: input);
      if (!childSchema.validateNode(schemaNode, log: log)) {
        result = false;
        continue;
      }
    }

    return result;
  }

  @override
  SchemaNode extractNode(SchemaNode o) {
    if (!o.checkType<YamlList>(log: false)) {
      throw SchemaExtractionError(o);
    }
    final inputList = (o.value as YamlList).cast<dynamic>();
    final childExtracts = <CE>[];
    for (final (i, input) in inputList.indexed) {
      final schemaNode =
          SchemaNode(path: [...o.path, i.toString()], value: input);
      if (!childSchema.validateNode(schemaNode, log: false)) {
        throw SchemaExtractionError(schemaNode);
      }
      childExtracts.add(childSchema.extractNode(schemaNode).value as CE);
    }
    return o.withValue(childExtracts).extractOrThis(extractor);
  }

  @override
  Map<String, dynamic> generateJsonSchema(Map<String, dynamic> defs) {
    return {"type": "array", "items": childSchema.getRefOrSchema(defs)};
  }
}

/// Schema for a String.
class StringSchema extends Schema<String> {
  StringSchema({
    super.extractor,
    super.defName,
  });

  @override
  bool validateNode(SchemaNode o, {bool log = true}) {
    if (!o.checkType<String>(log: log)) {
      return false;
    }
    return true;
  }

  @override
  SchemaNode extractNode(SchemaNode o) {
    if (!o.checkType<String>(log: false)) {
      throw SchemaExtractionError(o);
    }
    return o.withValue(o.value as String).extractOrThis(extractor);
  }

  @override
  Map<String, dynamic> generateJsonSchema(Map<String, dynamic> defs) {
    return {"type": "string"};
  }
}

/// Schema for an Int.
class IntSchema extends Schema<int> {
  IntSchema({
    super.extractor,
    super.defName,
  });

  @override
  bool validateNode(SchemaNode o, {bool log = true}) {
    if (!o.checkType<int>(log: log)) {
      return false;
    }
    return true;
  }

  @override
  SchemaNode extractNode(SchemaNode o) {
    if (!o.checkType<int>(log: false)) {
      throw SchemaExtractionError(o);
    }
    return o.withValue(o.value as int).extractOrThis(extractor);
  }

  @override
  Map<String, dynamic> generateJsonSchema(Map<String, dynamic> defs) {
    return {"type": "integer"};
  }
}

/// Schema for an object where only specific values are allowed.
class EnumSchema<CE> extends Schema<CE> {
  Set<CE> allowedValues;
  EnumSchema({
    required this.allowedValues,
    super.extractor,
    super.defName,
  });

  @override
  bool validateNode(SchemaNode o, {bool log = true}) {
    if (!allowedValues.contains(o.value)) {
      if (log) {
        _logger.severe(
            "'${o.pathString}' must be one of the following - $allowedValues (Got ${o.value})");
      }
      return false;
    }
    return true;
  }

  @override
  SchemaNode extractNode(SchemaNode o) {
    if (!allowedValues.contains(o.value)) {
      throw SchemaExtractionError(o);
    }
    return o.withValue(o.value as CE).extractOrThis(extractor);
  }

  @override
  Map<String, dynamic> generateJsonSchema(Map<String, dynamic> defs) {
    return {"enum": allowedValues.toList()};
  }
}

/// Schema for a bool.
class BoolSchema extends Schema<bool> {
  BoolSchema({
    super.extractor,
    super.defName,
  });

  @override
  bool validateNode(SchemaNode o, {bool log = true}) {
    if (!o.checkType<bool>(log: log)) {
      return false;
    }
    return true;
  }

  @override
  SchemaNode extractNode(SchemaNode o) {
    if (!o.checkType<bool>(log: false)) {
      throw SchemaExtractionError(o);
    }
    return o.withValue(o.value as bool).extractOrThis(extractor);
  }

  @override
  Map<String, dynamic> generateJsonSchema(Map<String, dynamic> defs) {
    return {"type": "boolean"};
  }
}

/// Schema which checks if atleast one of the underlying Schema matches.
class OneOfSchema<E> extends Schema<E> {
  final List<Schema> childSchemas;

  OneOfSchema({
    required this.childSchemas,
    super.extractor,
    super.defName,
  });

  @override
  bool validateNode(SchemaNode o, {bool log = true}) {
    // Running first time with no logs.
    for (final schema in childSchemas) {
      if (schema.validateNode(o, log: false)) {
        return true;
      }
    }
    // No schema matched, running again to print logs this time.
    if (log) {
      _logger.severe(
          "'${o.pathString}' must match atleast one of the allowed schema -");
      for (final schema in childSchemas) {
        if (schema.validateNode(o, log: log)) {
          return true;
        }
      }
    }
    return false;
  }

  @override
  SchemaNode extractNode(SchemaNode o) {
    for (final schema in childSchemas) {
      if (schema.validateNode(o, log: false)) {
        return o
            .withValue(schema.extractNode(o).value as E)
            .extractOrThis(extractor);
      }
    }
    throw SchemaExtractionError(o);
  }

  @override
  Map<String, dynamic> generateJsonSchema(Map<String, dynamic> defs) {
    return {
      r"$oneOf":
          childSchemas.map((child) => child.getRefOrSchema(defs)).toList()
    };
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
        childSchemas: [
          StringSchema(
            defName: "outputBindings",
            extractor: (node) => extractMap[node.pathString] = node.value,
          ),
          FixedMapSchema(
            keys: {
              "bindings": StringSchema(
                defName: "outputBindings",
              ),
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
      "structs": FixedMapSchema<dynamic>(keys: {
        "include": ListSchema<String>(childSchema: StringSchema()),
        "exclude": ListSchema<String>(childSchema: StringSchema()),
        "rename": DynamicMapSchema<dynamic>(keyValueSchemas: [
          (
            keyRegexp: r"^.+$",
            valueSchema:
                OneOfSchema(childSchemas: [StringSchema(), IntSchema()]),
          )
        ]),
        "pack": DynamicMapSchema<dynamic>(keyValueSchemas: [
          (
            keyRegexp: r"^.+$",
            valueSchema:
                EnumSchema<dynamic>(allowedValues: {null, 1, 2, 4, 8, 16}),
          )
        ])
      }),
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
structs:
  rename:
    a: b
  pack:
    a: 2
""");

  print("validate: ${testSchema.validate(yaml)}");
  print("extract: ${testSchema.extract(yaml).value}");
  print("extractMap: $extractMap");
  final defs = <String, dynamic>{};
  final jsonSchema = testSchema.generateJsonSchema(defs);
  print("jsonschema object: $jsonSchema");
  print("defs: $defs");
  final jsonSchemaJson = jsonEncode({
    r"$id": "test",
    r"$schema": "https://json-schema.org/draft/2020-12/schema",
    ...jsonSchema,
    r"$defs": defs,
  });
  print("jsonschema file: $jsonSchemaJson");
}
