%% plot_passive_vs_active.m
clear; clc; close all;

set(0, 'DefaultAxesFontName', 'Helvetica');
set(0, 'DefaultAxesFontSize', 11);
set(0, 'DefaultTextFontName', 'Helvetica');

load('passive_results.mat', 'logsout_passive', 'tout_passive');
load('active_results.mat',  'logsout_active',  'tout_active');

normal_force_p  = logsout_passive{10}.Values;
screw_depth_p   = logsout_passive{6}.Values;
screw_angle_p   = logsout_passive{5}.Values;
friction_trq_p  = logsout_passive{4}.Values;
phase_out_p     = logsout_passive{3}.Values;

normal_force_a  = logsout_active{10}.Values;
screw_depth_a   = logsout_active{6}.Values;
screw_angle_a   = logsout_active{5}.Values;
friction_trq_a  = logsout_active{4}.Values;
phase_out_a     = logsout_active{3}.Values;

c_passive = [0.85, 0.33, 0.10];
c_active  = [0.00, 0.45, 0.74];

fig = figure('Name','Passive vs Active Impedance Control', ...
    'Units','normalized','Position',[0.05 0.05 0.70 0.88], ...
    'Color','w');

tiledlayout(3,2,'TileSpacing','compact','Padding','compact');

%% (a) Normal Force
nexttile;
plot(normal_force_p.Time, normal_force_p.Data, 'Color', c_passive, 'LineWidth', 1.5); hold on;
plot(normal_force_a.Time, normal_force_a.Data, 'Color', c_active,  'LineWidth', 1.5);
yline(10, '--k', 'F_{engage} = 10N', 'LineWidth', 1, 'LabelHorizontalAlignment', 'left');
yline(15, ':k', 'F_{snug} = 15N', 'LineWidth', 1, 'LabelHorizontalAlignment', 'left');
yline(25, '-.r', 'Safety = 25N', 'LineWidth', 1, 'LabelHorizontalAlignment', 'left');
xlabel({'Time [s]','\bf(a)'});
ylabel('Force [N]');
title('Normal Force');
legend('Passive (K_f=0)', 'Active (K_f=0.75)', 'Location', 'northeast');
xlim([0 12]); grid on; box on;

%% (b) Screw Depth
nexttile;
plot(screw_depth_p.Time, screw_depth_p.Data * 1000, 'Color', c_passive, 'LineWidth', 1.5); hold on;
plot(screw_depth_a.Time, screw_depth_a.Data * 1000, 'Color', c_active,  'LineWidth', 1.5);
yline(20, '--k', 'L_{screw} = 20mm', 'LineWidth', 1, 'LabelHorizontalAlignment', 'left');
xlabel({'Time [s]','\bf(b)'});
ylabel('Depth [mm]');
title('Screw Depth');
legend('Passive (K_f=0)', 'Active (K_f=0.75)', 'Location', 'best');
xlim([0 12]); grid on; box on;

%% (c) Screw Angle
nexttile;
plot(screw_angle_p.Time, screw_angle_p.Data, 'Color', c_passive, 'LineWidth', 1.5); hold on;
plot(screw_angle_a.Time, screw_angle_a.Data, 'Color', c_active,  'LineWidth', 1.5);
xlabel({'Time [s]','\bf(c)'});
ylabel('Angle [rad]');
title('Screw Angle');
legend('Passive (K_f=0)', 'Active (K_f=0.75)', 'Location', 'best');
xlim([0 12]); grid on; box on;

%% (d) Friction Torque
nexttile;
plot(friction_trq_p.Time, friction_trq_p.Data * 1000, 'Color', c_passive, 'LineWidth', 1.5); hold on;
plot(friction_trq_a.Time, friction_trq_a.Data * 1000, 'Color', c_active,  'LineWidth', 1.5);
yline(3, '--r', '\tau_{nominal} = 3mN\cdotm', 'LineWidth', 1);
xlabel({'Time [s]','\bf(d)'});
ylabel('Torque [mN\cdotm]');
title('Friction Torque');
legend('Passive (K_f=0)', 'Active (K_f=0.75)', 'Location', 'best');
xlim([0 12]); grid on; box on;

%% (e) Phase Progression
nexttile;
stairs(phase_out_p.Time, phase_out_p.Data, 'Color', c_passive, 'LineWidth', 2); hold on;
stairs(phase_out_a.Time, phase_out_a.Data, 'Color', c_active,  'LineWidth', 2);
yticks([0 1 2 3 4]);
yticklabels({'0-Approach','1-Engagement','2-Rundown','3-Tightening','4-Completion'});
ylim([-0.5, 4.5]);
xlabel({'Time [s]','\bf(e)'});
title('Phase Progression');
legend('Passive (K_f=0)', 'Active (K_f=0.75)', 'Location', 'best');
xlim([0 12]); grid on; box on;

%% (f) Force Tracking Error
nexttile;
F_des_vec = zeros(size(normal_force_a.Data));
for i = 1:length(phase_out_a.Data)
    switch phase_out_a.Data(i)
        case {1, 2}
            F_des_vec(i) = 10;
        case 3
            F_des_vec(i) = 15;
        otherwise
            F_des_vec(i) = 0;
    end
end

force_error = F_des_vec - normal_force_a.Data;
plot(normal_force_a.Time, force_error, 'Color', c_active, 'LineWidth', 1.5);
yline(0, '--k', 'Zero error', 'LineWidth', 1);
xlabel({'Time [s]','\bf(f)'});
ylabel('Force Error [N]');
title('Force Tracking Error (Active Only)');
xlim([0 12]); grid on; box on;

sgtitle('Passive vs Force-Augmented Impedance Control — M5 Screwdriving', ...
    'FontSize', 14, 'FontWeight', 'bold');

savefig(fig, 'passive_vs_active_comparison.fig');
exportgraphics(fig, 'passive_vs_active_comparison.png', 'Resolution', 1200);

fprintf('Figures saved: passive_vs_active_comparison.fig and .png\n');