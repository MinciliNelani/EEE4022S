% Load the data from an Excel file
data = readtable('NotFaultyvsFaulty.xlsx');  % Replace with your actual file name

% Convert table to matrix if needed
data = table2array(data);

% Separate columns for "not faulty" and "faulty" conditions
speed_not_faulty = abs(data(:, 1));  % Convert negative speed to positive
torque_not_faulty = data(:, 2);

speed_faulty = abs(data(:, 3));  % Interturn faulty condition
torque_faulty = data(:, 4);

% Filter out negative torque values for both cases
torque_not_faulty(torque_not_faulty < 0) = 0;
torque_faulty(torque_faulty < 0) = 0;

% Apply Savitzky-Golay filter for smoother results for both cases
windowSize = 31;  % Must be an odd number
polynomialOrder = 3;  % Adjust as needed for fitting
smoothedTorque_not_faulty = sgolayfilt(torque_not_faulty, polynomialOrder, windowSize);
smoothedTorque_faulty = sgolayfilt(torque_faulty, polynomialOrder, windowSize);

% Remove duplicate speed values and corresponding torque values for both cases
[speed_not_faulty_unique, unique_idx_not_faulty] = unique(speed_not_faulty);
smoothedTorque_not_faulty_unique = smoothedTorque_not_faulty(unique_idx_not_faulty);

[speed_faulty_unique, unique_idx_faulty] = unique(speed_faulty);
smoothedTorque_faulty_unique = smoothedTorque_faulty(unique_idx_faulty);

% Create the plot
figure;
hold on;

% Interpolate for a smooth line for both cases
speed_not_faulty_interp = linspace(min(speed_not_faulty_unique), max(speed_not_faulty_unique), 500);
torque_not_faulty_interp = interp1(speed_not_faulty_unique, smoothedTorque_not_faulty_unique, speed_not_faulty_interp, 'pchip');

speed_faulty_interp = linspace(min(speed_faulty_unique), max(speed_faulty_unique), 500);
torque_faulty_interp = interp1(speed_faulty_unique, smoothedTorque_faulty_unique, speed_faulty_interp, 'pchip');

% Plot the interpolated data
plot(speed_not_faulty_interp, torque_not_faulty_interp, 'b-', 'DisplayName', 'Not Faulty');
plot(speed_faulty_interp, torque_faulty_interp, 'r--', 'DisplayName', 'Faulty');

% Customize the plot
xlabel('Speed (RPM)');
ylabel('Torque (Nm)');
title('Smoothed Torque vs. Speed for Not Faulty and Faulty Conditions');
legend('show');
grid on;

% Adjust axis limits for better visibility
xlim([0, max([speed_not_faulty; speed_faulty]) * 1.1]);
ylim([0, max([smoothedTorque_not_faulty; smoothedTorque_faulty]) * 1.1]);

hold off;
