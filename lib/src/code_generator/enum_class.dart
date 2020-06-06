import 'package:meta/meta.dart';

import 'binding.dart';
import 'binding_string.dart';
import 'writer.dart';

/// A binding for enums in C
class EnumClass extends Binding {
  final List<EnumConstant> enumConstants;

  EnumClass({
    @required String name,
    String dartDoc,
    List<EnumConstant> enumConstants,
  })  : enumConstants = enumConstants ?? [],
        super(name: name, dartDoc: dartDoc);

  @override
  BindingString toBindingString(Writer w) {
    final s = StringBuffer();

    if (dartDoc != null) {
      s.write('/// ');
      s.writeAll(dartDoc.split('\n'), '\n/// ');
      s.write('\n');
    }

    // print enclosing class
    s.write('class $name {\n');
    var depth = '  ';
    for (var ec in enumConstants) {
      if (ec.dartDoc != null) {
        s.write(depth + '/// ');
        s.writeAll(ec.dartDoc.split('\n'), '\n' + depth + '/// ');
        s.write('\n');
      }
      s.write(depth + 'static const int ${ec.name} = ${ec.value};\n');
    }
    s.write('}\n\n');

    return BindingString(type: BindingStringType.func, string: s.toString());
  }
}

/// Represents a single value in an enum
class EnumConstant {
  final String dartDoc;
  final String name;
  final int value;
  const EnumConstant({@required this.name, @required this.value, this.dartDoc});
}
