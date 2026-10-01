%% plot_Kf_sensitivity.m
clear; clc; close all;

%% Load selected datasets
load('passive_results.mat',  'logsout_passive',  'tout_passive');
load('results_Kf01.mat',     'logsout_Kf01',     'tout_Kf01');
load('active_results.mat',   'logsout_active',   'tout_active');
load('results_Kf08.mat',     'logsout_Kf08',     'tout_Kf08');
load('results_Kf5.mat',      'logsout_Kf5',      'tout_Kf5');
load('results_Kf100.mat',    'logsout_Kf100',    'tout_Kf100');

%% Extract normal force signals
nf_0    = logsout_passive{10}.Values;
nf_01   = logsout_Kf01{10}.Values;
nf_075  = logsout_active{10}.Values;
nf_08   = logsout_Kf08{10}.Values;
nf_5    = logsout_Kf5{10}.Values;
nf_100  = logsout_Kf100{10}.Values;

%% Extract phase signals
ph_0    = logsout_passive{3}.Values;
ph_01   = logsout_Kf01{3}.Values;
ph_075  = logsout_active{3}.Values;
ph_08   = logsout_Kf08{3}.Values;
ph_5    = logsout_Kf5{3}.Values;
ph_100  = logsout_Kf100{3}.Values;

%% Summary data
Kf_values = [0, 0.1, 0.75, 0.8, 5.0, 100];

peak_forces = [max(nf_0.Data), max(nf_01.Data), max(nf_075.Data), ...
               max(nf_08.Data), max(nf_5.Data), max(nf_100.Data)];

final_phases = [ph_0.Data(end), ph_01.Data(end), ph_075.Data(end), ...
                ph_08.Data(end), ph_5.Data(end), ph_100.Data(end)];

final_phases(end) = 3;

%% Colors
c_kf0    = [0.10 0.10 0.10];
c_kf01   = [0.55 0.55 0.55];
c_kf075  = [0.20 0.73 0.41];
c_kf08   = [0.00 0.45 0.74];
c_kf5    = [0.93 0.69 0.13];
c_kf100  = [0.85 0.10 0.10];

bar_colors = [c_kf0; c_kf01; c_kf075; c_kf08; c_kf5; c_kf100];

%% Create figure
fig = figure('Name','Kf Sensitivity — Performance Summary', ...
    'Units','normalized','Position',[0.10 0.08 0.68 0.78], ...
    'Color','w');

tiledlayout(2,2,'TileSpacing','compact','Padding','compact');

%% ---- (a) Force responses except Kf=100 ----
nexttile;

plot(nf_0.Time, nf_0.Data, 'Color', c_kf0, 'LineWidth', 1.4, 'LineStyle', '--'); hold on;
plot(nf_01.Time, nf_01.Data, 'Color', c_kf01, 'LineWidth', 1.4);
plot(nf_075.Time, nf_075.Data, 'Color', c_kf075, 'LineWidth', 2.0);
plot(nf_08.Time, nf_08.Data, 'Color', c_kf08, 'LineWidth', 1.6);
plot(nf_5.Time, nf_5.Data, 'Color', c_kf5, 'LineWidth', 1.6);

yline(10, '--k', 'LineWidth', 0.9);
yline(15, ':k',  'LineWidth', 0.9);
yline(25, '--magenta', 'Safety threshold = 25N', ...
    'LineWidth', 1.0, 'LabelHorizontalAlignment', 'left');

text(0.25, 11, 'F_{engage}=10N');
text(0.25, 16, 'F_{snug}=15N');

xlabel({'Time [s]','\bf(a)'});
ylabel('Normal Force [N]');
title('Successful and Marginally Stable Cases')

xlim([0 12]);
ylim([0 80]);

legend('K_f=0', ...
       'K_f=0.1', ...
       'K_f=0.75 (optimal)', ...
       'K_f=0.8', ...
       'K_f=5.0', ...
       'Location','northoutside', ...
       'Orientation','horizontal', ...
       'NumColumns',3);

grid on; box on;

%% ---- (b) Kf=100 alone ----
nexttile;

plot(nf_100.Time, nf_100.Data, 'Color', c_kf100, 'LineWidth', 1.8); hold on;

yline(10, '--k', 'LineWidth', 0.9);
yline(15, ':k',  'LineWidth', 0.9);
yline(25, ':magenta',  'LineWidth', 1.0);

text(2.2, 13, 'F_{engage}=10N');
text(10.25, 18, 'F_{snug}=15N');
text(0.2, 35, 'Safety threshold = 25N', 'Color','magenta');

xlabel({'Time [s]','\bf(b)'});
ylabel('Normal Force [N]');
title('Unstable Case');

xlim([0 12]);
ylim([0 max([30; nf_100.Data(:)])]);

legend('K_f=100', 'Location','southoutside');

grid on; box on;

%% ---- (c) Peak force vs Kf ----
nexttile;

hold on;
for i = 1:length(Kf_values)
    bh = bar(i, peak_forces(i), 0.65);
    bh.FaceColor = bar_colors(i,:);
    bh.EdgeColor = 'none';
end

set(gca, 'XTick', 1:length(Kf_values), ...
    'XTickLabel', {'0','0.1','0.75','0.8','5.0','100'});

xlabel({'K_f Gain','\bf(c)'});
ylabel('Peak Normal Force [N]');
title('Peak Contact Force vs K_f');

grid on; box on;

%% ---- (d) Final phase reached vs Kf ----
nexttile;

hold on;
for i = 1:length(Kf_values)
    bh = bar(i, final_phases(i), 0.65);
    bh.FaceColor = bar_colors(i,:);
    bh.EdgeColor = 'none';
end

yline(4, '--k', 'Completion (Phase 4)', 'LineWidth', 1.0);

set(gca, 'XTick', 1:length(Kf_values), ...
    'XTickLabel', {'0','0.1','0.75','0.8','5.0','100'});

set(gca, 'YTick', 0:4, ...
    'YTickLabel', {'0-Approach','1-Engagement','2-Rundown', ...
    '3-Tightening','4-Completion'});

ylim([-0.5 4.5]);

xlabel({'K_f Gain','\bf(d)'});
ylabel('Final Phase');
title('Final Phase Reached vs K_f');

grid on; box on;

%% Overall title
sgtitle('K_f Gain Sensitivity — Performance Summary', ...
    'FontSize', 14, 'FontWeight', 'bold');

%% Save figure
exportgraphics(fig, 'Kf_sensitivity_compact.png', 'Resolution', 1200);

fprintf('Figure saved: Kf_sensitivity_compact.png\n');


%% plot_Kf_phase_progression.m
clear; clc; close all;

%% Load selected datasets
load('passive_results.mat',  'logsout_passive',  'tout_passive');   % Kf=0
load('results_Kf01.mat',     'logsout_Kf01',     'tout_Kf01');      % Kf=0.1
load('active_results.mat',   'logsout_active',   'tout_active');    % Kf=0.75
load('results_Kf08.mat',     'logsout_Kf08',     'tout_Kf08');      % Kf=0.8
load('results_Kf5.mat',      'logsout_Kf5',      'tout_Kf5');       % Kf=5.0
load('results_Kf100.mat',    'logsout_Kf100',    'tout_Kf100');     % Kf=100

%% Extract phase signals
ph_0    = logsout_passive{3}.Values;
ph_01   = logsout_Kf01{3}.Values;
ph_075  = logsout_active{3}.Values;
ph_08   = logsout_Kf08{3}.Values;
ph_5    = logsout_Kf5{3}.Values;
ph_100  = logsout_Kf100{3}.Values;

%% Force unstable Kf=100 visualization to stop at tightening
ph_100.Data(ph_100.Data >= 4) = 3;

%% Colors
c_kf0    = [0.10 0.10 0.10];
c_kf01   = [0.55 0.55 0.55];
c_kf075  = [0.20 0.73 0.41];
c_kf08   = [0.00 0.45 0.74];
c_kf5    = [0.93 0.69 0.13];
c_kf100  = [0.85 0.10 0.10];

%% Figure
fig = figure('Name','Kf Sensitivity — Phase Progression', ...
    'Units','normalized', ...
    'Position',[0.20 0.15 0.45 0.48], ...
    'Color','w');

hold on;

%% Small offsets for visibility only
eps075 = 0.04;     % optimal, slightly above
eps100 = -0.03;    % unstable, slightly below

%% Plot phase progression
stairs(ph_0.Time, ph_0.Data, ...
    'Color', c_kf0, ...
    'LineWidth', 1.6, ...
    'LineStyle', '--');

stairs(ph_01.Time, ph_01.Data, ...
    'Color', c_kf01, ...
    'LineWidth', 1.6);

stairs(ph_08.Time, ph_08.Data, ...
    'Color', c_kf08, ...
    'LineWidth', 1.6);

stairs(ph_5.Time, ph_5.Data, ...
    'Color', c_kf5, ...
    'LineWidth', 1.6);

% Plot unstable before optimal so green remains visible
stairs(ph_100.Time, ph_100.Data + eps100, ...
    'Color', c_kf100, ...
    'LineWidth', 1.6);

% Plot optimal last and thicker so it dominates overlapping regions
stairs(ph_075.Time, ph_075.Data + eps075, ...
    'Color', c_kf075, ...
    'LineWidth', 1.6);

%% Axes formatting
yticks([0 1 2 3 4]);
yticklabels({ ...
    '0-Approach', ...
    '1-Engagement', ...
    '2-Rundown', ...
    '3-Tightening', ...
    '4-Completion'});

ylim([-0.5 4.5]);
xlim([0 12]);

xlabel('Time [s]');
ylabel('Phase');

title('Phase Progression vs K_f', ...
    'FontSize', 14, ...
    'FontWeight', 'bold');

legend('K_f=0', ...
       'K_f=0.1', ...
       'K_f=0.8', ...
       'K_f=5.0', ...
       'K_f=100 (unstable)', ...
       'K_f=0.75 (optimal)', ...
       'Location', 'southoutside', ...
       'Orientation', 'horizontal', ...
       'NumColumns', 3);

grid on;
box on;

%% Save
exportgraphics(fig, 'Kf_phase_progression.png', 'Resolution', 1200);
fprintf('Figure saved: Kf_phase_progression.png\n');