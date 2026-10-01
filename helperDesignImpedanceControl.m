clc
clear
clear allopttype
close all

addpath("C:\Users\adekoyoa\Videos\Dissertation Projects\neuromekaScrewDr\indy-ros2-jazzy-indyDCP3")
addpath("C:\Users\adekoyoa\Videos\Dissertation Projects\neuromekaScrewDr")

diary(['Output_',datestr(now,'mm-dd-yy','local'),'_at_',...
    datestr(now,'hh_MM_ss','local'),'.txt'])

optType = "Impedance Demonstration"; % RB for Reliabiity-Based
optimization_started(optType)
tic

base = "C:\Users\adekoyoa\Videos\Dissertation Projects\neuromekaScrewDr\indy-ros2-jazzy-indyDCP3";
urdfFile = fullfile(base,"indy_description","urdf_files","indyrp2_v2.urdf");

txt = fileread(urdfFile);
txt = replace(txt, ...
    "file:///home/user/indy-ros2/install/indy_description/share/indy_description/meshes/", ...
    "../meshes/");

robotFile = fullfile(base,"indy_description","urdf_files","indyrp2_v2_fixed.urdf");
fid = fopen(robotFile,'w');
fwrite(fid,txt);
fclose(fid);

%% Import Robot and Demonstrate Impedance
robotFile = fullfile(base,"indy_description","urdf_files","indyrp2_v2_fixed.urdf");
neuromeka = importrobot(robotFile, DataFormat="column");
neuromeka.Gravity = [0 0 -9.8067];

% Show link names and bodies
neuromeka.BodyNames'
showdetails(neuromeka)

% Set robot home position
% q_home = [0.00 -15.01 0.00 -90.02 -0.01 -75.00 0.00]'*pi/180;  % Obtained from the lab and manufacturer
q_home = [10, -18, 17, -104, 42, 43, 51]'*pi/180;  % Obtained from computing KINOVA equivalent

% NMPC-computed joint configuration (singularity-free, tested)
q_nmpc = [1.1315, 1.9696, -0.0300, -2.2275, 3.0331, 2.8824, 3.0543]';


show(neuromeka, q_home, 'PreservePlot', false, 'Frames', 'off');
hold on
% axis auto;
view(150, 29) % view(20, 10) or view(135, 25), view(45, 10), view(160, 10)
xlim([-1 1]); ylim([-1 1]); zlim([0 1.2]);

% There must be some damping in the actual manipulator, but typically this is not a known quantity. 
% Here we assume the following value for joint damping 
% (this is a very small value but it can help stabilize the robot model during simulation).
jointDamping = 0.001; % [Nm/rad/s]

gik = generalizedInverseKinematics(RigidBodyTree=neuromeka, ...
    ConstraintInputs={'pose','jointbounds'});
gik.SolverParameters.AllowRandomRestart = false;

% set joint constraints
% Allowing joints 2, 4, 6 to move
% Freezing 1, 3, 5, 7
jointConst = constraintJointBounds(neuromeka);
jointConst.Bounds(1,:) = q_nmpc(1);
jointConst.Bounds(3,:) = q_nmpc(3);
jointConst.Bounds(5,:) = q_nmpc(5);
jointConst.Bounds(7,:) = q_nmpc(7);

% get pose target
eeName = 'tcp';
poseTgt = constraintPoseTarget(eeName);
poseTgt.ReferenceBody = neuromeka.BaseName;

% Surface parameters
p_surface = [-0.30; -0.20; 0.35];  % top of cylinder
screw_axis = [0; 0; -1];           % screw axis: straight down

% --- Screwdriving configuration from NMPC ---
q_nmpc = [1.1315, 1.9696, -0.0300, -2.2275, 3.0331, 2.8824, 3.0543]';

T_nmpc = [-0.4307  -0.9025   0.0001  -0.3000;
          -0.9025   0.4307  -0.0000  -0.1999;
          -0.0000  -0.0001  -1.0000   0.3600;
                0        0        0   1.0000];

% Use NMPC pose
q_init = q_nmpc;
q0 = q_init;

% Start 5cm above surface
task_init = T_nmpc;
task_init(3,4) = 0.40;  % start at z = 0.40

% Set obstacle z-position (plate top surface)
objectPos = 0.2;  % Cartesian Joint Pz value — plate center

% Depth of ingress past the plate surface (same pattern as original)
depthOfIngress = 0.05;  % 5cm past plate

% Set goal BELOW the plate (just like original pushed past the wall)
task_goal = task_init;
task_goal(3,4) = objectPos - depthOfIngress;  % z = 0.15

% assign target transform to pose
poseTgt.TargetTransform = task_goal;

% IK solve
[q_goal, solnInfo] = gik(q_init, poseTgt, jointConst);

%% If necessary, uncomment to visualize the robot 
% Visualize goal configuration
% show(neuromeka, q_goal);
% view(150,29)
% xlim([-1 1]); ylim([-1 1]); zlim([0 1.2]);

figure
ax = axes;

% Draw initial configuration (NMPC start pose)
show(neuromeka, q_init, 'Parent', ax);
hold on

% Draw goal configuration
show(neuromeka, q_goal, 'Parent', ax);
view(150,29)
xlim([-1 1]); ylim([-1 1]); zlim([0 1.2]);

% Make the first robot transparent
patchHandles = findobj(ax, 'Type', 'Patch');
set(patchHandles(1:floor(end/2)), 'FaceAlpha', 0.18)


tStart = 0.5;
tEnd = 5;

q0 = q_init; % q0 is the parameter used in the Multibody model joint blocks, to initialize the robot pose


% Trajectory is implemented in Simulink® using Transform Trajectory block.
% The Transform Trajectory block generates an interpolated trajectory between two homogenous transformation matrices.


%% Impedance Control Model
% Impedance control is a type of indirect force control at which we do not specify the forces to be applied by end-effector.
% Instead the interaction between the end-effector and environment is modeled as spring-mass-damper system. 

% discrete controller time step 
Ts = 0.001; 

% In the figure above, Go, Gc, and Gt are the co-stifness parameters, 
% and they are calculated in the block mask Initialization section, using a helper function, as below.


%% SCREW-SUBSTRATE INTERACTION PARAMETERS
% ======================================
% Values are either:
% 1) directly cited from standards/literature, or
% 2) physically justified for simulation use

%% PHYSICAL PARAMETERS

% --- Screw geometry (ISO 261 + Manyar et al. 2025) ---
screw_type         = 'M5';
screw_pitch        = 0.8e-3;      % [m/rev] M5 coarse thread pitch
screw_diameter     = 5.0e-3;      % [m] nominal diameter
screw_length       = 20.0e-3;     % [m] screw length
screw_major_radius = 2.5e-3;      % [m] major/crest radius
screw_minor_radius = 2.013e-3;    % [m] minor/root radius
helix_angle        = atan(screw_pitch/(pi*screw_diameter));   % [rad]

% --- Friction model (Wang et al. 2022, Eq. 11) ---
% Simplified friction model:
% tau_friction = c_f * d_s * F_axial
% Thread geometry effects are neglected at this stage.
c_f = 0.20;                       % [-] friction coefficient
d_s = screw_diameter;             % [m] nominal screw diameter

% --- Physical contact model ---
% Tang/Wang stiffness values are controller gains, not physical contact stiffness.
% This contact stiffness is a physically justified simulation-scale value for
% metal-on-metal interaction, chosen to be realistic yet numerically tractable.
K_contact = 1e5;                  % [N/m] physical contact stiffness
D_contact = 100;                  % [N*s/m] chosen damping, scaled for stability

% --- Desired axial contact force during engagement ---
% Tang 2023 used ~1 N for a mounting/search phase.
% For M5 engagement, a larger axial force is more realistic.
F_contact_mounting = 20;          % [N] axial engagement force

%% CONTROLLER PARAMETERS (Tang 2023 reference values)
% These are controller gains, not physical material properties.
K_impedance  = 50;                % [N/m] impedance stiffness
Kd_impedance = 200;               % [N*s/m] impedance damping
Mo_impedance = 10;                % [kg] virtual mass

%% TASK PARAMETERS

% --- Torque-angle phase parameters (Wang et al. 2022, Fig. 4) ---
% Scenario-based approximations, not universal screw laws.
theta_total           = deg2rad(3680);   % [rad] total rotation
theta_clamping_angle  = deg2rad(140);    % [rad] clamping angle
prevailing_torque_ratio = 0.40;          % [-] prevailing / nominal torque ratio

%% WORKSPACE / TASK SETUP
screwPos  = p_surface;            % [m] screw location in workspace
screw_axis = [0; 0; -1];          % unit axis

%% CLEAN COMMAND WINDOW SUMMARY
fprintf('\n============================================================\n');
fprintf('SCREW-SUBSTRATE PARAMETERS LOADED\n');
fprintf('============================================================\n');

fprintf('Physical:\n');
fprintf('  Screw Type            : %s\n', screw_type);
fprintf('  Pitch                 : %.3f mm/rev\n', screw_pitch*1e3);
fprintf('  Diameter              : %.3f mm\n', screw_diameter*1e3);
fprintf('  Length                : %.1f mm\n', screw_length*1e3);
fprintf('  Major Radius          : %.3f mm\n', screw_major_radius*1e3);
fprintf('  Minor Radius          : %.3f mm\n', screw_minor_radius*1e3);
fprintf('  Helix Angle           : %.2f deg\n', rad2deg(helix_angle));
fprintf('  Friction Coefficient  : %.2f\n', c_f);
fprintf('  Contact Stiffness     : %.2e N/m\n', K_contact);
fprintf('  Contact Damping       : %.2f N*s/m\n', D_contact);
fprintf('  Engagement Force      : %.2f N\n', F_contact_mounting);

fprintf('\nController (reference values):\n');
fprintf('  K_impedance           : %.2f N/m\n', K_impedance);
fprintf('  Kd_impedance          : %.2f N*s/m\n', Kd_impedance);
fprintf('  Mo_impedance          : %.2f kg\n', Mo_impedance);

fprintf('\nTask:\n');
fprintf('  Total Rotation        : %.1f deg\n', rad2deg(theta_total));
fprintf('  Clamping Angle        : %.1f deg\n', rad2deg(theta_clamping_angle));
fprintf('  Prevailing Torque Rat.: %.1f %%\n', 100*prevailing_torque_ratio);

fprintf('============================================================\n\n');


%% Simulation
% obstacle position
%objectPos = 0.8 - 0.01*t;

mdl = "CartesianImpedanceCtrlForUse"; 
open_system(mdl);
open_system(mdl+"/indyrp2_v2_fixed.urdf/Scope");

% Double-check variable existence before simulation
varsToCheck = ["q0","tStart","tEnd","jointDamping","objectPos","q_goal","Kp","Kd"];

for i = 1:length(varsToCheck)
    if evalin('base', sprintf("exist('%s','var')", varsToCheck(i)))
        fprintf("✔ %s exists\n", varsToCheck(i));
    else
        fprintf("✘ %s MISSING\n", varsToCheck(i));
    end
end

oldFolder = pwd;
cd(fileparts(robotFile))

mdl = 'CartesianImpedanceCtrlForUse';

joints = {'joint0','joint1','joint2','joint3','joint4','joint5','joint6'};

for i = 1:7
    blk = [mdl '/indyrp2_v2_fixed.urdf/' joints{i}];
    set_param(blk,'JointMode','Normal');
end


% === CASE SELECTION FOR COMPARISON ===
% Set to 0 for baseline, 1 for force-augmented
clear screwPhaseManager
use_force_feedback = 1;  % Change to 0 for Case A (baseline)
Kf_gain = 100;           % Force feedback gain (only used when use_force_feedback = 1)


in = helperSetSimscapeInitialPose(mdl, q0);
out = sim(in);

open_system(mdl+"/indyrp2_v2_fixed.urdf/Scope");

%% Save results for Data Visualization and Plotting
% Run Passive simulation

% logsout_passive = out.logsout;
% tout_passive = out.tout;
% save('passive_results.mat', 'logsout_passive', 'tout_passive');

%% Run Active simulation
% logsout_active = out.logsout;
% tout_active = out.tout;
% save('active_results.mat', 'logsout_active', 'tout_active');

%% Other data points

% logsout_Kf01 = out.logsout;
% tout_Kf01 = out.tout;
% save('results_Kf01.mat', 'logsout_Kf01', 'tout_Kf01');
% 
% logsout_Kf08 = out.logsout;
% tout_Kf08 = out.tout;
% save('results_Kf08.mat', 'logsout_Kf08', 'tout_Kf08');

% logsout_Kf5 = out.logsout;
% tout_Kf5 = out.tout;
% save('results_Kf5.mat', 'logsout_Kf5', 'tout_Kf5');

logsout_Kf100 = out.logsout;
tout_Kf100 = out.tout;
save('results_Kf100.mat', 'logsout_Kf100', 'tout_Kf100');