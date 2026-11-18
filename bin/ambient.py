#!/usr/bin/env python3
"""Procedural rain and soft piano-like melodies. Requires Python 3 and mpv."""

import argparse
import math
import random
import struct
import subprocess


RATE = 24000
CHUNK = 2048
PEAK = 0.12  # Hard ceiling, about -18 dBFS; start with headphone volume low anyway.
NOTES = (293.66, 349.23, 392.00, 440.00, 523.25, 587.33)  # D minor pentatonic
PHRASES = ((0, 2, 3, 2, 1, 0), (2, 4, 3, 1, 2, 0), (1, 3, 4, 2, 1))


class Voice:
    def __init__(self, frequency, decay):
        self.phase = 0.0
        self.step = 2 * math.pi * frequency / RATE
        self.level = 1.0
        self.decay = math.exp(-1 / (RATE * decay))
        self.age = 0

    def sample(self):
        attack = min(1.0, self.age / (RATE * 0.008))
        sound = math.sin(self.phase) + self.level * (
            0.3 * math.sin(2.004 * self.phase) + 0.12 * math.sin(3.01 * self.phase)
        )
        sound *= self.level * attack * 0.0045
        self.phase += self.step
        self.level *= self.decay
        self.age += 1
        return sound


class Drop:
    def __init__(self, rng):
        self.level = rng.uniform(0.0015, 0.0035)
        self.decay = math.exp(-1 / (RATE * rng.uniform(0.05, 0.1)))
        self.rng = random.Random(rng.getrandbits(64))
        self.low = 0.0
        self.age = 0

    def sample(self):
        noise = 2 * self.rng.random() - 1
        self.low = 0.72 * self.low + 0.28 * noise
        sound = self.low * self.level * min(1.0, self.age / (RATE * 0.016))
        self.level *= self.decay
        self.age += 1
        return sound


def audio_chunks(seed, drops_enabled=True):
    rain_rng = random.Random(seed)
    music_rng = random.Random(seed + 1)
    voices = []
    drops = []
    low = 0.0
    soft = 0.0
    bright = 0.0
    swell = target = 0.5
    next_swell = 0
    next_note = 2 * RATE
    phrase = ()
    phrase_index = 0
    position = 0

    while True:
        samples = []
        for _ in range(CHUNK):
            if position >= next_swell:
                target = rain_rng.random()
                next_swell = position + int(rain_rng.uniform(6, 16) * RATE)
            if position >= next_note:
                if phrase_index == len(phrase):
                    phrase = music_rng.choice(PHRASES)
                    phrase_index = 0
                note = phrase[phrase_index]
                voices.append(Voice(NOTES[note], music_rng.uniform(1.8, 3.2)))
                if phrase_index == 0 or phrase_index == len(phrase) - 1:
                    voices.append(Voice(NOTES[0] / 2, 4))
                phrase_index += 1
                delay = music_rng.uniform(0.8, 1.5)
                if phrase_index == len(phrase):
                    delay += music_rng.uniform(2, 4)
                next_note = position + int(delay * RATE)

            swell += (target - swell) / (RATE * 3)
            noise = 2 * rain_rng.random() - 1
            if len(drops) < 24 and rain_rng.random() < (14 + 28 * swell) / RATE:
                drops.append(Drop(rain_rng))
            low = 0.88 * low + 0.12 * noise
            soft = 0.9 * soft + 0.1 * low
            bright = 0.45 * bright + 0.55 * noise
            rain = (1.6 * low + 0.45 * soft + 0.35 * (bright - low)) * (0.005 + 0.006 * swell)
            patter = sum(drop.sample() for drop in drops)
            sound = rain + drops_enabled * patter + sum(voice.sample() for voice in voices)
            samples.append(int(max(-PEAK, min(PEAK, sound * 4)) * 32767))
            position += 1

        voices = [voice for voice in voices if voice.level > 0.002]
        drops = [drop for drop in drops if drop.level > 0.0001]
        yield struct.pack(f"<{CHUNK}h", *samples)


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--seed", type=int, default=42, help="repeat the same sequence (default: 42)")
    parser.add_argument("--no-drops", action="store_true", help="mute individual drops to isolate the sound")
    args = parser.parse_args()
    command = [
        "mpv", "--no-video", "--no-terminal", "--really-quiet",
        "--demuxer=rawaudio", "--demuxer-rawaudio-format=s16le",
        f"--demuxer-rawaudio-rate={RATE}", "--demuxer-rawaudio-channels=1", "-",
    ]
    try:
        player = subprocess.Popen(command, stdin=subprocess.PIPE)
    except FileNotFoundError:
        parser.exit(1, "ambient.py: mpv is required for playback\n")

    try:
        for chunk in audio_chunks(args.seed, not args.no_drops):
            player.stdin.write(chunk)
    except (BrokenPipeError, KeyboardInterrupt):
        pass
    finally:
        try:
            player.stdin.close()
        except BrokenPipeError:
            pass
        player.wait()


if __name__ == "__main__":
    main()
