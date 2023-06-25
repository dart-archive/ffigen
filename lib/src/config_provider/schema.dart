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

  /// Custom validation hook, called post schema validation if successful.
  bool Function(SchemaNode node)? customValidation;

  /// Used to transform the payload to another type before passing to parent
  /// nodes and [result].
  dynamic Function(SchemaNode<E> node)? transform;

  /// Called when final result is prepared via [extractNode].
  void Function(SchemaNode<dynamic> node)? result;
  Schema({
    /// Used
    required this.schemaDefName,
    required this.schemaDescription,
    required this.customValidation,
    required this.transform,
    required this.result,
  });

  bool validateNode(SchemaNode o, {bool log = true});

  SchemaNode extractNode(SchemaNode o);

  Map<String, dynamic> generateJsonSchemaNode(Map<String, dynamic> defs);

  Map<String, dynamic> getJsonRefOrSchemaNode(Map<String, dynamic> defs) {
    if (schemaDefName == null) {
      return generateJsonSchemaNode(defs);
    }
    defs.putIfAbsent(schemaDefName!, () => generateJsonSchemaNode(defs));
    return {r"$ref": "#/\$defs/$schemaDefName"};
  }

  Map<String, dynamic> generateJsonSchema(String schemaId) {
    final defs = <String, dynamic>{};
    final schemaMap = generateJsonSchemaNode(defs);
    return {
      r"$id": schemaId,
      r"$schema": "https://json-schema.org/draft/2020-12/schema",
      ...schemaMap,
      r"$defs": defs,
    };
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

class FixedMapKey<DE extends dynamic> {
  final String key;
  final Schema valueSchema;
  final dynamic Function(SchemaNode o)? defaultValue;
  void Function(SchemaNode<DE> node)? resultOrDefault;
  final bool required;

  FixedMapKey({
    required this.key,
    required this.valueSchema,
    this.defaultValue,
    this.resultOrDefault,
    this.required = false,
  });
}

/// Schema for a Map which has a fixed set of known keys.
class FixedMapSchema<CE extends dynamic> extends Schema<Map<dynamic, CE>> {
  final List<FixedMapKey> keys;
  final Set<String> allKeys;
  final Set<String> requiredKeys;
  final bool unknownWarning;

  FixedMapSchema({
    required this.keys,
    super.schemaDefName,
    super.schemaDescription,
    super.customValidation,
    super.transform,
    super.result,
    this.unknownWarning = true,
  })  : requiredKeys = {
          for (final kv in keys.where((kv) => kv.required)) kv.key
        },
        allKeys = {for (final kv in keys) kv.key};

  @override
  bool validateNode(SchemaNode o, {bool log = true}) {
    if (!o.checkType<YamlMap>(log: log)) {
      return false;
    }

    var result = true;
    final inputMap = (o.value as YamlMap);

    for (final requiredKey in requiredKeys) {
      if (!inputMap.containsKey(requiredKey)) {
        if (log) {
          _logger.severe(
              "Key '${[...o.path, requiredKey].join(' -> ')}' is required.");
        }
        result = false;
      }
    }

    for (final entry in keys) {
      final path = [...o.path, entry.key.toString()];
      if (!inputMap.containsKey(entry.key)) {
        continue;
      }
      final schemaNode = SchemaNode(path: path, value: inputMap[entry.key]);
      if (!entry.valueSchema.validateNode(schemaNode, log: log)) {
        result = false;
        continue;
      }
    }

    if (unknownWarning && log) {
      for (final key in inputMap.keys) {
        if (!allKeys.contains(key)) {
          _logger.severe("Unknown key - '${[...o.path, key].join(' -> ')}'.");
        }
      }
    }

    if (!result && customValidation != null) {
      return customValidation!.call(o);
    }
    return result;
  }

  dynamic _getAllDefaults(SchemaNode o) {
    final result = <dynamic, CE>{};
    for (final entry in keys) {
      final path = [...o.path, entry.key];
      if (entry.defaultValue != null) {
        result[entry.key] =
            entry.defaultValue!.call(SchemaNode(path: path, value: null)) as CE;
      } else if (entry.valueSchema is FixedMapSchema) {
        final defaultValue = (entry.valueSchema as FixedMapSchema)
            ._getAllDefaults(SchemaNode(path: path, value: null));
        if (defaultValue != null) {
          result[entry.key] = (entry.valueSchema as FixedMapSchema)
              ._getAllDefaults(SchemaNode(path: path, value: null)) as CE;
        }
      }
      if (result.containsKey(entry.key) && entry.resultOrDefault != null) {
        // Call resultOrDefault hook for FixedMapKey.
        entry.resultOrDefault!.call(SchemaNode(
            path: path, value: result[entry.key], nullRawValue: true));
      }
    }
    return result.isEmpty
        ? null
        : o
            .withValue(result, null)
            .transformOrThis(transform, this.result)
            .value;
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

    for (final entry in keys) {
      final path = [...o.path, entry.key.toString()];
      if (!inputMap.containsKey(entry.key)) {
        // No value specified, fill in with default value instead.
        if (entry.defaultValue != null) {
          childExtracts[entry.key] = entry.defaultValue!
              .call(SchemaNode(path: path, value: null)) as CE;
        } else if (entry.valueSchema is FixedMapSchema) {
          final defaultValue = (entry.valueSchema as FixedMapSchema)
              ._getAllDefaults(SchemaNode(path: path, value: null));
          if (defaultValue != null) {
            childExtracts[entry.key] = (entry.valueSchema as FixedMapSchema)
                ._getAllDefaults(SchemaNode(path: path, value: null)) as CE;
          }
        }
      } else {
        // Extract value from node.
        final schemaNode = SchemaNode(path: path, value: inputMap[entry.key]);
        if (!entry.valueSchema.validateNode(schemaNode, log: false)) {
          throw SchemaExtractionError(schemaNode);
        }
        childExtracts[entry.key] =
            entry.valueSchema.extractNode(schemaNode).value as CE;
      }

      if (childExtracts.containsKey(entry.key) &&
          entry.resultOrDefault != null) {
        // Call resultOrDefault hook for FixedMapKey.
        entry.resultOrDefault!.call(SchemaNode(
            path: path, value: childExtracts[entry.key], nullRawValue: true));
      }
    }
    return o
        .withValue(childExtracts, o.rawValue)
        .transformOrThis(transform, result);
  }

  @override
  Map<String, dynamic> generateJsonSchemaNode(Map<String, dynamic> defs) {
    return {
      "type": "object",
      if (unknownWarning) "additionalProperties": false,
      if (schemaDescription != null) "description": schemaDescription!,
      if (keys.isNotEmpty)
        "properties": {
          for (final kv in keys)
            kv.key: kv.valueSchema.getJsonRefOrSchemaNode(defs)
        },
      if (requiredKeys.isNotEmpty) "required": requiredKeys.toList(),
    };
  }
}

/// Schema for a Map that can have any number of keys.
class DynamicMapSchema<CE extends dynamic> extends Schema<Map<dynamic, CE>> {
  /// [keyRegexp] will convert it's input to a String before matching.
  final List<({String keyRegexp, Schema valueSchema})> keyValueSchemas;

  DynamicMapSchema({
    required this.keyValueSchemas,
    super.schemaDefName,
    super.schemaDescription,
    super.customValidation,
    super.transform,
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

    if (!result && customValidation != null) {
      return customValidation!.call(o);
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
  Map<String, dynamic> generateJsonSchemaNode(Map<String, dynamic> defs) {
    return {
      "type": "object",
      if (schemaDescription != null) "description": schemaDescription!,
      if (keyValueSchemas.isNotEmpty)
        "patternProperties": {
          for (final (keyRegexp: keyRegexp, valueSchema: valueSchema)
              in keyValueSchemas)
            keyRegexp: valueSchema.getJsonRefOrSchemaNode(defs)
        }
    };
  }
}

/// Schema for a List.
class ListSchema<CE extends dynamic> extends Schema<List<CE>> {
  final Schema childSchema;

  ListSchema({
    required this.childSchema,
    super.schemaDefName,
    super.schemaDescription,
    super.customValidation,
    super.transform,
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

    if (!result && customValidation != null) {
      return customValidation!.call(o);
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
  Map<String, dynamic> generateJsonSchemaNode(Map<String, dynamic> defs) {
    return {
      "type": "array",
      if (schemaDescription != null) "description": schemaDescription!,
      "items": childSchema.getJsonRefOrSchemaNode(defs),
    };
  }
}

/// Schema for a String.
class StringSchema extends Schema<String> {
  final String? pattern;
  final RegExp? _regexp;

  StringSchema({
    super.schemaDefName,
    super.schemaDescription,
    super.customValidation,
    super.transform,
    super.result,
    this.pattern,
  }) : _regexp = pattern == null ? null : RegExp(pattern, dotAll: true);

  @override
  bool validateNode(SchemaNode o, {bool log = true}) {
    if (!o.checkType<String>(log: log)) {
      return false;
    }
    if (_regexp != null && !_regexp!.hasMatch(o.value as String)) {
      if (log) {
        _logger.severe(
            "Expected value of key '${o.pathString}' to match pattern $pattern (Input - ${o.value}).");
      }
      return false;
    }
    if (customValidation != null) {
      return customValidation!.call(o);
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
  Map<String, dynamic> generateJsonSchemaNode(Map<String, dynamic> defs) {
    return {
      "type": "string",
      if (schemaDescription != null) "description": schemaDescription!,
      if (pattern != null) "pattern": pattern,
    };
  }
}

/// Schema for an Int.
class IntSchema extends Schema<int> {
  IntSchema({
    super.schemaDefName,
    super.schemaDescription,
    super.customValidation,
    super.transform,
    super.result,
  });

  @override
  bool validateNode(SchemaNode o, {bool log = true}) {
    if (!o.checkType<int>(log: log)) {
      return false;
    }
    if (customValidation != null) {
      return customValidation!.call(o);
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
  Map<String, dynamic> generateJsonSchemaNode(Map<String, dynamic> defs) {
    return {
      "type": "integer",
      if (schemaDescription != null) "description": schemaDescription!,
    };
  }
}

/// Schema for an object where only specific values are allowed.
class EnumSchema<CE extends dynamic> extends Schema<CE> {
  Set<CE> allowedValues;
  EnumSchema({
    required this.allowedValues,
    super.schemaDefName,
    super.schemaDescription,
    super.customValidation,
    super.transform,
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
    if (customValidation != null) {
      return customValidation!.call(o);
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
  Map<String, dynamic> generateJsonSchemaNode(Map<String, dynamic> defs) {
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
    super.customValidation,
    super.transform,
    super.result,
  });

  @override
  bool validateNode(SchemaNode o, {bool log = true}) {
    if (!o.checkType<bool>(log: log)) {
      return false;
    }
    if (customValidation != null) {
      return customValidation!.call(o);
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
  Map<String, dynamic> generateJsonSchemaNode(Map<String, dynamic> defs) {
    return {
      "type": "boolean",
      if (schemaDescription != null) "description": schemaDescription!,
    };
  }
}

/// Schema which checks if atleast one of the underlying Schema matches.
class OneOfSchema<E extends dynamic> extends Schema<E> {
  final List<Schema> childSchemas;

  OneOfSchema({
    required this.childSchemas,
    super.schemaDefName,
    super.schemaDescription,
    super.customValidation,
    super.transform,
    super.result,
  });

  @override
  bool validateNode(SchemaNode o, {bool log = true}) {
    // Running first time with no logs.
    for (final schema in childSchemas) {
      if (schema.validateNode(o, log: false)) {
        if (customValidation != null) {
          return customValidation!.call(o);
        }
        return true;
      }
    }
    // No schema matched, running again to print logs this time.
    if (log) {
      _logger.severe(
          "'${o.pathString}' must match atleast one of the allowed schema -");
      for (final schema in childSchemas) {
        schema.validateNode(o, log: log);
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
  Map<String, dynamic> generateJsonSchemaNode(Map<String, dynamic> defs) {
    return {
      if (schemaDescription != null) "description": schemaDescription!,
      r"$oneOf": childSchemas
          .map((child) => child.getJsonRefOrSchemaNode(defs))
          .toList(),
    };
  }
}
