This folder contains visitor functions which are called from C function
clang_visitChildren_wrap.
Error handling must be done by
Wrapping the function body with try catch block, printing exception and stacktrace
and then rethrowing the exception, which are cascaded to halt the program