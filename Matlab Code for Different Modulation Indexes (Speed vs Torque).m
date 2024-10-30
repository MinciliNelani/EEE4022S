% Load the data from an Excel file
data = readtable('modulation index.xlsx');  % Replace with your actual file name

% Convert table to matrix if needed
data = table2array(data);

% Separate columns by modulation index
speed1 = abs(data(:, 1));  % Convert negative speed to positive
torque1 = data(:, 2);
speed2 = abs(data(:, 3));
torque2 = data(:, 4);
speed3 = abs(data(:, 5));
torque3 = data(:, 6);

% Filter out negative torque values
torque1(torque1 < 0) = 0;
torque2(torque2 < 0) = 0;
torque3(torque3 < 0) = 0;

% Apply Savitzky-Golay filter for smoother results
windowSize = 31;  % Must be an odd number
polynomialOrder = 3;  % Adjust as needed for fitting
smoothedTorque1 = sgolayfilt(torque1, polynomialOrder, windowSize);
smoothedTorque2 = sgolayfilt(torque2, polynomialOrder, windowSize);
smoothedTorque3 = sgolayfilt(torque3, polynomialOrder, windowSize);

% Remove duplicate speed values and corresponding torque values
[speed1_unique, unique_idx1] = unique(speed1);
smoothedTorque1_unique = smoothedTorque1(unique_idx1);

[speed2_unique, unique_idx2] = unique(speed2);
smoothedTorque2_unique = smoothedTorque2(unique_idx2);

[speed3_unique, unique_idx3] = unique(speed3);
smoothedTorque3_unique = smoothedTorque3(unique_idx3);

% Create the plot
figure;
hold on;

% Interpolate for a smooth line
speed1_interp = linspace(min(speed1_unique), max(speed1_unique), 500);
torque1_interp = interp1(speed1_unique, smoothedTorque1_unique, speed1_interp, 'pchip');

speed2_interp = linspace(min(speed2_unique), max(speed2_unique), 500);
torque2_interp = interp1(speed2_unique, smoothedTorque2_unique, speed2_interp, 'pchip');

speed3_interp = linspace(min(speed3_unique), max(speed3_unique), 500);
torque3_interp = interp1(speed3_unique, smoothedTorque3_unique, speed3_interp, 'pchip');

% Plot the interpolated data
plot(speed1_interp, torque1_interp, 'r-', 'DisplayName', 'Modulation Index = 0.75');
plot(speed2_interp, torque2_interp, 'g-', 'DisplayName', 'Modulation Index = 0.9');
plot(speed3_interp, torque3_interp, 'b-', 'DisplayName', 'Modulation Index = 1');

% Customize the plot
xlabel('Speed (RPM)');
ylabel('Torque (Nm)');
title('Smoothed Torque vs. Speed for Different Modulation Indices');
legend('show');
grid on;

% Adjust axis limits for better visibility
xlim([0, max([speed1; speed2; speed3]) * 1.1]);
ylim([0, max([smoothedTorque1; smoothedTorque2; smoothedTorque3]) * 1.1]);

hold off;
