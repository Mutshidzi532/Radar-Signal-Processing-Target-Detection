clc;
clear;
close all;
%% RADAR SIGNAL PROCESSING AND TARGET DETECTION
% Stage 1: Signal Generation
% Stage 2: Fast Fourier Transform (FFT)
% Author: Mutshidzi Madavha
disp('==============================================');
disp(' RADAR SIGNAL PROCESSING AND TARGET DETECTION');
disp('==============================================');
disp(' ');
%% STAGE 1: SIMULATED RADAR SIGNAL GENERATION
disp('Stage 1: Simulated Radar Signal Generation');
% 1. Define simulation parameters
fs = 1000;              % Sampling frequency (Hz)
T = 1;                  % Signal duration (seconds)
f_target = 50;          % Target signal frequency (Hz)
A_target = 1;            % Target signal amplitude
noise_std = 0.3;        % Noise standard deviation
% 2. Create the time vector
t = 0:1/fs:T-1/fs;
% 3. Generate the target signal
target_signal = A_target * sin(2*pi*f_target*t);
% 4. Generate random noise
rng(1);                 % Ensure reproducible results
noise = noise_std * randn(size(t));
% 5. Generate the received signal
received_signal = target_signal + noise;
% 6. Display simulation information
fprintf('Sampling frequency: %d Hz\n', fs);
fprintf('Target frequency: %.2f Hz\n', f_target);
fprintf('Target amplitude: %.2f\n', A_target);
fprintf('Noise standard deviation: %.2f\n', noise_std);
fprintf('Number of samples: %d\n', length(t));
fprintf('Signal duration: %.2f seconds\n', T);
% 7. Plot the signals
fig1 = figure('Name', 'Radar Signal Simulation', ...
              'NumberTitle', 'off');
subplot(3,1,1);
plot(t, target_signal);
title('Simulated Target Signal');
xlabel('Time (seconds)');
ylabel('Amplitude');
grid on;
subplot(3,1,2);
plot(t, noise);
title('Simulated Random Noise');
xlabel('Time (seconds)');
ylabel('Amplitude');
grid on;
subplot(3,1,3);
plot(t, received_signal);
title('Received Signal: Target + Noise');
xlabel('Time (seconds)');
ylabel('Amplitude');
grid on;
% 8. Save the Stage 1 figure
saveas(fig1, 'radar_signal_simulation.png');
disp('Stage 1 figure saved: radar_signal_simulation.png');
disp(' ');
%% STAGE 2: FAST FOURIER TRANSFORM (FFT)
disp('Stage 2: Fast Fourier Transform Analysis');
% 1. Calculate the FFT
N = length(received_signal);
Y = fft(received_signal);
% 2. Calculate the two-sided amplitude spectrum
P2 = abs(Y/N);
% 3. Extract the single-sided amplitude spectrum
P1 = P2(1:floor(N/2)+1);
% Double amplitudes except at DC and the Nyquist frequency
if rem(N, 2) == 0
    P1(2:end-1) = 2*P1(2:end-1);
else
    P1(2:end) = 2*P1(2:end);
end
% 4. Create the frequency axis
f = fs*(0:floor(N/2))/N;
% 5. Find the dominant frequency
[~, peak_index] = max(P1);
dominant_frequency = f(peak_index);
% 6. Display FFT results
frequency_resolution = fs/N;
fprintf('Expected target frequency: %.2f Hz\n', f_target);
fprintf('Detected dominant frequency: %.2f Hz\n', ...
        dominant_frequency);
fprintf('Frequency resolution: %.2f Hz\n', ...
        frequency_resolution);
% 7. Plot the frequency spectrum
fig2 = figure('Name', 'Radar FFT Analysis', ...
              'NumberTitle', 'off');
plot(f, P1, 'LineWidth', 1.2);
title('Single-Sided Amplitude Spectrum');
xlabel('Frequency (Hz)');
ylabel('Amplitude');
grid on;
xlim([0 200]);
% 8. Save the Stage 2 figure
saveas(fig2, 'radar_fft_analysis.png');
disp('Stage 2 figure saved: radar_fft_analysis.png');
disp(' ');
disp('Stages 1 and 2 completed successfully.');
%% STAGE 3: THRESHOLD-BASED TARGET DETECTION

disp(' ');
disp('Stage 3: Threshold-Based Target Detection');

% 1. Calculate the detection statistic

detection_statistic = max(abs(received_signal));

% 2. Define the detection threshold

threshold = 1.5;

% 3. Apply the detection rule

if detection_statistic > threshold
    detection_result = 'TARGET DETECTED';
else
    detection_result = 'TARGET NOT DETECTED';
end

% 4. Display the results

fprintf('Detection statistic: %.4f\n', detection_statistic);
fprintf('Detection threshold: %.4f\n', threshold);
fprintf('Detection decision: %s\n', detection_result);

% 5. Plot the received signal and threshold

fig3 = figure('Name', 'Threshold-Based Target Detection', ...
    'NumberTitle', 'off');

plot(t, received_signal, 'b');
hold on;

yline(threshold, '--r', 'Upper Threshold');
yline(-threshold, '--r', 'Lower Threshold');

title('Threshold-Based Target Detection');
xlabel('Time (seconds)');
ylabel('Amplitude');
legend('Received Signal', 'Detection Thresholds');
grid on;

hold off;

% 6. Save the figure

saveas(fig3, 'radar_target_detection.png');

disp('Detection figure saved: radar_target_detection.png');
disp('Stage 3 completed.');
%% STAGE 4: DETECTION PERFORMANCE EVALUATION

disp(' ');
disp('Stage 4: Detection Performance Evaluation');

% 1. Define simulation parameters

num_trials = 10000;
threshold_pd = threshold;
target_amplitude_pd = A_target;
noise_std_pd = noise_std;

% 2. Initialise counters

detections = 0;
false_alarms = 0;

% 3. Run Monte Carlo simulations

rng(42);  % Reproducible statistical experiment

for k = 1:num_trials

    % Generate a random noise-only signal

    noise_only = noise_std_pd * randn(size(t));

    % Generate a target signal with independent noise

    target_with_noise = ...
        target_amplitude_pd * sin(2*pi*f_target*t) ...
        + noise_std_pd * randn(size(t));

    % Calculate detection statistics

    noise_statistic = max(abs(noise_only));
    target_statistic = max(abs(target_with_noise));

    % Evaluate detection and false alarm

    if target_statistic > threshold_pd
        detections = detections + 1;
    end

    if noise_statistic > threshold_pd
        false_alarms = false_alarms + 1;
    end

end

% 4. Calculate probabilities

prob_detection = detections / num_trials;
prob_false_alarm = false_alarms / num_trials;

% 5. Display results

fprintf('Number of trials: %d\n', num_trials);
fprintf('Detection threshold: %.2f\n', threshold_pd);
fprintf('Probability of detection: %.4f (%.2f%%)\n', ...
    prob_detection, 100*prob_detection);
fprintf('Probability of false alarm: %.4f (%.2f%%)\n', ...
    prob_false_alarm, 100*prob_false_alarm);

% 6. Plot the performance results

fig4 = figure('Name', 'Detection Performance', ...
    'NumberTitle', 'off');

bar([prob_detection, prob_false_alarm]);

set(gca, 'XTickLabel', ...
    {'Probability of Detection', 'Probability of False Alarm'});

ylabel('Estimated Probability');
title('Radar Detection Performance');
ylim([0 1]);
grid on;

% 7. Save the figure

saveas(fig4, 'radar_detection_performance.png');

disp('Performance figure saved: radar_detection_performance.png');
disp('Stage 4 completed.');
%% STAGE 5: THRESHOLD PERFORMANCE COMPARISON

disp(' ');
disp('Stage 5: Threshold Performance Comparison');

% 1. Define thresholds to investigate

threshold_values = 0.5:0.25:3.0;

num_thresholds = length(threshold_values);

% 2. Prepare result arrays

pd_values = zeros(1, num_thresholds);
pfa_values = zeros(1, num_thresholds);

% 3. Set simulation parameters

num_trials_threshold = 5000;

rng(100);

% 4. Evaluate each threshold

for j = 1:num_thresholds

    current_threshold = threshold_values(j);

    detection_count = 0;
    false_alarm_count = 0;

    for k = 1:num_trials_threshold

        % Noise-only signal

        noise_only = noise_std * randn(size(t));

        % Target signal with noise

        target_signal_trial = ...
            A_target * sin(2*pi*f_target*t) ...
            + noise_std * randn(size(t));

        % Calculate detection statistics

        noise_statistic = max(abs(noise_only));

        target_statistic = max(abs(target_signal_trial));

        % Count detections

        if target_statistic > current_threshold
            detection_count = detection_count + 1;
        end

        % Count false alarms

        if noise_statistic > current_threshold
            false_alarm_count = false_alarm_count + 1;
        end

    end

    % Calculate probabilities

    pd_values(j) = detection_count / num_trials_threshold;

    pfa_values(j) = false_alarm_count / num_trials_threshold;

end

% 5. Display results

fprintf('\nThreshold | Probability of Detection | Probability of False Alarm\n');

for j = 1:num_thresholds

    fprintf('%9.2f | %24.4f | %27.4f\n', ...
        threshold_values(j), pd_values(j), pfa_values(j));

end

% 6. Plot probability of detection

fig5 = figure('Name', 'Threshold vs Detection Probability', ...
              'NumberTitle', 'off');

plot(threshold_values, pd_values, '-o', 'LineWidth', 1.5);

xlabel('Detection Threshold');
ylabel('Probability of Detection');

title('Effect of Threshold on Detection Probability');

ylim([0 1.05]);
grid on;

saveas(fig5, 'threshold_vs_detection_probability.png');

% 7. Plot probability of false alarm

fig6 = figure('Name', 'Threshold vs False Alarm Probability', ...
              'NumberTitle', 'off');

plot(threshold_values, pfa_values, '-o', 'LineWidth', 1.5);

xlabel('Detection Threshold');
ylabel('Probability of False Alarm');

title('Effect of Threshold on False Alarm Probability');

ylim([0 1.05]);
grid on;

saveas(fig6, 'threshold_vs_false_alarm_probability.png');

disp('Threshold comparison figures saved.');
disp('Stage 5 completed.');
%% STAGE 6: RECEIVER OPERATING CHARACTERISTIC (ROC) CURVE
disp(' ');
disp('Stage 6: ROC Curve Analysis');
% 1. Plot probability of detection against false alarm probability
fig7 = figure('Name', 'Radar ROC Curve', ...
    'NumberTitle', 'off');
plot(pfa_values, pd_values, '-o', ...
    'LineWidth', 1.5);
xlabel('Probability of False Alarm');
ylabel('Probability of Detection');
title('Radar Receiver Operating Characteristic (ROC) Curve');
xlim([0 1]);
ylim([0 1.05]);
grid on;
% 2. Save the figure
saveas(fig7, 'radar_roc_curve.png');
% 3. Display completion message
disp('ROC curve saved: radar_roc_curve.png');
disp('Stage 6 completed successfully.');
%% STAGE 7: SIGNAL-TO-NOISE RATIO ANALYSIS
disp(' ');
disp('Stage 7: Signal-to-Noise Ratio Analysis');
% 1. Define noise levels
noise_levels = [0.1 0.2 0.3 0.5 0.8];
num_noise_levels = length(noise_levels);
snr_values_db = zeros(1, num_noise_levels);
% 2. Calculate theoretical SNR for each noise level
for j = 1:num_noise_levels
    signal_power = mean(target_signal.^2);
    noise_power = noise_levels(j)^2;
    snr_values_db(j) = ...
        10 * log10(signal_power / noise_power);
end
% 3. Display the results
fprintf('\nNoise Standard Deviation | Theoretical SNR (dB)\n');
for j = 1:num_noise_levels
    fprintf('%24.2f | %20.2f dB\n', ...
        noise_levels(j), snr_values_db(j));
end
% 4. Plot the results
fig8 = figure('Name', 'Noise Level and SNR Analysis', ...
    'NumberTitle', 'off');
plot(noise_levels, snr_values_db, '-o', ...
    'LineWidth', 1.5);
xlabel('Noise Standard Deviation');
ylabel('Theoretical SNR (dB)');
title('Effect of Noise on Signal-to-Noise Ratio');
grid on;
% 5. Save the figure
saveas(fig8, 'radar_snr_analysis.png');
disp('SNR figure saved: radar_snr_analysis.png');
disp('Stage 7 completed successfully.');
%% STAGE 8: CONSOLIDATED RESULTS AND REPORTING
disp(' ');
disp('Stage 8: Consolidated Results and Reporting');
% 1. Create a results table
results_table = table( ...
    threshold_values', ...
    pd_values', ...
    pfa_values', ...
    'VariableNames', { ...
    'Threshold', ...
    'ProbabilityDetection', ...
    'ProbabilityFalseAlarm'});
% 2. Display the table
disp('Detection Performance Results:');
disp(results_table);
% 3. Save the table as a CSV file
writetable(results_table, ...
    'radar_detection_results.csv');
% 4. Save the main simulation parameters
parameter_names = { ...
    'Sampling Frequency (Hz)'; ...
    'Signal Duration (seconds)'; ...
    'Target Frequency (Hz)'; ...
    'Target Amplitude'; ...
    'Noise Standard Deviation'; ...
    'Number of Detection Trials'; ...
    'Number of Threshold Trials'};
parameter_values = [ ...
    fs; ...
    T; ...
    f_target; ...
    A_target; ...
    noise_std; ...
    num_trials; ...
    num_trials_threshold];
parameters_table = table( ...
    parameter_names, ...
    parameter_values, ...
    'VariableNames', {'Parameter', 'Value'});
writetable(parameters_table, ...
    'radar_simulation_parameters.csv');
% 5. Save the results report as a text file
report_file = fopen('radar_project_report.txt', 'w');
fprintf(report_file, ...
    'RADAR SIGNAL PROCESSING AND TARGET DETECTION\n');
fprintf(report_file, ...
    '============================================\n\n');
fprintf(report_file, ...
    'Project objective:\n');
fprintf(report_file, ...
    ['Simulate a target signal, analyse its frequency, ' ...
    'and evaluate threshold-based detection performance.\n\n']);
fprintf(report_file, ...
    'Simulation configuration:\n');
fprintf(report_file, 'Sampling frequency: %.2f Hz\n', fs);
fprintf(report_file, 'Target frequency: %.2f Hz\n', f_target);
fprintf(report_file, 'Target amplitude: %.2f\n', A_target);
fprintf(report_file, 'Noise standard deviation: %.2f\n\n', noise_std);
fprintf(report_file, ...
    'Detection performance across thresholds:\n\n');
fprintf(report_file, ...
    'Threshold | Probability of Detection | Probability of False Alarm\n');
for j = 1:length(threshold_values)
    fprintf(report_file, ...
        '%.2f | %.4f | %.4f\n', ...
        threshold_values(j), ...
        pd_values(j), ...
        pfa_values(j));
end
fprintf(report_file, ...
    '\nLimitations:\n');
fprintf(report_file, ...
    ['This project uses simulated sinusoidal signals and ' ...
    'Gaussian noise. Results are not measurements of ' ...
    'real radar hardware performance.\n']);
fclose(report_file);
disp('Saved: radar_detection_results.csv');
disp('Saved: radar_simulation_parameters.csv');
disp('Saved: radar_project_report.txt');
disp('Stage 8 completed successfully.');
%% STAGE 9: FINAL PROJECT REVIEW
disp(' ');
disp('Stage 9: Final Project Review');
% 1. List required output files
required_files = {
    'radar_signal_simulation.png'
    'radar_fft_analysis.png'
    'radar_target_detection.png'
    'radar_detection_performance.png'
    'threshold_vs_detection_probability.png'
    'threshold_vs_false_alarm_probability.png'
    'radar_roc_curve.png'
    'radar_snr_analysis.png'
    'radar_detection_results.csv'
    'radar_simulation_parameters.csv'
    'radar_project_report.txt'
    };
% 2. Check each file
file_status = false(length(required_files), 1);
for k = 1:length(required_files)
    file_status(k) = isfile(required_files{k});
    if file_status(k)
        fprintf('[OK]      %s\n', required_files{k});
    else
        fprintf('[MISSING] %s\n', required_files{k});
    end
end
% 3. Display summary
fprintf('\nFiles found: %d of %d\n', ...
    sum(file_status), length(required_files));
if all(file_status)
    disp('All required output files are present.');
else
    disp('Some output files are missing. Check the list above.');
end
% 4. Save the verification report
verification_table = table( ...
    required_files, file_status, ...
    'VariableNames', {'FileName', 'FileExists'});
writetable(verification_table, ...
    'radar_project_file_check.csv');
disp('Verification report saved: radar_project_file_check.csv');
disp('Stage 9 completed.');