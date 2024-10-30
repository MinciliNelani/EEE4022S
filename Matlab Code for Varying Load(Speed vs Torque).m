% Load the data from an Excel file
data = readtable('LoadVary.xlsx');  % Replace with your actual file name

% Convert table to matrix if needed
data = table2array(data);

% Separate columns by load level
speed_no_load = abs(data(:, 1));  % Convert negative speed to positive
torque_no_load = data(:, 2);
speed_20_load = abs(data(:, 3));
torque_20_load = data(:, 4);
speed_full_load = abs(data(:, 5));
torque_full_load = data(:, 6);

% Filter out negative torque values
torque_no_load(torque_no_load < 0) = 0;
torque_20_load(torque_20_load < 0) = 0;
torque_full_load(torque_full_load < 0) = 0;

% Apply Savitzky-Golay filter for smoother results
windowSize = 31;  % Must be an odd number
polynomialOrder = 3;  % Adjust as needed for fitting
smoothedTorque_no_load = sgolayfilt(torque_no_load, polynomialOrder, windowSize);
smoothedTorque_20_load = sgolayfilt(torque_20_load, polynomialOrder, windowSize);
smoothedTorque_full_load = sgolayfilt(torque_full_load, polynomialOrder, windowSize);

% Remove duplicate speed values and corresponding torque values
[speed_no_load_unique, unique_idx1] = unique(speed_no_load);
smoothedTorque_no_load_unique = smoothedTorque_no_load(unique_idx1);

[speed_20_load_unique, unique_idx2] = unique(speed_20_load);
smoothedTorque_20_load_unique = smoothedTorque_20_load(unique_idx2);

[speed_full_load_unique, unique_idx3] = unique(speed_full_load);
smoothedTorque_full_load_unique = smoothedTorque_full_load(unique_idx3);

% Create the plot
figure;
hold on;

% Interpolate for a smooth line
speed_no_load_interp = linspace(min(speed_no_load_unique), max(speed_no_load_unique), 500);
torque_no_load_interp = interp1(speed_no_load_unique, smoothedTorque_no_load_unique, speed_no_load_interp, 'pchip');

speed_20_load_interp = linspace(min(speed_20_load_unique), max(speed_20_load_unique), 500);
torque_20_load_interp = interp1(speed_20_load_unique, smoothedTorque_20_load_unique, speed_20_load_interp, 'pchip');

speed_full_load_interp = linspace(min(speed_full_load_unique), max(speed_full_load_unique), 500);
torque_full_load_interp = interp1(speed_full_load_unique, smoothedTorque_full_load_unique, speed_full_load_interp, 'pchip');

% Plot the interpolated data
plot(speed_no_load_interp, torque_no_load_interp, 'b-', 'DisplayName', 'No Load');
plot(speed_20_load_interp, torque_20_load_interp, 'g-', 'DisplayName', '20% Load');
plot(speed_full_load_interp, torque_full_load_interp, 'r-', 'DisplayName', 'Full Load');

% Customize the plot
xlabel('Speed (RPM)');
ylabel('Torque (Nm)');
title('Smoothed Torque vs. Speed for Different Load Levels');
legend('show');
grid on;

% Adjust axis limits for better visibility
xlim([0, max([speed_no_load; speed_20_load; speed_full_load]) * 1.1]);
ylim([0, max([smoothedTorque_no_load; smoothedTorque_20_load; smoothedTorque_full_load]) * 1.1]);

hold off;
