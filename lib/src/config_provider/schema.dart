import 'dart:convert';

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

  SchemaNode extractOrRaw(dynamic Function(SchemaNode<E> value)? extractor) {
    if (extractor != null) {
      return this.withValue(extractor.call(this));
    }
    return this;
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

  bool validate(dynamic value) {
    return validateNode(SchemaNode(path: [], value: value));
  }

  SchemaNode extract(dynamic value) {
    return extractNode(SchemaNode(path: [], value: value));
  }
}

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

    for (final MapEntry(key: key, value: value) in keys.entries) {
      final path = [...o.path, key.toString()];
      if (!inputMap.containsKey(key)) {
        if (log) {
          _logger.severe("Unknown key - '${[...o.path, key].join(' -> ')}'.");
        }
        continue;
      }
      final schemaNode = SchemaNode(path: path, value: inputMap[key]);
      if (!value.validateNode(schemaNode, log: log)) {
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
  SchemaNode extractNode(SchemaNode o) {
    if (!o.checkType<YamlMap>(log: false)) {
      throw SchemaExtractionError(o);
    }

    final inputMap = (o.value as YamlMap);
    final childExtracts = <dynamic, CE>{};

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
    for (final requiredKey in requiredKeys) {
      if (!inputMap.containsKey(requiredKey)) {
        throw SchemaExtractionError(
            null, "Invalid schema, missing required key - $requiredKey.");
      }
    }
    return o.withValue(childExtracts).extractOrRaw(extractor);
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

class DynamicMapSchema<CE> extends Schema<Map<dynamic, CE>> {
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
      for (final (keyRegexp: keyRegexp, valueSchema: valueSchema)
          in keyValueSchemas) {
        if (RegExp(keyRegexp).hasMatch(key.toString()) &&
            valueSchema.validateNode(schemaNode, log: log)) {
          keyValueMatch = true;
          break;
        }
      }
      if (!keyValueMatch) {
        result = false;
        continue;
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
        if (RegExp(keyRegexp).hasMatch(key.toString()) &&
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

    return o.withValue(childExtracts).extractOrRaw(extractor);
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
    return o.withValue(childExtracts).extractOrRaw(extractor);
  }

  @override
  Map<String, dynamic> generateJsonSchema(Map<String, dynamic> defs) {
    return {"type": "array", "items": childSchema.getRefOrSchema(defs)};
  }
}

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
    return o.withValue(o.value as String).extractOrRaw(extractor);
  }

  @override
  Map<String, dynamic> generateJsonSchema(Map<String, dynamic> defs) {
    return {"type": "string"};
  }
}

class IntegerSchema extends Schema<int> {
  IntegerSchema({
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
    return o.withValue(o.value as int).extractOrRaw(extractor);
  }

  @override
  Map<String, dynamic> generateJsonSchema(Map<String, dynamic> defs) {
    return {"type": "integer"};
  }
}

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
    return o.withValue(o.value as CE).extractOrRaw(extractor);
  }

  @override
  Map<String, dynamic> generateJsonSchema(Map<String, dynamic> defs) {
    return {"enum": allowedValues.toList()};
  }
}

class BooleanSchema extends Schema<bool> {
  BooleanSchema({
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
    return o.withValue(o.value as bool).extractOrRaw(extractor);
  }

  @override
  Map<String, dynamic> generateJsonSchema(Map<String, dynamic> defs) {
    return {"type": "boolean"};
  }
}

class OneOfSchema<E> extends Schema<E> {
  final List<Schema> childSchemas;

  OneOfSchema({
    required this.childSchemas,
    super.extractor,
    super.defName,
  });

  @override
  bool validateNode(SchemaNode o, {bool log = true}) {
    for (final schema in childSchemas) {
      if (schema.validateNode(o, log: log)) {
        return true;
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
            .extractOrRaw(extractor);
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
            keyRegexp: r"^.*$",
            valueSchema:
                OneOfSchema(childSchemas: [StringSchema(), IntegerSchema()]),
          )
        ]),
        "pack": DynamicMapSchema<dynamic>(keyValueSchemas: [
          (
            keyRegexp: r"^.*$",
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
    0: 1
  pack:
    'ABCD': 2
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
