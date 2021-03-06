function [sol_eq, sol_i_eq, ssol_eq, ssol_i_eq, sol_i_eq_SR, ssol_i_eq_SR, ssol_i_1S_SR ] = equilibrate
% Uses analytical initial conditions and runs to equilibrium
% Note that tmax is consistently adjusted to appropriate values for to
% ensure there are numerous mesh points where large gradients in the time
% dimension are present

tic;    % Start stopwatch

%% Initial arguments
% Setting sol.sol = 0 enables a parameters structure to be read into
% pindrift but indicates that the initial conditions should be the
% analytical solutions
sol.sol = 0;    

p = pinParams;

% Store initial mobility of intrinsic layer- note all mobilities will be
% set to this value during the equilibration procedure.
mue_i = p.mue_i;          % electron mobility
muh_i = p.muh_i;      % hole mobility
mue_p = p.mue_p;
muh_p = p.muh_p;
mue_n = p.mue_n;
muh_n = p.muh_n;
mui = p.mui;    % Ion mobility

%% Start with low recombination coefficients
p.klin = 0;
p.klincon = 0;
p.taun_etl = 1e6;       % [s] SRH time constant for electrons
p.taup_etl = 1e6;      % [s] SRH time constant for holes
p.taun_htl = 1e6;       %%%% USE a high value of (e.g.) 1 to switch off
p.taup_htl = 1e6;

% Raditative recombination could also be set to low values initially if required. 
% p.krad = 1e-20;
% p.kradetl = 1e-20;
% p.kradhtl = 1e-20;

%% General initial parameters
p.tmesh_type = 2;
p.tpoints = 200;

p.Ana = 0;
p.JV = 0;
p.Vapp = 0;
p.Int = 0;
p.pulseon = 0; 
p.OC = 0;
p.BC = 1;
p.tmesh_type = 2;
p.tmax = 1e-9;
p.t0 = p.tmax/1e4;

%% Switch off mbilities
p.mue_i = 0;          % electron mobility
p.muh_i = 0;      % hole mobility
p.mue_p = 0;
p.muh_p = 0;
p.mue_n = 0;
p.muh_n = 0;
p.mui = 0;

%% Initial solution with zero mobility
disp('Initial solution, zero mobility')
sol = pindrift(sol, p);
disp('Complete')

% Switch on mobilities
p.mue_i = mue_i;          % electron mobility
p.muh_i = muh_i;      % hole mobility
p.mue_p = mue_p;
p.muh_p = muh_p;
p.mue_n = mue_n;
p.muh_n = muh_n;
p.mui = mui;

p.figson = 1;
p.tmax = 1e-9;
p.t0 = p.tmax/1e3;

%% Soluition with mobility switched on
disp('Solution with mobility switched on')
sol = pindrift(sol, p);

p.Ana = 1;
p.calcJ = 0;
p.tmax = 1e-2;
p.t0 = p.tmax/1e10;

sol_eq = pindrift(sol, p);
disp('Complete')

%% Set up solution for open circuit
disp('Switching boundary conditions to zero flux')
%p.Ana = 0;
p.BC = 0;
p.tmax = 1e-9;
p.t0 = p.tmax/1e3;

sol = pindrift(sol_eq, p);
disp('Complete')

%% Symmetricise the solution
disp('Symmetricise solution for open circuit')
symsol = symmetricize(sol);
disp('Complete')

%% Equilibrium solution with mirrored cell and OC boundary conditions, mobility zero
disp('Initial equilibrium open circuit solution')
p.BC = 1;
p.OC = 1;
p.calcJ = 0;

%% Switch off mbilities
p.mue_i = 0;          % electron mobility
p.muh_i = 0;      % hole mobility
p.mue_p = 0;
p.muh_p = 0;
p.mue_n = 0;
p.muh_n = 0;
p.mui = 0;

ssol = pindrift(symsol, p);
disp('Complete')

%% OC with mobility switched on
disp('Open circuit solution with mobility switched on')
p.tmax = 1e-6;
p.t0 = p.tmax/1e3;
% Switch on mobilities
p.mue_i = mue_i;          % electron mobility
p.muh_i = muh_i;      % hole mobility
p.mue_p = mue_p;
p.muh_p = muh_p;
p.mue_n = mue_n;
p.muh_n = muh_n;
p.mui = 0;

ssol = pindrift(ssol, p);

% Longer time step to ensure equilibrium has been reached
p.tmax = 1e-2;
p.t0 = p.tmax/1e3;

ssol_eq = pindrift(ssol, p);
disp('Complete')

%% Equilibrium solutions with ion mobility switched on
%% Closed circuit conditions
disp('Closed circuit equilibrium with ions')

p.OC = 0;
p.tmax = 1e-9;
p.t0 = p.tmax/1e3;
p.mui = 1e-6;           % Ions are accelerated to reach equilibrium

sol = pindrift(sol_eq, p);

% Much longer second step to ensure that ions have migrated
p.calcJ = 2;
p.tmax = 1e-2;
p.t0 = p.tmax/1e3;

sol_i_eq = pindrift(sol, p);
disp('Complete')

%% Ion equilibrium with surface recombination
disp('Switching on surface recombination')
p.taun_etl = 1e-10;
p.taup_etl = 1e-10;
p.taun_htl = 1e-10;
p.taup_htl = 1e-10; 

p.calcJ = 0;
p.tmax = 1e-6;
p.t0 = p.tmax/1e3;

sol_i_eq_SR = pindrift(sol_i_eq, p);
disp('Complete')

% Switch off SR
p.taun_etl = 1e6;
p.taup_etl = 1e6;
p.taun_htl = 1e6;
p.taup_htl = 1e6; 

%% Symmetricise closed circuit condition
disp('Symmetricise equilibriumion solution')
symsol = symmetricize(sol_i_eq);
disp('Complete')

p.OC = 1;
p.tmax = 1e-9;
p.t0 = p.tmax/1e3;

%% Switch off mbilities
p.mue_i = 0;          % electron mobility
p.muh_i = 0;      % hole mobility
p.mue_p = 0;
p.muh_p = 0;
p.mue_n = 0;
p.muh_n = 0;
p.mui = 0;

%% OC condition with ions at equilbirium
disp('Open circuit equilibrium with ions')
ssol = pindrift(symsol, p);

p.tmax = 1e-9;
p.t0 = p.tmax/1e3;

% Switch on mobilities
p.mue_i = mue_i;          % electron mobility
p.muh_i = muh_i;      % hole mobility
p.mue_p = mue_p;
p.muh_p = muh_p;
p.mue_n = mue_n;
p.muh_n = muh_n;
p.mui = 0;

ssol = pindrift(ssol, p);

% Switch on ion mobility to ensure equilibrium has been reached
p.tmax = 1e-9;
p.t0 = p.tmax/1e3;
p.mui = 1e-6;

ssol = pindrift(ssol, p);

p.tmax = 1e-2;
p.t0 = p.tmax/1e3;

ssol_i_eq = pindrift(ssol, p);

disp('Complete')

%% Ions, OC Surface recombination
p.taun_etl = 1e-10;
p.taup_etl = 1e-10;
p.taun_htl = 1e-10;
p.taup_htl = 1e-10; 

p.tmax = 1e-3;
p.t0 = p.tmax/1e6;

ssol_i_eq_SR = pindrift(ssol_i_eq , p);

%% 1 Sun quasi equilibrium
disp('1 Sun quasi equilibrium')
tmax = 1e-3;
p.t0 = p.tmax/1e6;
p.Int = 1;

ssol_i_1S_SR = pindrift(ssol_i_eq_SR, p);

disp('Complete')


disp('EQUILIBRATION COMPLETE')
toc

end
