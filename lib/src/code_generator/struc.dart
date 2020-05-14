import 'constants.dart';
import 'package:meta/meta.dart';

import 'writer.dart';
import 'binding.dart';
import 'binding_string.dart';
import 'type.dart';

/// A binding for C function
class Struc extends Binding {
  final List<Member> members;

  const Struc({
    @required String name,
    String dartDoc,
    this.members = const <Member>[],
  }) : super(name: name, dartDoc: dartDoc);

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
      s.write('  @${m.type.toCType()}()\n');
      s.write('  ${m.type.toDartType()} ${m.name};\n\n');
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
