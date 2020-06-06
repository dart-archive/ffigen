import 'package:meta/meta.dart';

import 'binding.dart';
import 'binding_string.dart';
import 'constants.dart';
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

    // write class declaration
    s.write('class $name extends ${ffiLibraryPrefix}.Struct{\n');
    for (var m in members) {
      if (m.type.isPrimitive) {
        s.write('  @${m.type.cType}()\n');
      }
      s.write('  ${m.type.dartType} ${m.name};\n\n');
    }
    s.write('}\n\n');

    return BindingString(type: BindingStringType.func, string: s.toString());
  }
}

class Member {
  final String name;
  final Type type;

  const Member({this.name, this.type});
}
