This is a test to see how a browser reacts to `SourceBuffer.appendBuffer()` with media that overlaps the `currentTime`.

https://ntrrgc.github.io/mse-repro-append-overwriting-currentTime/

The video assets are specifically crafted so that catching up during a flush is slow enough to be noticeable even when running the test on a desktop computer.

## "Need to rewind" edge case

Additionally, this tests what happens when the second append's only GOP extends beyond the duration of the old appends.

https://ntrrgc.github.io/mse-repro-append-overwriting-currentTime/need-rewind.html