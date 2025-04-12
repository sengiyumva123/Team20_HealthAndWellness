import numpy as np
from scipy.io import wavfile
import os
import time
from typing import Optional
from dataclasses import dataclass

@dataclass
class SoundConfig:
    sample_rate: int = 44100
    duration: float = 10.0
    max_amplitude: int = 32767  # For 16-bit audio

class SoundscapeGenerator:
    def __init__(self, config: Optional[SoundConfig] = None):
        self.config = config or SoundConfig()
        self.sound_lib = {
            "falling": self._generate_wind,
            "water": self._generate_water,
            "flying": self._generate_whoosh,
            "default": self._generate_wind
        }
        os.makedirs("soundscapes", exist_ok=True)
    
    def generate(self, text: str) -> str:
        """Generate soundscape from dream text with timestamped filename"""
        archetype = self._detect_archetype(text)
        sound_fn = self.sound_lib.get(archetype, self.sound_lib["default"])
        samples = sound_fn()
        
        filename = f"{int(time.time())}_{archetype}.wav"
        wavfile.write(
            f"soundscapes/{filename}",
            self.config.sample_rate,
            samples
        )
        return filename
    
    def _detect_archetype(self, text: str) -> str:
        """Detect sound archetype from text with improved matching"""
        text = text.lower()
        water_words = {"water", "ocean", "sea", "river", "wave"}
        flying_words = {"fly", "air", "sky", "wing", "float"}
        
        if any(word in text for word in water_words):
            return "water"
        if any(word in text for word in flying_words):
            return "flying"
        return "falling"
    
    def _generate_wind(self) -> np.ndarray:
        """Generate wind-like sound with exponential decay"""
        t = np.linspace(0, self.config.duration, int(self.config.sample_rate * self.config.duration))
        return np.int16(
            self.config.max_amplitude * 0.1 *  # Reduced amplitude for wind
            np.sin(2 * np.pi * 100 * t) * 
            np.exp(-0.1 * t)
    
    def _generate_water(self) -> np.ndarray:
        """Generate water-like sound with pink noise characteristics"""
        samples = int(self.config.sample_rate * self.config.duration)
        # Pink noise (1/f noise) approximation
        white = np.random.randn(samples)
        b = [0.049922035, -0.095993537, 0.050612699, -0.004408786]
        a = [1, -2.494956002, 2.017265875, -0.522189400]
        pink = np.convolve(white, b, mode='same') / np.convolve(np.ones_like(white), a, mode='same')
        return np.int16(self.config.max_amplitude * 0.05 * pink)
    
    def _generate_whoosh(self) -> np.ndarray:
        """Generate whooshing sound with frequency sweep"""
        t = np.linspace(0, self.config.duration, int(self.config.sample_rate * self.config.duration))
        return np.int16(
            self.config.max_amplitude * 0.15 *  # Reduced amplitude
            np.sin(2 * np.pi * (200 + 50 * t) * t))