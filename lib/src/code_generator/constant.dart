import 'package:meta/meta.dart';

import 'binding.dart';
import 'binding_string.dart';
import 'type.dart';
import 'writer.dart';

/// A simple Constant
/// ```dart 
/// const int name = 10;
/// ```
/// rawValue is pasted as it is, so make sure to add quotes 
/// for a string constant
class Constant extends Binding {
  final Type type;
  final String rawValue;

  const Constant({
    @required String name,
    String dartDoc,
    @required this.type,
    @required this.rawValue,
  }) : super(name: name, dartDoc: dartDoc);

  @override
  BindingString toBindingString(Writer w) {
    final s = StringBuffer();

    if (dartDoc != null) {
      s.write('/// ');
      s.writeAll(dartDoc.split('\n'), '\n/// ');
      s.write('\n');
    }

    s.write('const ${type.getDartType(w)} $name = $rawValue;\n\n');

    return BindingString(type: BindingStringType.constant, string: s.toString());
  }
}
