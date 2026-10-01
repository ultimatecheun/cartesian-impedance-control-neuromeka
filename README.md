# Cartesian Impedance Control — Neuromeka Indy

Compliant **Cartesian impedance control** for a 7-DOF Neuromeka Indy manipulator, with a full stiffness-sensitivity study and an active-vs-passive comparison. Built in MATLAB, Simulink, and Simscape as part of my dissertation work on safe human–robot interaction.

## Overview

Impedance control lets a robot behave like a programmable spring–damper at its end-effector — essential for contact-rich, human-adjacent tasks like screwdriving, insertion, and guided motion. This project imports the Indy robot from URDF, designs a Cartesian impedance controller, and studies how the closed-loop behavior changes as the feedback stiffness `Kf` is varied.

## What's inside

| File | Purpose |
|------|---------|
| `helperDesignImpedanceControl.m` | Main script — imports the robot, sets the home pose, and designs/demonstrates the impedance controller |
| `CartesianImpedanceCtrlForUse.slx` | Simulink/Simscape model of the closed-loop system |
| `calcCoStiffness.m`, `SkSym.m`, `Tilde.m`, `UnTilde.m` | Math helpers (stiffness computation, skew-symmetric operators) |
| `sensitivityAnalysisVisualization.m` | Sweeps feedback stiffness `Kf` and plots the effect on overshoot & settling |
| `activePassiveVisualization.m`, `overshootPlotVisualization.m` | Comparison and results plots |
| `fig_*.png`, `Kf_*.png` | Generated result figures (sensitivity, comparison) |

> The 7-DOF Indy robot description/URDF this project imports comes from Neuromeka's open-source [indy-ros2](https://github.com/neuromeka-robotics) driver — install it separately and point the script at it (it is **not** bundled here).

## Selected results

- **Stiffness sensitivity:** how end-effector overshoot and steady-state error respond across `Kf ∈ {0.1 … 100}`.
- **Active vs. passive:** side-by-side comparison of the compliant response under each control strategy.

*(See `fig_*.png` and `Kf_*.png` for the generated figures.)*

## Requirements

MATLAB with **Robotics System Toolbox**, **Simulink**, and **Simscape Multibody**.

## Run it

```matlab
% From the repo root, in MATLAB:
helperDesignImpedanceControl      % imports robot, designs & demonstrates the controller
sensitivityAnalysisVisualization  % reproduces the Kf sensitivity study
```

## Attribution

The 7-DOF Indy robot description (URDF/meshes) used by this project is from Neuromeka's open-source [indy-ros2](https://github.com/neuromeka-robotics) project and retains its original license (referenced, not redistributed here). All impedance-control design, analysis, and Simulink modeling are my own.

## Author

**Oluwaseun A. Adekoya** — Robotics Engineer & PhD Candidate, University of Cincinnati.
Part of my research on safe human–robot collaboration. License: MIT (my code).
