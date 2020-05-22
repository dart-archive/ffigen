/// Container for all temp data needed by parser
///
/// This container is needed by visitors as they are top level functions 
/// called from C code and have fixed input arguments and return value
import 'package:ffigen/src/code_generator.dart';
import 'package:ffigen/src/config_provider.dart';

/// Holds configurations
Config config;

/// final bindings
List<Binding> bindings = <Binding>[];

/// Temporarily holds a function
Func func;

/// Temporarily holds a typestring (used by typedeclaration visitor)
String typeString;
