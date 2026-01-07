clear all; clc; close all;

% Load System Fan 4 (back exhaust) identification data
data = readtable('sine_20260102_145352.csv');

% Extract signals
t = data.time_sec(:);
u_pwm = data.pwm(:); % PWM input (%)
y_rpm = data.rpm(:); % fan's RPM
Ts = mean(diff(t));  % sampling time

% Plot raw signals
figure
plot(t, u_pwm, 'k', 'LineWidth', 1.2); hold on;
plot(t, y_rpm, 'r', 'LineWidth', 1.2);
grid on
title('Fan RPM response to sinusoidal PWM input');
legend('PWM (%)','RPM');
xlabel('Time (s)');
ylabel('Amplitude');

%% Normalize signals and compute peaks
freq = 2; % (Hz)
phm = 60 / 180 * pi; % desired phase margin (rad)
samples_per_period = round(1 / (freq * Ts));  % samples per sin period

% Detect RPM peaks
[peaks_max, ~] = findpeaks(y_rpm, 'MinPeakDistance', floor(samples_per_period / 2));
[peaks_min, ~] = findpeaks(-y_rpm, 'MinPeakDistance', floor(samples_per_period / 2));
peaks_min = -peaks_min;

% Compute RPM amplitude scale
amp_max = mean(peaks_max);
amp_min = mean(peaks_min);
scale = (amp_max - amp_min) / 2;

% Normalize RPM (PWM should remain the same, I think, because we cannot
% send negative PWM to the fan.
u_sim = u_pwm;
y_norm = y_rpm - scale;


% Plot for visualization only
figure;
plot(t, u_sim, 'k', 'LineWidth', 1.2); hold on;
plot(t, y_norm, 'b', 'LineWidth', 1.2);
grid on;
title('PWM input and scaled RPM output');
xlabel('Time [s]');
ylabel('Amplitude');
legend('PWM (%)', 'Scaled RPM');

%%
M =  amp_max - scale;
Phi = freq*2*pi*(525.238 - 527.813); % measured phase shift (rad)

% figure(2), plot(tout,U,'b'), hold on, plot(tout,Ybar_expe, 'r');
% simtime = t(end);
% sim('ident_sin_real');
% figure
% plot(t,Ybar_expe); hold on
% plot(t,u_norm); hold on
% plot(t,y_norm);
% title('The output derivative in comparison to the input and output');
% legend('Derivative','Input', 'Ouput');
% ylabel('Amplitude (degrees)'); xlabel('Time (seconds)');

wt = 2 * pi * freq; % angular freq of the input (rad/s)

% Compute derivative
dy_dt = diff(y_rpm)/Ts;
t_d = t(1:end-1);

% Derivative amplitude
MB = (max(dy_dt) - min(dy_dt)) / 2;

% Derivative phase relative to PWM
[~, idx_d_peak] = max(dy_dt);
t_d_peak = t_d(idx_d_peak);

[~, idx_pwm_peak] = max(u_pwm);
t_pwm_peak = t(idx_pwm_peak);

PhiB = 2*pi*freq*(t_d_peak - t_pwm_peak); % (rad)

phase_deriv = MB / M * cos(PhiB - Phi);
process_phase = Phi;

%% Sweep fractional order mu and compute ki candidates
mu_range = 0.2:0.001:2;  
ki1_vals = zeros(size(mu_range));
ki2_vals = zeros(size(mu_range));
ki3_vals = zeros(size(mu_range));

for idx = 1:length(mu_range)
    mu = mu_range(idx);
    
    % Fractional derivative constants
    z1 = mu * wt^(-mu-1) * sin(pi*mu/2);
    z2 = 2 * wt^(-mu) * cos(pi*mu/2);
    z3 = wt^(-2*mu);
    
    % Candidate ki values from quadratic formula
    ki1 = -((z1 + z2*phase_deriv) + sqrt((z1 + z2*phase_deriv)^2 - 4*z3*phase_deriv^2)) / (2*z3*phase_deriv);
    ki2 = -((z1 + z2*phase_deriv) - sqrt((z1 + z2*phase_deriv)^2 - 4*z3*phase_deriv^2)) / (2*z3*phase_deriv);
    
    % Candidate ki value from phase margin formula
    ki3 = (tan(pi - phm + process_phase) * wt^mu) / (sin(pi*mu/2) - tan(pi - phm + process_phase) * cos(pi*mu/2));
    
    % Store for plotting
    ki1_vals(idx) = ki1;
    ki2_vals(idx) = ki2;
    ki3_vals(idx) = ki3;
end

% Plot comparison
figure; plot(mu_range, ki1_vals, 'r', mu_range, ki3_vals, 'b'); grid on;
title('ki1 vs ki3'); xlabel('\mu'); ylabel('ki'); legend('ki1','ki3');

figure; plot(mu_range, ki2_vals, 'r', mu_range, ki3_vals, 'b'); grid on;
title('ki2 vs ki3'); xlabel('\mu'); ylabel('ki'); legend('ki2','ki3');

% TODO: choose mu based on plots
mu = 1.09;  % example, tune based on intersection of ki curves

% Compute ki from phase margin formula
ki = (tan(pi - phm + process_phase) * wt^mu) / (sin(pi*mu/2) - tan(pi - phm + process_phase) * cos(pi*mu/2));

% Compute proportional gain
kp = (1/M) * (1 / sqrt(1 + 2*ki*wt^(-mu)*cos(pi*mu/2) + (ki^2)*wt^(-2*mu)));

%% Fractional controller construction

% Fractional orders
alfa1 = 1 - mu;
alfa = mu;

% Fractional derivative operator using Oustaloup approximation
% s_alfa1 approximates s^(alfa1)
s_alfa1 = ora_foc_RdK(alfa1, 2, 0.01, 100);

% Continuous-time FOPI controller: kp + ki * integral^alfa1
reg = minreal(kp + kp * ki * tf(1, [1, 0]) * s_alfa1);

% Discretize with 500ms sampling time for the C# code (ZOH)
Ts_C_sharp = 0.5;
regd = minreal(c2d(reg, Ts_C_sharp, 'zoh'), 1e-4);

% Display zeros, poles, gain
disp('Discrete FOPI controller ZPK:');
zpk(regd)

% For recurrence relation / difference equation
[num, den] = tfdata(regd, 'v');
num
den

%% Frequency response comparison
figure
bode(reg); hold on
bode(regd); hold off
grid on
title('Bode plot: Continuous vs Discrete FOPI Controller');

%% Try the regulator on my transfer function
HFan = getFanTF();
figure,
step(feedback(HFan * reg, 1));
figure,
step(feedback(reg, HFan));
