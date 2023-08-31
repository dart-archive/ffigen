import 'package:logging/logging.dart';
import 'package:yaml/yaml.dart';

final _logger = Logger('ffigen.config_provider.config');

/// Base class for all ConfigSpecs to extend.
///
/// [TE] - type input for [transform], [RE] - type input for [result].
///
/// Validation -
///
/// - [customValidation] is called after the ConfigSpec hierarchical validations
/// are completed.
///
/// Extraction -
///
/// - The data is first validated, if invalid it throws a
/// ConfigSpecExtractionError.
/// - The extracted data from the child(s) is collected and the value is
/// transformed via [transform] (if specified).
/// - Finally the [result] closure is called (if specified).
abstract class ConfigSpec<TE extends Object?, RE extends Object?> {
  /// Used to generate and refer the reference definition generated in json
  /// schema. Must be unique for a nested Schema.
  String? schemaDefName;

  /// Used to generate the description field in json schema.
  String? schemaDescription;

  /// Custom validation hook, called post validation if successful.
  bool Function(ConfigValue node)? customValidation;

  /// Used to transform the payload to another type before passing to parent
  /// nodes and [result].
  RE Function(ConfigValue<TE> node)? transform;

  /// Called when final result is prepared via [_extractNode].
  void Function(ConfigValue<RE> node)? result;
  ConfigSpec({
    required this.schemaDefName,
    required this.schemaDescription,
    required this.customValidation,
    required this.transform,
    required this.result,
  });

  bool _validateNode(ConfigValue o, {bool log = true});

  ConfigValue<RE> _extractNode(ConfigValue o);

  /// ConfigSpec objects should call [_getJsonRefOrSchemaNode] instead to get the
  /// child json schema.
  Map<String, dynamic> _generateJsonSchemaNode(Map<String, dynamic> defs);

  Map<String, dynamic> _getJsonRefOrSchemaNode(Map<String, dynamic> defs) {
    if (schemaDefName == null) {
      return _generateJsonSchemaNode(defs);
    }
    defs.putIfAbsent(schemaDefName!, () => _generateJsonSchemaNode(defs));
    return {r"$ref": "#/\$defs/$schemaDefName"};
  }

  Map<String, dynamic> generateJsonSchema(String schemaId) {
    final defs = <String, dynamic>{};
    final schemaMap = _generateJsonSchemaNode(defs);
    return {
      r"$id": schemaId,
      r"$comment":
          "This file is generated. To regenerate run: dart tool/generate_json_schema.dart in github.com/dart-lang/ffigen",
      r"$schema": "https://json-schema.org/draft/2020-12/schema",
      ...schemaMap,
      r"$defs": defs,
    };
  }

  /// Run validation on an object [value].
  bool validate(dynamic value) {
    return _validateNode(ConfigValue(path: [], value: value));
  }

  /// Extract ConfigSpecNode from [value]. This will call the [transform] for all
  /// underlying ConfigSpecs if valid.
  /// Should ideally only be called if [validate] returns True. Throws
  /// [ConfigSpecExtractionError] if any validation fails.
  ConfigValue extract(dynamic value) {
    return _extractNode(ConfigValue(path: [], value: value));
  }
}

/// An individual value in a config for a specific [path] instantiated from a [ConfigSpec].
///
/// A config value contains both the [value] that users of the configuration would want
/// to use, as well as the [rawValue] that was provided as input to the configuration.
class ConfigValue<TE> {
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
  final TE value;

  /// Contains the raw underlying node value. Would be null for fields populated
  /// but default values
  final Object? rawValue;

  ConfigValue({
    required this.path,
    required this.value,
    Object? rawValue,
    bool nullRawValue = false,
  }) : rawValue = nullRawValue ? null : (rawValue ?? value);

  /// Copy object with a different value.
  ConfigValue<T> withValue<T>(T value, Object? rawValue) {
    return ConfigValue<T>(
      path: path,
      value: value,
      rawValue: rawValue,
      nullRawValue: rawValue == null,
    );
  }

  /// Transforms this with a nullable [transform] or return itself
  /// and calls the [result] callback
  ConfigValue<RE> transformOrThis<RE extends Object?>(
    RE Function(ConfigValue<TE> value)? transform,
    void Function(ConfigValue<RE> node)? resultCallback,
  ) {
    ConfigValue<RE> returnValue;
    if (transform != null) {
      returnValue = this.withValue(transform.call(this), rawValue);
    } else {
      returnValue = this.withValue(this.value as RE, rawValue);
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

class ConfigSpecExtractionError extends Error {
  final ConfigValue? item;
  final String message;
  ConfigSpecExtractionError(this.item, [this.message = "Invalid ConfigSpec"]);

  @override
  String toString() {
    if (item != null) {
      return "$runtimeType: $message @ ${item!.pathString}";
    }
    return "$runtimeType: $message";
  }
}

class HeterogeneousMapEntry {
  final String key;
  final ConfigSpec valueConfigSpec;
  final Object? Function(ConfigValue<void> o)? defaultValue;
  void Function(ConfigValue<Object?> node)? resultOrDefault;
  final bool required;

  HeterogeneousMapEntry({
    required this.key,
    required this.valueConfigSpec,
    this.defaultValue,
    this.resultOrDefault,
    this.required = false,
  });
}

enum AdditionalProperties { Allow, Warn, Error }

/// ConfigSpec for a Map which has a fixed set of known keys.
///
/// [CE] typecasts result from entries->{}->valueConfigSpec.
///
/// [RE] typecasts result returned by this node.
class HeterogeneousMapConfigSpec<CE extends Object?, RE extends Object?>
    extends ConfigSpec<Map<dynamic, CE>, RE> {
  final List<HeterogeneousMapEntry> entries;
  final Set<String> allKeys;
  final Set<String> requiredKeys;
  final AdditionalProperties additionalProperties;

  HeterogeneousMapConfigSpec({
    required this.entries,
    super.schemaDefName,
    super.schemaDescription,
    super.customValidation,
    super.transform,
    super.result,
    this.additionalProperties = AdditionalProperties.Warn,
  })  : requiredKeys = {
          for (final kv in entries.where((kv) => kv.required)) kv.key
        },
        allKeys = {for (final kv in entries) kv.key};

  @override
  bool _validateNode(ConfigValue o, {bool log = true}) {
    if (!o.checkType<Map>(log: log)) {
      return false;
    }

    var result = true;
    final inputMap = (o.value as Map);

    for (final requiredKey in requiredKeys) {
      if (!inputMap.containsKey(requiredKey)) {
        if (log) {
          _logger.severe(
              "Key '${[...o.path, requiredKey].join(' -> ')}' is required.");
        }
        result = false;
      }
    }

    for (final entry in entries) {
      final path = [...o.path, entry.key.toString()];
      if (!inputMap.containsKey(entry.key)) {
        continue;
      }
      final configSpecNode =
          ConfigValue(path: path, value: inputMap[entry.key]);
      if (!entry.valueConfigSpec._validateNode(configSpecNode, log: log)) {
        result = false;
        continue;
      }
    }

    if (additionalProperties != AdditionalProperties.Allow) {
      for (final key in inputMap.keys) {
        if (!allKeys.contains(key)) {
          if (log) {
            _logger.severe("Unknown key - '${[...o.path, key].join(' -> ')}'.");
          }
          if (additionalProperties == AdditionalProperties.Error) {
            result = false;
          }
        }
      }
    }

    if (!result && customValidation != null) {
      return customValidation!.call(o);
    }
    return result;
  }

  dynamic _getAllDefaults(ConfigValue o) {
    final result = <dynamic, CE>{};
    for (final entry in entries) {
      final path = [...o.path, entry.key];
      if (entry.defaultValue != null) {
        result[entry.key] = entry.defaultValue!
            .call(ConfigValue(path: path, value: null)) as CE;
      } else if (entry.valueConfigSpec is HeterogeneousMapConfigSpec) {
        final defaultValue =
            (entry.valueConfigSpec as HeterogeneousMapConfigSpec)
                ._getAllDefaults(ConfigValue(path: path, value: null));
        if (defaultValue != null) {
          result[entry.key] =
              (entry.valueConfigSpec as HeterogeneousMapConfigSpec)
                  ._getAllDefaults(ConfigValue(path: path, value: null)) as CE;
        }
      }
      if (result.containsKey(entry.key) && entry.resultOrDefault != null) {
        // Call resultOrDefault hook for HeterogeneousMapEntry.
        entry.resultOrDefault!.call(ConfigValue(
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
  ConfigValue<RE> _extractNode(ConfigValue o) {
    if (!o.checkType<Map>(log: false)) {
      throw ConfigSpecExtractionError(o);
    }

    final inputMap = (o.value as Map);
    final childExtracts = <dynamic, CE>{};

    for (final requiredKey in requiredKeys) {
      if (!inputMap.containsKey(requiredKey)) {
        throw ConfigSpecExtractionError(
            null, "Invalid config spec, missing required key - $requiredKey.");
      }
    }

    for (final entry in entries) {
      final path = [...o.path, entry.key.toString()];
      if (!inputMap.containsKey(entry.key)) {
        // No value specified, fill in with default value instead.
        if (entry.defaultValue != null) {
          childExtracts[entry.key] = entry.defaultValue!
              .call(ConfigValue(path: path, value: null)) as CE;
        } else if (entry.valueConfigSpec is HeterogeneousMapConfigSpec) {
          final defaultValue =
              (entry.valueConfigSpec as HeterogeneousMapConfigSpec)
                  ._getAllDefaults(ConfigValue(path: path, value: null));
          if (defaultValue != null) {
            childExtracts[entry.key] = (entry.valueConfigSpec
                    as HeterogeneousMapConfigSpec)
                ._getAllDefaults(ConfigValue(path: path, value: null)) as CE;
          }
        }
      } else {
        // Extract value from node.
        final configSpecNode =
            ConfigValue(path: path, value: inputMap[entry.key]);
        if (!entry.valueConfigSpec._validateNode(configSpecNode, log: false)) {
          throw ConfigSpecExtractionError(configSpecNode);
        }
        childExtracts[entry.key] =
            entry.valueConfigSpec._extractNode(configSpecNode).value as CE;
      }

      if (childExtracts.containsKey(entry.key) &&
          entry.resultOrDefault != null) {
        // Call resultOrDefault hook for HeterogeneousMapEntry.
        entry.resultOrDefault!.call(ConfigValue(
            path: path, value: childExtracts[entry.key], nullRawValue: true));
      }
    }

    if (additionalProperties == AdditionalProperties.Error) {
      for (final key in inputMap.keys) {
        if (!allKeys.contains(key)) {
          throw ConfigSpecExtractionError(
              o, "Invalid ConfigSpec: additional properties not allowed.");
        }
      }
    }

    return o
        .withValue(childExtracts, o.rawValue)
        .transformOrThis(transform, result);
  }

  @override
  Map<String, dynamic> _generateJsonSchemaNode(Map<String, dynamic> defs) {
    return {
      "type": "object",
      if (additionalProperties != AdditionalProperties.Allow)
        "additionalProperties": false,
      if (schemaDescription != null) "description": schemaDescription!,
      if (entries.isNotEmpty)
        "properties": {
          for (final kv in entries)
            kv.key: kv.valueConfigSpec._getJsonRefOrSchemaNode(defs)
        },
      if (requiredKeys.isNotEmpty) "required": requiredKeys.toList(),
    };
  }
}

/// ConfigSpec for a Map that can have any number of keys.
///
/// [CE] typecasts result from keyValueConfigSpecs->{}->valueConfigSpec.
///
/// [RE] typecasts result returned by this node.
class MapConfigSpec<CE extends Object?, RE extends Object?>
    extends ConfigSpec<Map<dynamic, CE>, RE> {
  /// Both [keyRegexp] - [valueConfigSpec] pair is used to match a set of
  /// key-value input. Atleast one entry must match against an input for it
  /// to be considered valid.
  ///
  /// Note: [keyRegexp] will be matched against key.toString()
  final List<({String keyRegexp, ConfigSpec valueConfigSpec})>
      keyValueConfigSpecs;

  MapConfigSpec({
    required this.keyValueConfigSpecs,
    super.schemaDefName,
    super.schemaDescription,
    super.customValidation,
    super.transform,
    super.result,
  });

  @override
  bool _validateNode(ConfigValue o, {bool log = true}) {
    if (!o.checkType<Map>(log: log)) {
      return false;
    }

    var result = true;
    final inputMap = (o.value as Map);

    for (final MapEntry(key: key, value: value) in inputMap.entries) {
      final configSpecNode =
          ConfigValue(path: [...o.path, key.toString()], value: value);
      var keyValueMatch = false;

      /// Running first time with no logs.
      for (final (keyRegexp: keyRegexp, valueConfigSpec: valueConfigSpec)
          in keyValueConfigSpecs) {
        if (RegExp(keyRegexp, dotAll: true).hasMatch(key.toString()) &&
            valueConfigSpec._validateNode(configSpecNode, log: false)) {
          keyValueMatch = true;
          break;
        }
      }
      if (!keyValueMatch) {
        result = false;
        // No configSpec matched, running again to print logs this time.
        if (log) {
          _logger.severe(
              "'${configSpecNode.pathString}' must match atleast one of the allowed key regex and configSpec.");
          for (final (keyRegexp: keyRegexp, valueConfigSpec: valueConfigSpec)
              in keyValueConfigSpecs) {
            if (!RegExp(keyRegexp, dotAll: true).hasMatch(key.toString())) {
              _logger.severe(
                  "'${configSpecNode.pathString}' does not match regex - '$keyRegexp' (Input - $key)");
              continue;
            }
            if (valueConfigSpec._validateNode(configSpecNode, log: log)) {
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
  ConfigValue<RE> _extractNode(ConfigValue o) {
    if (!o.checkType<Map>(log: false)) {
      throw ConfigSpecExtractionError(o);
    }

    final inputMap = (o.value as Map);
    final childExtracts = <dynamic, CE>{};
    for (final MapEntry(key: key, value: value) in inputMap.entries) {
      final configSpecNode =
          ConfigValue(path: [...o.path, key.toString()], value: value);
      var keyValueMatch = false;
      for (final (keyRegexp: keyRegexp, valueConfigSpec: valueConfigSpec)
          in keyValueConfigSpecs) {
        if (RegExp(keyRegexp, dotAll: true).hasMatch(key.toString()) &&
            valueConfigSpec._validateNode(configSpecNode, log: false)) {
          childExtracts[key] =
              valueConfigSpec._extractNode(configSpecNode).value as CE;
          keyValueMatch = true;
          break;
        }
      }
      if (!keyValueMatch) {
        throw ConfigSpecExtractionError(configSpecNode);
      }
    }

    return o
        .withValue(childExtracts, o.rawValue)
        .transformOrThis(transform, result);
  }

  @override
  Map<String, dynamic> _generateJsonSchemaNode(Map<String, dynamic> defs) {
    return {
      "type": "object",
      if (schemaDescription != null) "description": schemaDescription!,
      if (keyValueConfigSpecs.isNotEmpty)
        "patternProperties": {
          for (final (keyRegexp: keyRegexp, valueConfigSpec: valueConfigSpec)
              in keyValueConfigSpecs)
            keyRegexp: valueConfigSpec._getJsonRefOrSchemaNode(defs)
        }
    };
  }
}

/// ConfigSpec for a List.
///
/// [CE] typecasts result from [childConfigSpec].
///
/// [RE] typecasts result returned by this node.
class ListConfigSpec<CE extends Object?, RE extends Object?>
    extends ConfigSpec<List<CE>, RE> {
  final ConfigSpec childConfigSpec;

  ListConfigSpec({
    required this.childConfigSpec,
    super.schemaDefName,
    super.schemaDescription,
    super.customValidation,
    super.transform,
    super.result,
  });

  @override
  bool _validateNode(ConfigValue o, {bool log = true}) {
    if (!o.checkType<YamlList>(log: log)) {
      return false;
    }
    final inputList = (o.value as YamlList).cast<dynamic>();
    var result = true;
    for (final (i, input) in inputList.indexed) {
      final configSpecNode =
          ConfigValue(path: [...o.path, "[$i]"], value: input);
      if (!childConfigSpec._validateNode(configSpecNode, log: log)) {
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
  ConfigValue<RE> _extractNode(ConfigValue o) {
    if (!o.checkType<YamlList>(log: false)) {
      throw ConfigSpecExtractionError(o);
    }
    final inputList = (o.value as YamlList).cast<dynamic>();
    final childExtracts = <CE>[];
    for (final (i, input) in inputList.indexed) {
      final configSpecNode =
          ConfigValue(path: [...o.path, i.toString()], value: input);
      if (!childConfigSpec._validateNode(configSpecNode, log: false)) {
        throw ConfigSpecExtractionError(configSpecNode);
      }
      childExtracts
          .add(childConfigSpec._extractNode(configSpecNode).value as CE);
    }
    return o
        .withValue(childExtracts, o.rawValue)
        .transformOrThis(transform, result);
  }

  @override
  Map<String, dynamic> _generateJsonSchemaNode(Map<String, dynamic> defs) {
    return {
      "type": "array",
      if (schemaDescription != null) "description": schemaDescription!,
      "items": childConfigSpec._getJsonRefOrSchemaNode(defs),
    };
  }
}

/// ConfigSpec for a String.
///
/// [RE] typecasts result returned by this node.
class StringConfigSpec<RE extends Object?> extends ConfigSpec<String, RE> {
  final String? pattern;
  final RegExp? _regexp;

  StringConfigSpec({
    super.schemaDefName,
    super.schemaDescription,
    super.customValidation,
    super.transform,
    super.result,
    this.pattern,
  }) : _regexp = pattern == null ? null : RegExp(pattern, dotAll: true);

  @override
  bool _validateNode(ConfigValue o, {bool log = true}) {
    if (!o.checkType<String>(log: log)) {
      return false;
    }
    if (!(_regexp?.hasMatch(o.value as String) ?? true)) {
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
  ConfigValue<RE> _extractNode(ConfigValue o) {
    if (!o.checkType<String>(log: false)) {
      throw ConfigSpecExtractionError(o);
    }
    return o
        .withValue(o.value as String, o.rawValue)
        .transformOrThis(transform, result);
  }

  @override
  Map<String, dynamic> _generateJsonSchemaNode(Map<String, dynamic> defs) {
    return {
      "type": "string",
      if (schemaDescription != null) "description": schemaDescription!,
      if (pattern != null) "pattern": pattern,
    };
  }
}

/// ConfigSpec for an Int.
///
/// [RE] typecasts result returned by this node.
class IntConfigSpec<RE extends Object?> extends ConfigSpec<int, RE> {
  IntConfigSpec({
    super.schemaDefName,
    super.schemaDescription,
    super.customValidation,
    super.transform,
    super.result,
  });

  @override
  bool _validateNode(ConfigValue o, {bool log = true}) {
    if (!o.checkType<int>(log: log)) {
      return false;
    }
    if (customValidation != null) {
      return customValidation!.call(o);
    }
    return true;
  }

  @override
  ConfigValue<RE> _extractNode(ConfigValue o) {
    if (!o.checkType<int>(log: false)) {
      throw ConfigSpecExtractionError(o);
    }
    return o
        .withValue(o.value as int, o.rawValue)
        .transformOrThis(transform, result);
  }

  @override
  Map<String, dynamic> _generateJsonSchemaNode(Map<String, dynamic> defs) {
    return {
      "type": "integer",
      if (schemaDescription != null) "description": schemaDescription!,
    };
  }
}

/// ConfigSpec for an object where only specific values are allowed.
/// [CE] is the type for elements in [allowedValues].
///
/// [RE] typecasts result returned by this node.
class EnumConfigSpec<CE extends Object?, RE extends Object?>
    extends ConfigSpec<CE, RE> {
  Set<CE> allowedValues;
  EnumConfigSpec({
    required this.allowedValues,
    super.schemaDefName,
    super.schemaDescription,
    super.customValidation,
    super.transform,
    super.result,
  });

  @override
  bool _validateNode(ConfigValue o, {bool log = true}) {
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
  ConfigValue<RE> _extractNode(ConfigValue o) {
    if (!allowedValues.contains(o.value)) {
      throw ConfigSpecExtractionError(o);
    }
    return o
        .withValue(o.value as CE, o.rawValue)
        .transformOrThis(transform, result);
  }

  @override
  Map<String, dynamic> _generateJsonSchemaNode(Map<String, dynamic> defs) {
    return {
      "enum": allowedValues.toList(),
      if (schemaDescription != null) "description": schemaDescription!,
    };
  }
}

/// ConfigSpec for a bool.
///
/// [RE] typecasts result returned by this node.
class BoolConfigSpec<RE> extends ConfigSpec<bool, RE> {
  BoolConfigSpec({
    super.schemaDefName,
    super.schemaDescription,
    super.customValidation,
    super.transform,
    super.result,
  });

  @override
  bool _validateNode(ConfigValue o, {bool log = true}) {
    if (!o.checkType<bool>(log: log)) {
      return false;
    }
    if (customValidation != null) {
      return customValidation!.call(o);
    }
    return true;
  }

  @override
  ConfigValue<RE> _extractNode(ConfigValue o) {
    if (!o.checkType<bool>(log: false)) {
      throw ConfigSpecExtractionError(o);
    }
    return o
        .withValue(o.value as bool, o.rawValue)
        .transformOrThis(transform, result);
  }

  @override
  Map<String, dynamic> _generateJsonSchemaNode(Map<String, dynamic> defs) {
    return {
      "type": "boolean",
      if (schemaDescription != null) "description": schemaDescription!,
    };
  }
}

/// ConfigSpec that requires atleast one underlying match.
///
/// [TE] typecasts the result returned by the the first valid [childConfigSpecs].
///
/// [RE] typecasts result returned by this node.
class OneOfConfigSpec<TE extends Object?, RE extends Object?>
    extends ConfigSpec<TE, RE> {
  final List<ConfigSpec> childConfigSpecs;

  OneOfConfigSpec({
    required this.childConfigSpecs,
    super.schemaDefName,
    super.schemaDescription,
    super.customValidation,
    super.transform,
    super.result,
  });

  @override
  bool _validateNode(ConfigValue o, {bool log = true}) {
    // Running first time with no logs.
    for (final spec in childConfigSpecs) {
      if (spec._validateNode(o, log: false)) {
        if (customValidation != null) {
          return customValidation!.call(o);
        }
        return true;
      }
    }
    // No configSpec matched, running again to print logs this time.
    if (log) {
      _logger.severe(
          "'${o.pathString}' must match atleast one of the allowed configSpec -");
      for (final spec in childConfigSpecs) {
        spec._validateNode(o, log: log);
      }
    }
    return false;
  }

  @override
  ConfigValue<RE> _extractNode(ConfigValue o) {
    for (final spec in childConfigSpecs) {
      if (spec._validateNode(o, log: false)) {
        return o
            .withValue(spec._extractNode(o).value as TE, o.rawValue)
            .transformOrThis(transform, result);
      }
    }
    throw ConfigSpecExtractionError(o);
  }

  @override
  Map<String, dynamic> _generateJsonSchemaNode(Map<String, dynamic> defs) {
    return {
      if (schemaDescription != null) "description": schemaDescription!,
      r"$oneOf": childConfigSpecs
          .map((child) => child._getJsonRefOrSchemaNode(defs))
          .toList(),
    };
  }
}
