# cJson example

Demonstrates generation of bindings for a C library called
[cJson](https://github.com/DaveGamble/cJSON) and then using these bindings
to parse some json.

## Building the cJson dynamic library
From the root of this repository -
```
cd third_party/cjson_library
cmake .
make
```

## Generating bindings
At the root of this example (`example/c_json`), run -
```
dart run ffigen
```
This will generate bindings in a file: [cjson_generated_bindings.dart](./cjson_generated_bindings.dart)

## Running the example
```
dart main.dart
```
