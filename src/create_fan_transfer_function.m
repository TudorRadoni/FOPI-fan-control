clear all; clc; close all;

% Load System Fan 4 (back exhaust step data)
step_data = readtable('stepresp_20260106_201637.csv')
t = step_data.time_sec;
pwm = step_data.pwm;
rpm = step_data.rpm;

% Load the sine experiment as well for estimating K
% Using only the step response would capture the dynamics (tau, Td)
% But we also want the scale, so that's why I use the sine data.
%
% Q: Why not estimate from step response?
% A: Because the fan is non linear and I think that using the sine is
% better for getting a more realistic model.

sine_data = readtable('sine_20260102_145352.csv');
t_sine_raw = sine_data.time_sec;
pwm_sine_raw = sine_data.pwm;
rpm_sine_raw = sine_data.rpm;

%% Plot raw step data
figure;
yyaxis left
plot(t, pwm, '-', 'LineWidth', 1.5); ylabel('PWM (%)');
yyaxis right
plot(t, rpm, '-', 'LineWidth', 1.5); ylabel('RPM');
xlabel('Time (s)');
title('Fan PWM and RPM (Step Response)');
grid on;

%% Detect PWM steps
dpwm = [0; diff(pwm)];
step_idx = find(dpwm ~= 0);

% Pick the first step for estimation
step_start = step_idx(1);
PWM_before = pwm(step_start-1);
RPM_before = rpm(step_start-1);
RPM_after = mean(rpm(step_start+40:step_start+60)); % use mean to reduce noise

% Estimate delay
threshold = 5; % RPM change threshold to detect response
step_range = step_start:length(rpm);
change_idx = step_range(find(abs(rpm(step_range)-RPM_before) > threshold, 1));
Td = t(change_idx) - t(step_start);

% Estimate time constant (63% rise)
y63 = RPM_before + 0.63*(RPM_after-RPM_before);
rise_idx = step_range(find(rpm(step_range) >= y63, 1));
tau = t(rise_idx) - t(change_idx);

% Estimate gain from sine experiment
K = (max(rpm_sine_raw) - min(rpm_sine_raw)) / (max(pwm_sine_raw) - min(pwm_sine_raw));
K = K * 1.04;   % manual adjustment
fprintf('Estimated gain from sine experiment: K = %.3f RPM/%%PWM\n', K);

%% Build transfer function
s = tf('s');
FanTF = K/(tau*s + 1) * exp(-Td*s);
disp('Estimated transfer function:');
FanTF

% Save the transfer function for use in other scripts
% HINT: Use TF = getFanTF();
save('ArcticP14_TF.mat', 'FanTF');

%% =========================
%  Simulate step response
%  =========================

% Interpolate step data to evenly spaced vector
t_step = linspace(t(1), t(end), 1000);  % 1000 points
pwm_step = interp1(t, pwm, t_step, 'linear');
rpm_step = interp1(t, rpm, t_step, 'linear');

% Simulate response using estimated transfer function
[y_step_sim, t_step_out] = lsim(FanTF, pwm_step, t_step);

% Plot measured vs simulated for step response
figure;
plot(t_step, rpm_step, 'r', 'LineWidth', 1.5); hold on;
plot(t_step_out, y_step_sim, 'b--', 'LineWidth', 1.5);
xlabel('Time (s)'); ylabel('RPM');
legend('Measured', 'Simulated');
title('Measured vs Simulated Fan RPM (Step Response)');
grid on;

%% =========================
%  Simulate sine response
%  =========================

% Interpolate to evenly spaced vector
t_sine = linspace(t_sine_raw(1), t_sine_raw(end), 1000);
pwm_sine = interp1(t_sine_raw, pwm_sine_raw, t_sine, 'linear');
rpm_sine = interp1(t_sine_raw, rpm_sine_raw, t_sine, 'linear');

[y_sim, t_out] = lsim(FanTF, pwm_sine, t_sine);

% Plot measured vs simulated
figure;
plot(t_sine, rpm_sine, 'r', 'LineWidth', 1.5); hold on;
plot(t_out, y_sim, 'b--', 'LineWidth', 1.5);
xlabel('Time (s)'); ylabel('RPM');
legend('Measured', 'Simulated');
title('Measured vs Simulated Fan RPM (Sine Experiment)');
grid on;
