# Objective C example

This example shows how to use ffigen to generate bindings for an Objective C
library. It uses the AVFAudio framework to play audio files.

```
dart play_audio.dart test.mp3
```

## Config notes

The ffigen config for an Objective C library looks very similar to a C library.
The most important difference is that you must set `language: objc`. If you want
to filter which interfaces are included you can use the `objc-interfaces:`
option. This works similarly to the other filtering options.

It is recommended that you filter out just about everything you're not
interested in binding (see the ffigen config in [pubspec.yaml](./pubspec.yaml)).
Virtually all Objective C libraries depend on Apple's internal libraries, which
are huge. Filtering can reduce the generated bindings from millions of lines to
tens of thousands. You can use the `exclude-all-by-default` flag, or exclude
individual sets of declarations like this:

```yaml
functions:
  exclude:
    - '.*'
# Same for structs/unions/enums etc.
```

In this example, we're only interested in `AVAudioPlayer`, so we've filtered out
everything else. But ffigen will automatically pull in anything referenced by
any of the fields or methods of `AVAudioPlayer`, so we're still able to use
`NSURL` etc to load our audio file.

## Generating bindings

At the root of this example (`example/objective_c`), run:

```
dart run ffigen --config config.yaml
```

This will generate [avf_audio_bindings.dart](./avf_audio_bindings.dart).
