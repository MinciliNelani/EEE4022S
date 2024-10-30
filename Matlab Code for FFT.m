data = readtable('fft2.xlsx');  % Replace 'datafile.xlsx' with your Excel filename
time = data{:,1};  % Assuming the first column is time
current = data{:,2};  % Assuming the second column is voltage
voltage = data{:,3};  % Assuming the third column is current
fs = 100002.4;  % Sampling frequency in Hz
fc = 1000;      % Set cutoff frequency to 1000 Hz (or adjust based on your needs)

% Normalize cutoff frequency to Nyquist frequency
Wn = fc / (fs / 2);

% Design a 4th-order low-pass Butterworth filter
[b, a] = butter(4, Wn, 'low');

% Apply filter to your voltage and current data
filtered_voltage = filtfilt(b, a, voltage);
filtered_current = filtfilt(b, a, current);

% Plot filtered voltage and current signals
subplot(2,1,1);
plot(time, filtered_voltage);
title('Filtered Voltage Signal');
xlabel('Time (s)');
ylabel('Voltage (V)');

subplot(2,1,2);
plot(time, filtered_current);
title('Filtered Current Signal');
xlabel('Time (s)');
ylabel('Current (A)');

% Extract current values greater than 0
filtered_current_above_0 = filtered_current(filtered_current > 0);
filtered_time_current = time(filtered_current > 0);  % Corresponding time values
% Extract voltage values between 150V and 250V
filtered_voltage_150_250 = filtered_voltage(filtered_voltage >= 150 & filtered_voltage <= 250);
filtered_time_voltage = time(filtered_voltage >= 150 & filtered_voltage <= 250);  % Corresponding time values
% Plot filtered current above 0
subplot(2,1,1);
plot(filtered_time_current, filtered_current_above_0);
title('Filtered Current Signal (Above 0)');
xlabel('Time (s)');
ylabel('Current (A)');

% Plot filtered voltage between 150V and 250V
subplot(2,1,2);
plot(filtered_time_voltage, filtered_voltage_150_250);
title('Filtered Voltage Signal (150V to 250V)');
xlabel('Time (s)');
ylabel('Voltage (V)');
L = length(filtered_voltage);  % Length of the signal
Y_voltage = fft(filtered_voltage);  % FFT of voltage
Y_current = fft(filtered_current);  % FFT of current

% Compute two-sided spectrum, then single-sided spectrum
P2_voltage = abs(Y_voltage/L);
P1_voltage = P2_voltage(1:L/2+1);
P1_voltage(2:end-1) = 2*P1_voltage(2:end-1);

P2_current = abs(Y_current/L);
P1_current = P2_current(1:L/2+1);
P1_current(2:end-1) = 2*P1_current(2:end-1);

% Frequency axis
f = (0:(L/2))/L * fs;

% Plot FFT results
figure;
subplot(2,1,1);
plot(f, P1_voltage);
title('FFT of Voltage Signal');
xlabel('Frequency (Hz)');
ylabel('Amplitude');

subplot(2,1,2);
plot(f, P1_current);
title('FFT of Current Signal');
xlabel('Frequency (Hz)');
ylabel('Amplitude');
