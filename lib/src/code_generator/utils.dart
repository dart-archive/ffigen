import 'dart_keywords.dart';

class UniqueNamer {
  final Set<String> _usedUpNames;

  /// Creates a UniqueNamer with given [usedUpNames] and Dart reserved keywords.
  UniqueNamer(Set<String> usedUpNames)
      : assert(keywords.intersection(usedUpNames).isEmpty),
        _usedUpNames = {...keywords, ...usedUpNames};

  /// Creates a UniqueNamer with given [usedUpNames] only.
  UniqueNamer._raw(this._usedUpNames);

  /// Returns a unique name by appending `_<int>` to it if necessary.
  ///
  /// Adds the resulting name to the used names by default.
  String makeUnique(String name, [bool addToUsedUpNames = true]) {
    var cr_name = name;
    var i = 1;
    while (_usedUpNames.contains(cr_name)) {
      cr_name = '${name}_$i';
      i++;
    }
    if (addToUsedUpNames) {
      _usedUpNames.add(cr_name);
    }
    return cr_name;
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
