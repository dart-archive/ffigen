import 'constants.dart';

/// Type class for return types, variable types, etc
class Type {
  static const _cTypes = <String, _SubType>{
    'char': _SubType(c: '$ffiLibraryPrefix.Uint8', dart: 'int'),
    'int8': _SubType(c: '$ffiLibraryPrefix.Int8', dart: 'int'),
    'int16': _SubType(c: '$ffiLibraryPrefix.Int16', dart: 'int'),
    'int32': _SubType(c: '$ffiLibraryPrefix.Int32', dart: 'int'),
    'int64': _SubType(c: '$ffiLibraryPrefix.Int64', dart: 'int'),
    'uint8': _SubType(c: '$ffiLibraryPrefix.Uint8', dart: 'int'),
    'uint16': _SubType(c: '$ffiLibraryPrefix.Uint16', dart: 'int'),
    'uint32': _SubType(c: '$ffiLibraryPrefix.Uint32', dart: 'int'),
    'uint64': _SubType(c: '$ffiLibraryPrefix.Uint64', dart: 'int'),
    'float': _SubType(c: '$ffiLibraryPrefix.Float', dart: 'double'),
    'float32': _SubType(c: '$ffiLibraryPrefix.Float', dart: 'double'),
    'float64': _SubType(c: '$ffiLibraryPrefix.Double', dart: 'double'),
    'double': _SubType(c: '$ffiLibraryPrefix.Double', dart: 'double'),
  };

  final String type;

  const Type(this.type);

  String toCType() {
    var s = _cTypes[type];

    if (s != null) {
      return s.c;
    } else {
      // TODO: implement all C types
      throw UnimplementedError('type $s not implemented');
    }
  }

  String toDartType() {
    var s = _cTypes[type];

    if (s != null) {
      return s.dart;
    } else {
      // TODO: implement all dart types
      throw UnimplementedError('type $s not implemented');
    }
  }
}

class _SubType {
  final String c;
  final String dart;

  const _SubType({this.c, this.dart});
}
