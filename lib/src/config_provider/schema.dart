import 'dart:convert';

import 'package:ffigen/src/config_provider/config_types.dart';
import 'package:logging/logging.dart';
import 'package:yaml/yaml.dart';

final _logger = Logger('ffigen.config_provider.config');

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

  /// Contains the underlying node value after all transformations and
  /// default values have been applied.
  final E value;

  /// Contains the raw underlying node value. Would be null for fields populated
  /// but default values
  final dynamic rawValue;

  SchemaNode({
    required this.path,
    required this.value,
    dynamic rawValue,
    bool nullRawValue = false,
  }) : rawValue = nullRawValue ? null : (rawValue ?? value);

  /// Copy object with a different value.
  SchemaNode<T> withValue<T>(T value, dynamic rawValue) {
    return SchemaNode<T>(
      path: path,
      value: value,
      rawValue: rawValue,
      nullRawValue: rawValue == null,
    );
  }

  /// Transforms this SchemaNode with a nullable [transform] or return itself
  /// and calls the [result] callback
  SchemaNode transformOrThis(
    dynamic Function(SchemaNode<E> value)? transform,
    void Function(SchemaNode node)? resultCallback,
  ) {
    SchemaNode returnValue = this;
    if (transform != null) {
      returnValue = this.withValue(transform.call(this), rawValue);
    }
    resultCallback?.call(returnValue);
    return returnValue;
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
  /// Used to generate and refer the reference definition generated in json
  /// schema. Must be unique for a nested Schema.
  String? schemaDefName;

  /// Used to generate the description field in json schema.
  String? schemaDescription;

  /// Used to transform the payload to another type before passing to parent
  /// nodes and [result].
  dynamic Function(SchemaNode<E> node)? transform;

  /// Passed to parent nodes and result (only if required by parent)
  ///
  /// SchemaNode<void> is used since value should not be accessed here.
  dynamic Function(SchemaNode<void> node)? defaultValue;

  /// Called when final result is prepared via [extractNode] or
  /// [getDefaultValue].
  void Function(SchemaNode<dynamic> node)? result;
  Schema({
    /// Used
    this.schemaDefName,
    this.schemaDescription,
    this.transform,
    this.defaultValue,
    this.result,
  });

  bool validateNode(SchemaNode o, {bool log = true});

  SchemaNode extractNode(SchemaNode o);

  Map<String, dynamic> generateJsonSchema(Map<String, dynamic> defs);

  /// Returns default value or null for a node. Calls [result] if value is
  /// not null.
  dynamic getDefaultValue(SchemaNode o) {
    final v = defaultValue?.call(o.withValue(null, null));
    if (v != null) result?.call(o.withValue(v, null));
    return v;
  }

  Map<String, dynamic> getRefOrSchema(Map<String, dynamic> defs) {
    if (schemaDefName == null) {
      return generateJsonSchema(defs);
    }
    defs.putIfAbsent(schemaDefName!, () => generateJsonSchema(defs));
    return {r"$ref": "#/\$defs/$schemaDefName"};
  }

  /// Run validation on an object [value].
  bool validate(dynamic value) {
    return validateNode(SchemaNode(path: [], value: value));
  }

  /// Extract SchemaNode from [value]. This will call the [transform] for all
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
    super.schemaDefName,
    super.schemaDescription,
    super.transform,
    super.defaultValue,
    super.result,
  }) {
    final unknownKeys =
        requiredKeys.where((element) => !keys.containsKey(element)).toList();
    if (unknownKeys.isNotEmpty) {
      throw ArgumentError(
          "Invalid requiredKeys: $unknownKeys, requiredKeys must be a subset of keys");
    }

    // Get default values of underlying keys if [defaultValue] is not specified
    // for this.
    super.defaultValue ??= (SchemaNode o) {
      final result = <dynamic, CE>{};
      for (final MapEntry(key: key, value: value) in keys.entries) {
        final defaultValue = value.getDefaultValue(
            SchemaNode(path: [...o.path, key.toString()], value: value));
        if (defaultValue != null) {
          result[key] = defaultValue as CE;
        }
      }
      return result.isEmpty ? null : result;
    };
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
        // No value specified, fill in with default value instead.
        final defaultValue =
            value.getDefaultValue(SchemaNode(path: path, value: null));
        if (defaultValue != null) {
          childExtracts[key] = defaultValue as CE;
        }
        continue;
      }
      final schemaNode = SchemaNode(path: path, value: inputMap[key]);
      if (!value.validateNode(schemaNode, log: false)) {
        throw SchemaExtractionError(schemaNode);
      }
      childExtracts[key] = value.extractNode(schemaNode).value as CE;
    }
    return o
        .withValue(childExtracts, o.rawValue)
        .transformOrThis(transform, result);
  }

  @override
  Map<String, dynamic> generateJsonSchema(Map<String, dynamic> defs) {
    return {
      "type": "object",
      if (schemaDescription != null) "description": schemaDescription!,
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
    super.schemaDefName,
    super.schemaDescription,
    super.transform,
    super.defaultValue,
    super.result,
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

    return o
        .withValue(childExtracts, o.rawValue)
        .transformOrThis(transform, result);
  }

  @override
  Map<String, dynamic> generateJsonSchema(Map<String, dynamic> defs) {
    return {
      "type": "object",
      if (schemaDescription != null) "description": schemaDescription!,
      if (keyValueSchemas.isNotEmpty)
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
    super.schemaDefName,
    super.schemaDescription,
    super.transform,
    super.defaultValue,
    super.result,
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
    return o
        .withValue(childExtracts, o.rawValue)
        .transformOrThis(transform, result);
  }

  @override
  Map<String, dynamic> generateJsonSchema(Map<String, dynamic> defs) {
    return {
      "type": "array",
      if (schemaDescription != null) "description": schemaDescription!,
      "items": childSchema.getRefOrSchema(defs),
    };
  }
}

/// Schema for a String.
class StringSchema extends Schema<String> {
  StringSchema({
    super.schemaDefName,
    super.schemaDescription,
    super.transform,
    super.defaultValue,
    super.result,
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
    return o
        .withValue(o.value as String, o.rawValue)
        .transformOrThis(transform, result);
  }

  @override
  Map<String, dynamic> generateJsonSchema(Map<String, dynamic> defs) {
    return {
      "type": "string",
      if (schemaDescription != null) "description": schemaDescription!,
    };
  }
}

/// Schema for an Int.
class IntSchema extends Schema<int> {
  IntSchema({
    super.schemaDefName,
    super.schemaDescription,
    super.transform,
    super.defaultValue,
    super.result,
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
    return o
        .withValue(o.value as int, o.rawValue)
        .transformOrThis(transform, result);
  }

  @override
  Map<String, dynamic> generateJsonSchema(Map<String, dynamic> defs) {
    return {
      "type": "integer",
      if (schemaDescription != null) "description": schemaDescription!,
    };
  }
}

/// Schema for an object where only specific values are allowed.
class EnumSchema<CE> extends Schema<CE> {
  Set<CE> allowedValues;
  EnumSchema({
    required this.allowedValues,
    super.schemaDefName,
    super.schemaDescription,
    super.transform,
    super.defaultValue,
    super.result,
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
    return o
        .withValue(o.value as CE, o.rawValue)
        .transformOrThis(transform, result);
  }

  @override
  Map<String, dynamic> generateJsonSchema(Map<String, dynamic> defs) {
    return {
      "enum": allowedValues.toList(),
      if (schemaDescription != null) "description": schemaDescription!,
    };
  }
}

/// Schema for a bool.
class BoolSchema extends Schema<bool> {
  BoolSchema({
    super.schemaDefName,
    super.schemaDescription,
    super.transform,
    super.defaultValue,
    super.result,
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
    return o
        .withValue(o.value as bool, o.rawValue)
        .transformOrThis(transform, result);
  }

  @override
  Map<String, dynamic> generateJsonSchema(Map<String, dynamic> defs) {
    return {
      "type": "boolean",
      if (schemaDescription != null) "description": schemaDescription!,
    };
  }
}

/// Schema which checks if atleast one of the underlying Schema matches.
class OneOfSchema<E> extends Schema<E> {
  final List<Schema> childSchemas;

  OneOfSchema({
    required this.childSchemas,
    super.schemaDefName,
    super.schemaDescription,
    super.transform,
    super.defaultValue,
    super.result,
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
            .withValue(schema.extractNode(o).value as E, o.rawValue)
            .transformOrThis(transform, result);
      }
    }
    throw SchemaExtractionError(o);
  }

  @override
  Map<String, dynamic> generateJsonSchema(Map<String, dynamic> defs) {
    return {
      if (schemaDescription != null) "description": schemaDescription!,
      r"$oneOf":
          childSchemas.map((child) => child.getRefOrSchema(defs)).toList(),
    };
  }
}

void main() {
  final extractMap = <String, dynamic>{};
  final testSchema = FixedMapSchema<dynamic>(
      keys: {
        "name": StringSchema(
          result: (node) => extractMap[node.pathString] = node.value,
        ),
        "description": StringSchema(
          result: (node) => extractMap[node.pathString] = node.value,
        ),
        "output": OneOfSchema(
          childSchemas: [
            StringSchema(
              schemaDefName: "outputBindings",
              transform: (node) => extractMap[node.pathString] = node.value,
            ),
            FixedMapSchema(
              keys: {
                "bindings": StringSchema(
                  schemaDefName: "outputBindings",
                ),
                "symbol-file": FixedMapSchema<dynamic>(keys: {
                  "output": StringSchema(),
                  "import-path": StringSchema(),
                })
              },
              requiredKeys: ["bindings"],
              transform: (node) =>
                  OutputConfig(node.value["bindings"] as String, null),
              result: (node) => extractMap[node.pathString] = node.value,
            )
          ],
        ),
        "headers": FixedMapSchema<List<String>>(
          keys: {
            "entry-points": ListSchema<String>(childSchema: StringSchema()),
            "include-directives":
                ListSchema<String>(childSchema: StringSchema()),
          },
          result: (node) => extractMap[node.pathString] = node.value,
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
        "comments": FixedMapSchema<dynamic>(
          keys: {
            "style": EnumSchema(
              allowedValues: {"any", "doxygen"},
              defaultValue: (node) => "doxygen",
            ),
            "length": EnumSchema(
              allowedValues: {"brief", "full"},
              defaultValue: (node) => "brief",
              result: (node) => extractMap[node.pathString] = node.value,
            ),
          },
          result: (node) {
            print("comments rawValue: ${node.rawValue}");
            print("comments value: ${node.value}");
            extractMap[node.pathString] = node.value;
          },
        ),
      },
      result: (node) {
        print("root rawValue: ${node.rawValue}");
        print("root value: ${node.value}");
        extractMap[node.pathString] = node.value;
      });
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
