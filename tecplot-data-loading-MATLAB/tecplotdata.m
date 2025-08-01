clc;
clear;
close all;
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% TECPLOT DATA ANALYSIS - TIME AVERAGED RESULTS
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% 
% This script processes and analyzes CFD data from Tecplot output files and 
% turbine performance data to calculate key performance metrics including:
% - Power and thrust coefficients (Cp, Ct)
% - Axial induction factors
% - Velocity fields and deficits
% - Statistical analysis of turbine performance
%
% Author: Hossein Seyedzadeh
% Last updated: June 27, 2025
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Start the timer
tic;

%% 1. PHYSICAL CONSTANTS AND PARAMETERS
% Physical constants
rho = 998;                % Water density [kg/m^3]
nu = 1.0e-6;              % Kinematic viscosity of water [m^2/s]

% Geometry parameters
D = 0.2794;               % Rotor diameter [m]
R = D/2;                  % Rotor radius [m]
A = pi * R^2;             % Rotor swept area [m^2]
TSR = 4.8;                % Tip speed ratio (absolute value)

% Domain parameters
Lx = 2.2;                 % Domain length in x [m]
Ly = 2.2;                 % Domain length in y [m]
U_inf = 0.82;             % Reference velocity [m/s]

%% 2. TECPLOT FILE PARAMETERS
filename = 'tecplot-output.dat';  % <-- change to your actual file name
Nx = 101;                 % Grid points in x
Ny = 101;                 % Grid points in y
Nz = 313;                 % Grid points in z

% Calculate derived grid parameters
N_node = Nx * Ny * Nz;    % Total number of nodes
N_cell = (Nx-1) * (Ny-1) * (Nz-1);  % Total number of cells

% Define variable names and types
var_names = {
    'X', 'Y', 'Z', ...            % Node-centered variables (positions)
    'U', 'V', 'W', ...            % Cell-centered variables (velocity components)
    'uu', 'vv', 'ww', ...         % Reynolds stresses
    'uv', 'vw', 'uw', ...         % Reynolds stresses (cross terms)
    'K', 'Nv'                     % Turbulence kinetic energy and eddy viscosity
};
num_vars = length(var_names);
num_nodevars = 3;         % Number of node-centered variables
num_cellvars = num_vars - num_nodevars;  % Number of cell-centered variables

%% 3. LOAD TECPLOT DATA
fprintf('Loading Tecplot data from: %s\n', filename);

% Open and read the file
fid = fopen(filename, 'r');
if fid == -1
    error('❌ Failed to open file: %s', filename);
end

% Read all lines as text
lines = textscan(fid, '%s', 'Delimiter', '\n');
fclose(fid);
lines = lines{1};

% Find where numeric data starts (skip header)
data_start_idx = find(~cellfun(@isempty, regexp(lines, '^[\s\-0-9\.E\+]+$')), 1);
data_lines = lines(data_start_idx:end);
fprintf('  Skipped %d header lines\n', data_start_idx-1);

% Convert text data to numbers
data_str = strjoin(data_lines, ' ');
data_numbers = sscanf(data_str, '%f');

% Validate data length
expected_length = num_nodevars * N_node + num_cellvars * N_cell;
if length(data_numbers) < expected_length
    error('❌ Data length mismatch: expected %d, found %d', expected_length, length(data_numbers));
end
fprintf('  Read %d numeric values\n', length(data_numbers));

%% 4. PROCESS TECPLOT DATA
fprintf('Processing Tecplot data...\n');

% Separate data into variables
data = cell(1, num_vars);
offset = 0;

% Extract node-centered variables
for i = 1:num_nodevars
    data{i} = data_numbers(offset + 1 : offset + N_node);
    offset = offset + N_node;
end

% Extract cell-centered variables
for i = num_nodevars+1 : num_vars
    data{i} = data_numbers(offset + 1 : offset + N_cell);
    offset = offset + N_cell;
end

% Reshape node-centered variables into 3D arrays
X = reshape(data{1}, [Nx, Ny, Nz]);
Y = reshape(data{2}, [Nx, Ny, Nz]);
Z = reshape(data{3}, [Nx, Ny, Nz]);

% Reshape cell-centered variables into 3D arrays
U  = reshape(data{4},  [Nx-1, Ny-1, Nz-1]);
V  = reshape(data{5},  [Nx-1, Ny-1, Nz-1]);
W  = reshape(data{6},  [Nx-1, Ny-1, Nz-1]);
uu = reshape(data{7},  [Nx-1, Ny-1, Nz-1]);
vv = reshape(data{8},  [Nx-1, Ny-1, Nz-1]);
ww = reshape(data{9},  [Nx-1, Ny-1, Nz-1]);
uv = reshape(data{10}, [Nx-1, Ny-1, Nz-1]);
vw = reshape(data{11}, [Nx-1, Ny-1, Nz-1]);
uw = reshape(data{12}, [Nx-1, Ny-1, Nz-1]);
K  = reshape(data{13}, [Nx-1, Ny-1, Nz-1]);
Nv = reshape(data{14}, [Nx-1, Ny-1, Nz-1]);

fprintf('✅ Tecplot data successfully loaded.\n');
fprintf('   Grid size: %d x %d x %d (nodes)\n', Nx, Ny, Nz);
fprintf('   Cell-centered size: %d x %d x %d\n', Nx-1, Ny-1, Nz-1);

%% Calculate and display execution time
elapsed_time = toc;
fprintf('\n=== EXECUTION SUMMARY ===\n');
fprintf('Script execution completed successfully.\n');
fprintf('Total execution time: %.3f seconds (%.2f minutes)\n', elapsed_time, elapsed_time/60);
if elapsed_time > 60
    minutes = floor(elapsed_time/60);
    seconds = mod(elapsed_time, 60);
    fprintf('Formatted time: %d minutes %.1f seconds\n', minutes, seconds);
end
fprintf('========================\n');

%% End of script



