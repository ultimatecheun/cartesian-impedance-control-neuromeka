%% plot_Kf_steady_state_overshoot_refined.m
clear; clc; close all;

%% Load datasets
load('active_results.mat',  'logsout_active');   % Kf=0.75
load('results_Kf08.mat',    'logsout_Kf08');     % Kf=0.8
load('results_Kf5.mat',     'logsout_Kf5');      % Kf=5.0
load('results_Kf100.mat',   'logsout_Kf100');    % Kf=100

%% Extract normal force signals
nf_075  = logsout_active{10}.Values;
nf_08   = logsout_Kf08{10}.Values;
nf_5    = logsout_Kf5{10}.Values;
nf_100  = logsout_Kf100{10}.Values;

%% Overshoot settings
F_target = 10;      % F_engage target [N]
t_start  = 5.3;     % exclude initial contact transient
t_end    = 9.0;     % engagement/run-down interval

signals = {nf_075, nf_08, nf_5, nf_100};
Kf_vals = [0.75, 0.8, 5.0, 100];

%% Compute steady-state overshoot
overshoot = zeros(size(Kf_vals));
peak_force = zeros(size(Kf_vals));

for i = 1:length(signals)

    sig = signals{i};

    idx = sig.Time >= t_start & sig.Time <= t_end;

    peak_force(i) = max(sig.Data(idx));

    overshoot(i) = max(0, ...
        ((peak_force(i) - F_target) / F_target) * 100);
end

%% Display values
T = table(Kf_vals(:), peak_force(:), overshoot(:), ...
    'VariableNames', ...
    {'Kf','PeakSteadyForce_N','Overshoot_percent'});

disp(T);

%% Colors
c_kf075  = [0.20 0.73 0.41];   % green
c_kf08   = [0.00 0.45 0.74];   % blue
c_kf5    = [0.93 0.69 0.13];   % amber
c_kf100  = [0.85 0.10 0.10];   % red

%% Figure
fig = figure('Name','Kf Overshoot Summary', ...
    'Units','normalized', ...
    'Position',[0.18 0.18 0.62 0.48], ...
    'Color','w');

%% ============================================================
%% (a) Successful / unsafe completion cases
%% ============================================================
subplot(1,2,1);
hold on;

vals_left = overshoot(1:3);
colors_left = {c_kf075, c_kf08, c_kf5};

for i = 1:3

    b = bar(i, vals_left(i), 0.65);
    b.FaceColor = colors_left{i};
    b.EdgeColor = 'none';

    %% Put large values inside bars
    if vals_left(i) > 100

        text(i, vals_left(i)-25, ...
            sprintf('%.0f%%', vals_left(i)), ...
            'HorizontalAlignment','center', ...
            'VerticalAlignment','middle', ...
            'FontSize',10, ...
            'FontWeight','bold', ...
            'Color','w');

    else

        text(i, vals_left(i)+4, ...
            sprintf('%.0f%%', vals_left(i)), ...
            'HorizontalAlignment','center', ...
            'FontSize',10, ...
            'FontWeight','bold');
    end
end

set(gca, ...
    'XTick',1:3, ...
    'XTickLabel',{'0.75','0.8','5.0'}, ...
    'FontSize',10);

xlabel({'K_f Gain','\bf(a)'});
ylabel('Force Overshoot Relative to F_{engage} [%]');

title('Successful / Unsafe Completion Cases');

ylim([0 520]);

%% Optimal annotation
text(1, vals_left(1)+22, ...
    'Optimal', ...
    'HorizontalAlignment','center', ...
    'FontWeight','bold', ...
    'FontSize',10);

grid on;
box on;

%% ============================================================
%% (b) Unstable case
%% ============================================================
subplot(1,2,2);
hold on;

b = bar(1, overshoot(4), 0.55);
b.FaceColor = c_kf100;
b.EdgeColor = 'none';

%% Put label inside bar
text(1, overshoot(4)-65, ...
    sprintf('%.0f%%', overshoot(4)), ...
    'HorizontalAlignment','center', ...
    'VerticalAlignment','middle', ...
    'FontSize',10, ...
    'FontWeight','bold', ...
    'Color','w');

set(gca, ...
    'XTick',1, ...
    'XTickLabel',{'100'}, ...
    'FontSize',10);

xlabel({'K_f Gain','\bf(b)'});
ylabel('Force Overshoot Relative to F_{engage} [%]');

title('Unstable Case');

ylim([0 1400]);

grid on;
box on;

%% Overall title
sgtitle('Steady-State Engagement Force Overshoot vs K_f', ...
    'FontSize',14, ...
    'FontWeight','bold');

%% Save
exportgraphics(fig, ...
    'Kf_overshoot_summary.png', ...
    'Resolution',1200);

savefig(fig, ...
    'Kf_overshoot_summary.fig');

fprintf('Saved: Kf_overshoot_summary.png and .fig\n');