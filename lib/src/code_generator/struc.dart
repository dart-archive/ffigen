import 'package:meta/meta.dart';

import 'binding.dart';
import 'binding_string.dart';
import 'type.dart';
import 'writer.dart';

/// A binding for C function
class Struc extends Binding {
  final List<Member> members;

  Struc({
    @required String name,
    String dartDoc,
    List<Member> members,
  })  : members = members ?? [],
        super(name: name, dartDoc: dartDoc);

  @override
  BindingString toBindingString(Writer w) {
    final s = StringBuffer();

    if (dartDoc != null) {
      s.write('/// ');
      s.writeAll(dartDoc.split('\n'), '\n/// ');
      s.write('\n');
    }

    var helpers = <ArrayHelper>[];

    // write class declaration
    s.write('class $name extends ${w.ffiLibraryPrefix}.Struct{\n');
    for (var m in members) {
      if (m.type.type == BroadType.ConstantArray) {
        var arrayHelper = ArrayHelper(
          helperClassName: '_ArrayHelper_${name}_${m.name}',
          elementType: m.type.elementType,
          length: 3,
          // length: m.type.arrayLength,
          name: m.name,
          structName: name,
          elementNamePrefix: '_${m.name}_item_',
        );
        s.write(arrayHelper.declarationString(w));
        helpers.add(arrayHelper);
      } else {
        if (m.type.isPrimitive) {
          s.write('  @${m.type.getCType(w)}()\n');
        }
        s.write('  ${m.type.getDartType(w)} ${m.name};\n\n');
      }
    }
    s.write('}\n\n');

    for (var helper in helpers) {
      s.write(helper.helperClassString(w));
    }

    return BindingString(type: BindingStringType.struc, string: s.toString());
  }
}

class Member {
  final String name;
  final Type type;

  const Member({this.name, this.type});
}

// creates an Array helper binding for a Struct Array
class ArrayHelper {
  final Type elementType;
  final int length;
  final String structName;

  final String name;
  final String helperClassName;
  final String elementNamePrefix;

  ArrayHelper({
    @required this.elementType,
    @required this.length,
    @required this.structName,
    @required this.name,
    @required this.helperClassName,
    @required this.elementNamePrefix,
  });

  String declarationString(Writer w) {
    var s = StringBuffer();
    final arrayDartType = elementType.getDartType(w);
    final arrayCType = elementType.getCType(w);

    for (var i = 0; i < length; i++) {
      if (elementType.isPrimitive) {
        s.write('  @${arrayCType}()\n');
      }
      s.write('  ${arrayDartType} ${elementNamePrefix}$i;\n');
    }

    s.write('/// helper for array, supports `[]` operator\n');
    s.write(
        '$helperClassName get $name => ${helperClassName}(this, $length);\n');

    return s.toString();
  }

  String helperClassString(Writer w) {
    var s = StringBuffer();

    final arrayType = elementType.getDartType(w);

    s.write('/// Helper for array $name in struct $structName\n');

    // write class declaration
    s.write('class $helperClassName{\n');
    s.write('final $structName _struct;\n');
    s.write('final int length;\n');
    s.write('$helperClassName(this._struct, this.length);\n');

    // override []= operator
    s.write('void operator []=(int index, $arrayType value) {\n');
    s.write('switch(index) {\n');
    for (var i = 0; i < length; i++) {
      s.write('case $i:\n');
      s.write('  _struct.${elementNamePrefix}$i = value;\n');
      s.write('  break;\n');
    }
    s.write('default:\n');
    s.write(
        "  throw RangeError('Index \$index must be in the range [0..${length - 1}].');");
    s.write('}\n');
    s.write('}\n');

    // override [] operator
    s.write('$arrayType operator [](int index) {\n');
    s.write('switch(index) {\n');
    for (var i = 0; i < length; i++) {
      s.write('case $i:\n');
      s.write('  return _struct.${elementNamePrefix}$i;\n');
    }
    s.write('default:\n');
    s.write(
        "  throw RangeError('Index \$index must be in the range [0..${length - 1}].');");
    s.write('}\n');
    s.write('}\n');

    // override toString()
    s.write('@override\n');
    s.write('String toString() {\n');
    s.write("if (length == 0) return '[]';\n");
    s.write("var sb = StringBuffer('[');\n");
    s.write('sb.write(this[0]);\n');
    s.write('for (var i = 1; i < length; i++) {\n');
    s.write("  sb.write(',');\n");
    s.write('  sb.write(this[i]);');
    s.write('}\n');
    s.write("sb.write(']');");
    s.write('return sb.toString();\n');
    s.write('}\n');

    s.write('}\n\n');
    return s.toString();
  }
}
