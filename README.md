This is a test to see how a browser reacts to `SourceBuffer.appendBuffer()` with media that overlaps the `currentTime`.

The video assets are specifically crafted so that catching up during a flush is slow enough to be noticeable even when running the test on a desktop computer.