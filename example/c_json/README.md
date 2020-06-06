# cJson example

Demonstrates generation of bindings for a C library called 
[cJson](https://github.com/DaveGamble/cJSON) and then using these bindings 
to parse some json.

## Building the cJson dynamic library
```
cd ./example/c_json/cjson_library
cmake .
make
```

## Generating bindings
```
pub run ffigen:generate
```
This will generate bindings in a file: [cjson_generated_bindings.dart](./cjson_generated_bindings.dart)

## Running the example
```
dart main.dart
```