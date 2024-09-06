%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%% READ IN SOUND SAMPLES AND DEFINE SEGMENT LENGTHS%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Male speech voice for hood_m
% MALE
% [y, fs] = audioread('hood_m.wav');

% Female speech voice for heed_f
% FEMALE
[y, fs] = audioread('heed_f.wav');

% Define the segment length (in seconds)
segment_length = 0.1; % 100ms

% Calculate the number of samples for the segment
segment_samples = round(segment_length * fs);

% Choose the starting point of the segment (you can change this as needed)
start_sample = 1;

%I use this variable to manipulate the length of the synthesized signal I
%play at the end 
desired_duration = 1; % in seconds


desired_samples = round(desired_duration * fs);

% Extract the 100ms segment from the speech signal
segment = y(start_sample:start_sample+segment_samples-1);

% Instead of using the pitch() function built-in I opt for the correlation
% function which I discussed in the report 
autocorr_segment = xcorr(segment);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%% SPECIFICATIONS FOR BOTH MALE AND FEMALE FREQUENCY ESTIMATIONS%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Define the expected F0 range (80-150 Hz) for male
% MALE
% min_male_f0 = 80;
% max_male_f0 = 150;

% FEMALE
%Define the expected F0 range (165-255 Hz) for female
min_female_f0 = 165;
max_female_f0 = 255;

% Calculate the lag values corresponding to the F0 range male
% MALE
% min_male_lag = round(fs / max_male_f0);
% max_male_lag = round(fs / min_male_f0);

% Calculate the lag values corresponding to the F0 range female
% FEMALE
min_female_lag = round(fs / max_female_f0);
max_female_lag = round(fs / min_female_lag);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%% FUNDAMENTAL FREQUENCY ESTIMATION%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Find peaks in the autocorrelation within the expected lag range
[peaks, locs] = findpeaks(autocorr_segment);

% Filter peaks within the expected lag range for male
% MALE
% expected_peaks_male = locs(locs >= min_male_lag & locs <= max_male_lag);

% FEMALE
% Filter peaks within the expected lag range for female
expected_peaks_female = locs(locs >= min_female_lag & locs <= max_female_lag);

% Calculate fundamental frequencies (F0) in Hz for male
% MALE
% fundamental_frequencies_male = fs ./ expected_peaks_male;

% FEMALE
% Calculate fundamental frequencies (F0) in Hz for female
fundamental_frequencies_female = fs ./ expected_peaks_female;

% Calculate the mean F0 for male
% MALE
% mean_male_f0 = mean(fundamental_frequencies_male);

% FEMALE
% Calculate the mean F0 for female
mean_female_f0 = mean(fundamental_frequencies_female);


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%% LINEAR PREDICTIVE CODING IMPLEMENTATION (THIS INCLUDES FINDING FORMANTS)%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Using LPC to estimate formant frequencies in both speech 
order = 70; % Change this to better fit the signal 
%The lpc coefficiencts are stored in the first variable in the vector. For
%now I am ignoring the second variable which is the prediction error
[lpc_coeffs, ~] = lpc(segment, order);
[response, norm_ang_freq] = freqz(1, lpc_coeffs, 2^nextpow2(length(segment)), fs);%with the freqz() function, I can plot the frequency response of the digital signal

% Find peaks in the LPC spectrum that correspond to formants
[pks, freq_locs] = findpeaks(abs(response));

% Select the first three peaks as the first three formants
% and ensure they are within the expected range for human speech formants
formant_freqs = norm_ang_freq(freq_locs);
valid_formants_idx = formant_freqs > 90 & formant_freqs < 8000; % This should be the estimated formant frequency for human speech
formant_frequencies = formant_freqs(valid_formants_idx);
formant_frequencies = sort(formant_frequencies(1:0), 'ascend'); % I sort the first 3 formants but plot five formants

fprintf('Formant Frequencies (1st-3rd):\n');
for i = 1:min(3, length(formant_frequencies))
    fprintf('Formant %d: %.2f Hz\n', i, formant_frequencies(i));
end
% Calculate the mean of the first three formant frequencies
mean_formants = mean(formant_frequencies(1:0));


%Print out both the mean of the fundamental frequencies and the mean
%formants (which might be unnecessary?)
% MALE
% fprintf('Mean F0: %.2f Hz\n', mean_male_f0);
% fprintf('Mean Formants (1st-3rd): %.2f Hz\n', mean_formants);

% FEMALE
fprintf('Mean F0: %.2f Hz\n', mean_female_f0);
fprintf('Mean Formants (1st-3rd): %.2f Hz\n', mean_formants);


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%% SIGNAL SYNTHESIS PROCESS%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% This is used to calculate the period of the impulse train used for the
% synthesised signal play at the end 

% MALE
% impulse_train_period = round(fs / mean_male_f0);  
% impulse_train = zeros(size(segment));
% impulse_train(1:impulse_train_period:end) = 1;

% FEMALE
% impulse_train_period = round(fs / mean_female_f0);  
% impulse_train = zeros(size(segment));
% impulse_train(1:impulse_train_period:end) = 1;

% FOR MALE
% impulse_train_period = round(fs / mean_male_f0);
% 
% % FOR FEMALE
impulse_train_period = round(fs / mean_female_f0);
% 
% 
% 
impulse_train_samples = min(desired_samples, impulse_train_period);
impulse_train = zeros(1, desired_samples);
impulse_train(1:impulse_train_samples:end) = 1;

synthesized_signal = filter(1, lpc_coeffs, impulse_train);

% Normalize the synthesized signal
synthesized_signal = synthesized_signal / max(abs(synthesized_signal));

% Play the signal 
sound(synthesized_signal,fs);

% MALE WRITE OUT
% path_male = fullfile('Speech_Main_Assignment', 'synthesized_speech_male.wav');
% audiowrite(path_male, synthesized_signal, fs);

% FEMALE WRITE OUT
% path_female = fullfile('Speech_Main_Assignment', 'synthesized_speech_female.wav');
% audiowrite(path_female, synthesized_signal, fs);

% Plot the signal's frequency domain representation
Y = fft(segment, length(response)); % Compute the FFT of the signal
f = (0:length(Y)-1) * fs / length(Y); % Frequency vector

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%% PLOTTING ALL THE GRAPHS %%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%This is where I start with all the graph plots for the spectrum and the
%spectral envelope. 
figure;
subplot(2,1,1);
plot(f, 20*log10(abs(Y)));
title('Frequency domain representation of the signal');
xlabel('Frequency (Hz)');
ylabel('Magnitude (dB)');
%this zooms in the plot to find the formants clearly 
xlim([0 max(formant_frequencies) + 1000]); 

% Plot the spectral envelope on the same graph
subplot(2,1,2);
plot(norm_ang_freq, 20*log10(abs(response)), 'r');
title('Spectral Envelope of the Signal');
xlabel('Frequency (Hz)');
ylabel('Magnitude (dB)');
hold on;

for i = 1:length(formant_frequencies)
    freq_index = find(norm_ang_freq >= formant_frequencies(i), 1);
    plot(formant_frequencies(i), 20*log10(abs(response(freq_index))), 'x');
end
title('Spectral Envelope with Formant Frequencies');
xlabel('Frequency (Hz)');
ylabel('Magnitude (dB)');

% Mark the formant frequencies on the spectral envelope. I tried using 'x'
% as a marker but this wasn't really visible
% plot(formant_frequencies, 20*log10(abs(h(freq_locs(valid_formants_idx)))), 'x');

%GRAPHS
figure;
plot(f, 20*log10(abs(Y(1:length(f)))), 'k'); 
hold on;
plot(norm_ang_freq, 20*log10(abs(response)), 'r', 'LineWidth', 1.5); 
title('Frequency Domain Representation and LPC Spectral Envelope. Order = 26 Segment Length: 170ms');
xlabel('Frequency (Hz)');
ylabel('Magnitude (dB)');

% Mark the formant frequencies on the plot. Use pretty big green circles
% because it wasn't very clear with x on the same plot as the signal
% spectrum 
for i = 1:length(formant_frequencies)
    freq_index = find(norm_ang_freq >= formant_frequencies(i), 1);
    plot(formant_frequencies(i), 20*log10(abs(response(freq_index))), 'go', 'MarkerSize', 8, 'MarkerFaceColor', 'g');
end

% Spectograms
legend('Signal Spectrum', 'LPC Spectral Envelope', 'Formant Frequencies');
hold off;

figure;
subplot(2,1,1);
spectrogram(segment, 256, 250, 256, fs, 'yaxis');
title('Spectrogram of the Original Signal Segment');
xlabel('Time (s)');
ylabel('Frequency (Hz)');

% Plot the spectrogram of the synthesized signal
subplot(2,1,2);
spectrogram(synthesized_signal, 256, 250, 256, fs, 'yaxis');
title('Spectrogram of the Synthesized Signal');
xlabel('Time (s)');
ylabel('Frequency (Hz)');

% sound(y,fs);