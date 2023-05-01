# Natives example

A simple example generating `Native` bindings for a very small header file (`headers/example.h`).

## Generating bindings
At the root of this example (`example/simple`), run -
```
dart run ffigen --config config.yaml
```
This will generate bindings in a file: [generated_bindings.dart](./generated_bindings.dart).
