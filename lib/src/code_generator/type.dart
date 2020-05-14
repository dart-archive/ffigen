import 'constants.dart';

/// Type class for return types, variable types, etc
class Type {
  static const _primitives = <String, _SubType>{
    'char': _SubType(c: 'Uint8', dart: 'int'),
    'int8': _SubType(c: 'Int8', dart: 'int'),
    'int16': _SubType(c: 'Int16', dart: 'int'),
    'int32': _SubType(c: 'Int32', dart: 'int'),
    'int64': _SubType(c: 'Int64', dart: 'int'),
    'uint8': _SubType(c: 'Uint8', dart: 'int'),
    'uint16': _SubType(c: 'Uint16', dart: 'int'),
    'uint32': _SubType(c: 'Uint32', dart: 'int'),
    'uint64': _SubType(c: 'Uint64', dart: 'int'),
    'float': _SubType(c: 'Float', dart: 'double'),
    'float32': _SubType(c: 'Float', dart: 'double'),
    'float64': _SubType(c: 'Double', dart: 'double'),
    'double': _SubType(c: 'Double', dart: 'double'),
  };

  final String type;

  const Type(this.type);

  bool get isPrimitive => _primitives.containsKey(type);

  String get cType {
    var s = _primitives[type];

    if (s != null) {
      // for primitives
      return '$ffiLibraryPrefix.${s.c}';
    } else if (type[0] == '*') {
      // for pointers
      return _getPointerType(type);
    } else {
      // for structs
      return type;
    }
  }

  String _getPointerType(String t) {
    if (t[0] == '*') {
      return '$ffiLibraryPrefix.Pointer<${_getPointerType(t.substring(1))}>';
    } else {
      var s = _primitives[t];
      if (s != null) {
        // for primitives
        return '$ffiLibraryPrefix.${s.c}';
      } else {
        // for structs
        return t;
      }
    }
  }

  String get dartType {
    var s = _primitives[type];

    if (s != null) {
      return s.dart;
    } else if (type[0]=='*') {
      // for pointers
      return _getPointerType(type);
    } else {
      // for structs
      return type;
    }
  }
}

class _SubType {
  final String c;
  final String dart;

  const _SubType({this.c, this.dart});
}
