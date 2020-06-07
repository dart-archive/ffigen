import 'package:meta/meta.dart';

import 'binding.dart';
import 'binding_string.dart';
import 'type.dart';
import 'writer.dart';

/// A binding to a global variable
class Global extends Binding {
  final Type type;

  const Global({
    @required String name,
    @required this.type,
    String dartDoc,
  }) : super(name: name, dartDoc: dartDoc);

  @override
  BindingString toBindingString(Writer w) {
    final s = StringBuffer();

    if (dartDoc != null) {
      s.write('/// ');
      s.writeAll(dartDoc.split('\n'), '\n/// ');
      s.write('\n');
    }

    s.write(
        "final ${type.getDartType(w)} $name = ${w.dylibIdentifier}.lookup<${type.getCType(w)}>('$name').value;\n\n");

    return BindingString(type: BindingStringType.global, string: s.toString());
  }
}
