# Linear Predictive Speech Synthesizer

Author: Tega Orogun


# Project Overview

This project demonstrates a digital signal processing approach to analyze, model, and synthesize human speech using Linear Predictive Coding (LPC). By modeling speech as a source-filter process, this synthesizer generates vowel sounds based on fundamental frequency and formant frequencies of the input signal.

# Objectives

1. Analyze the speech signal, focusing on its fundamental frequency and formant frequencies.

2. Use LPC to create a filter model that simulates the human vocal tract.

3. Generate a synthesized speech signal using an impulse train convolved with the LPC filter.

# Key Features

- LPC-Based Speech Synthesis: Uses LPC coefficients to replicate vowel formants, producing a synthetic speech signal that mimics natural vowel sounds.
- MATLAB Implementation: Leverages MATLAB for efficient computation of LPC coefficients, fundamental frequency, and synthesis.
- Adjustable LPC Order and Segment Lengths: Evaluate speech quality by varying LPC orders and segment lengths, achieving optimal synthesis quality.

# Methodology

1. Signal Analysis:

  - Fundamental Frequency: Calculated using MATLAB’s autocorrelation() function, which identifies the pitch period.
  - Formant Frequencies: Estimated by analyzing the spectral envelope obtained through LPC, using the findpeaks() function to detect frequency peaks.

2. Signal Modeling:

  - LPC coefficients are computed with MATLAB’s lpc() function, varying the order to observe changes in signal quality and formant accuracy.
  - Fourier transform and freqz() function are used to obtain the spectral envelope, which visualizes formant frequencies.

3. Signal Synthesis:

  - Generates an impulse train based on the mean fundamental frequency.
  - Convolves the impulse train with the LPC filter using the filter() function, producing a synthesized speech output.

4. Experimentation:

  - Synthesized signal quality is evaluated by varying the LPC order and analyzing the effect on the formants.
  - Segment length adjustments are also explored, observing their impact on fundamental frequency and formant stability.
