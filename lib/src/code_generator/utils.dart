import 'dart_keywords.dart';

class UniqueNamer {
  final Set<String> _usedUpNames;

  /// Creates a UniqueNamer with given [usedUpNames] and Dart reserved keywords.
  UniqueNamer(Set<String> usedUpNames)
      : assert(keywords.intersection(usedUpNames).isEmpty),
        _usedUpNames = {...keywords, ...usedUpNames};

  /// Creates a UniqueNamer with given [usedUpNames] only.
  UniqueNamer._raw(this._usedUpNames);

  /// Returns a unique name by appending `<int>` to it if necessary.
  ///
  /// Adds the resulting name to the used names by default.
  String makeUnique(String name, [bool addToUsedUpNames = true]) {
    var crName = name;
    var i = 1;
    while (_usedUpNames.contains(crName)) {
      crName = '$name$i';
      i++;
    }
    if (addToUsedUpNames) {
      _usedUpNames.add(crName);
    }
    return crName;
  }

  /// Adds a name to used names.
  ///
  /// Note: [makeUnique] also adds the name by default.
  void markUsed(String name) {
    _usedUpNames.add(name);
  }

  /// Returns true if a name has been used before.
  bool isUsed(String name) {
    return _usedUpNames.contains(name);
  }

  /// Returns true if a name has not been used before.
  bool isUnique(String name) {
    return !_usedUpNames.contains(name);
  }

  UniqueNamer clone() => UniqueNamer._raw({..._usedUpNames});
}

/// Converts [text] to a dart doc comment(`///`).
///
/// Comment is split on new lines only.
String makeDartDoc(String text) {
  final s = StringBuffer();
  s.write('/// ');
  s.writeAll(text.split('\n'), '\n/// ');
  s.write('\n');

  return s.toString();
}

/// Converts [text] to a dart comment (`//`).
///
/// Comment is split on new lines only.
String makeDoc(String text) {
  final s = StringBuffer();
  s.write('// ');
  s.writeAll(text.split('\n'), '\n// ');
  s.write('\n');

  return s.toString();
}

class YamlWriter {
  final String indent;

  YamlWriter({this.indent = '  '});

  /// Writes [obj] as YAML.
  String write(dynamic obj) {
    final sb = StringBuffer();
    _write(obj, sb);
    return sb.toString();
  }

  bool _write(dynamic obj, StringBuffer sb, {String curIndent = ''}) {
    if (obj is List) {
      return _writeList(obj, sb, curIndent: curIndent);
    } else if (obj is Map) {
      return _writeMap(obj, sb, curIndent: curIndent);
    } else if (obj is String) {
      return _writeString(obj, sb, curIndent: curIndent);
    } else {
      sb.write(obj);
      return false;
    }
  }

  bool _writeString(String obj, StringBuffer sb, {String curIndent = ''}) {
    sb.write(' "${obj.replaceAll('"', r'\"')}"');
    return false;
  }

  bool _writeList(List obj, StringBuffer sb, {String curIndent = ''}) {
    if (obj.isEmpty) {
      sb.write('[]');
      return false;
    }
    sb.write('\n');

    var wroteLineBreak = false;

    for (final item in obj) {
      sb.write('$curIndent- ');
      final line = _write(item, sb, curIndent: curIndent + indent);
      if (!line) {
        sb.write('\n');
        wroteLineBreak = true;
      }
    }

    return wroteLineBreak;
  }

  bool _writeMap(Map obj, StringBuffer sb, {String curIndent = ''}) {
    if (sb.isNotEmpty) {
      sb.write('\n');
    }
    var wroteLineBreak = false;

    for (final entry in obj.entries) {
      sb.write("$curIndent${entry.key}:");
      final line = _write(entry.value, sb, curIndent: curIndent + indent);
      if (!line) {
        sb.write('\n');
        wroteLineBreak = true;
      }
    }

    return wroteLineBreak;
  }
}
