# zig-synth
An audio synthesizer in Zig

### Roadmap
- Sound
    - [ ] Polyphony
        - [x] Basic polyphony
        - [x] Voice stealing
        - [ ] Apply parameter updates across all voices
    - [ ] Unison
        - An efficient way to implement Unison could be to have multiple scanners per oscillator,
          where each one has a slightly offset step size. However, I need to look into that first.
    - [ ] Modulation
        - Modulation Matrix (?)
            - With Zigs comptime abilities it seems like there is a performant, but still very
              dynamic implementation for this.
        - Because you cannot have threads in WebAssembly, I will probably have to create a separate instance
          on the UI thread, where I calculate the modulated values and then send those to the audio worklet.
    - [ ] Filter

- Tech
    - [ ] Windows (WASAPI) Support
    - [ ] Linux Support (I will need to look into possible APIs first)
    - [ ] Build as VST. I don't really know how VSTs work, but from what I read it seems like it's just a shared library
          with a set of defined exports.
    - [ ] User Interface
        - I plan on having multiple render backends, like:
            - [ ] Metal on macOS. When this is finished I don't see a problem with getting the whole thing to run on iOS either.
            - [ ] DirectX / OpenGL on Windows
            - [ ] WebGL in the browser. This is what I will target first, because it's the most approachable one for me..
                  I will need to workout a proper API anyways. Maybe even a DOM-backed UI will work for that.

### Building
First of all `git clone https://github.com/schroffl/zig-synth` this repository and run `zig build` in it.

- The standalone version only runs on macOS for now. To start it execute `zig build run` in the cloned git repo.
  If you have a MIDI input device, you can go into `src/host/macos.zig` and set the proper `midi_hint` value.

- The single-file browser build can be found in `zig-cache/bin/zig-synth.html`.
  Sadly, this only works in Chrome at the time of writing. Firefox et al. haven't implemented the
  Audio Worklet API yet. Ironically, since Microsoft Edge now uses Chromium it probably runs there too.

### Useful Resources
A list of useful resources that I find during development:

 * [EarLevel Engineering by Nigel Redmon](https://www.earlevel.com/main/), specifically the [wavetable oscillator series](https://www.earlevel.com/main/2012/05/03/a-wavetable-oscillator%e2%80%94introduction/)
 * [Using Objective-C from js-ctypes](https://developer.mozilla.org/en-US/docs/Mozilla/js-ctypes/Examples/Using_Objective-C_from_js-ctypes)
 * [Bandlimited oscillators](https://hackaday.io/project/157580-hgsynth/log/145886-bandlimited-oscillators)
 * [Sound Synthesis Theory/Oscillators and Wavetables](https://en.wikibooks.org/wiki/Sound_Synthesis_Theory/Oscillators_and_Wavetables)
 * [The New Wave: An In-Depth Look At Live 10's Wavetable](https://www.ableton.com/en/blog/new-wave-depth-look-wavetable/)
 * Basically every article on Aliasing, Sample Rates, Band-Limiting, Fourier Transforms and related math (Take a look at 3Blue1Brown on YouTube)
