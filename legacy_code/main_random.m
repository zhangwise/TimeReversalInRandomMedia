%% Propagation of time-harmonic waves in a random medium.
clc; clear all; close all; 

%%% Constants
h = .1; % Longitudinal (along z) step size
zc = 1;
xc = 4;
sigma = 1;
L = 10; % Position of mirror
k = 1; % Frequency ?
omega = 1; % Frequency
r0 = 2; % Gaussian beam radius
N = 2^10 + 1; % Number of points for discretization
xmax = 60;

x = linspace(-xmax/2, xmax/2, N)';
dx = xmax /(N - 1);
fmax = 1/2/dx;
f = 2 * pi .* linspace(-fmax, fmax, N);

u0 = exp(-x.^2/r0^2); % Initial profile

rM = 2;
mirror = exp(-x.^2/rM^2); % Gaussian mirror profile

%% simulate GP;
nb_MC = 100; % Number of profiles to be averaged
nb_GP = round(L / zc); % Number of Gaussian processes

U_L = zeros(nb_MC, N); % Transmitted wave profile
U_0_rand = zeros(nb_MC, N); % Refocused wave profile random medium
U_0_homo = zeros(nb_MC, N); % Refocused wave profile homogeneous medium
for i = 1:nb_MC
    GP_seq = sample_GP(x, sigma, xc, nb_GP);
    
    % Go forward in random medium
    U_L(i,:) = split_step_fourier_method(0, 1, round(L/h) - 1, u0, h, k, f, GP_seq);
    
    % Go reverse in same random medium
    %u = conj(mean_wave_L) .* mirror;
    u = conj(U_L(i,:)') .* mirror;
    U_0_rand(i,:) = split_step_fourier_method(round(L/h) - 1, -1, 0, u, -h, k, f, GP_seq);
    
    % Go reverse in homogeneous medium
    %u = conj(U_L(i,:)') .* mirror;
    %U_0_homo(i,:) = split_step_fourier_method(round(L/h) - 1, -1, 0, u, h, k, f);
end
U_L = mean(U_L, 1)';
U_0_rand = mean(abs(U_0_rand), 1)';
U_0_homo = mean(U_0_homo, 1)';


%%% mean refocused wave profile in z=0 (random medium)
atr = (1 -4i * L/k/r0^2 -  4 * L^2/k^2/r0^2/rM^2 - 2i*L/k/rM^2)^0.5;
rtr_square = (1/rM^2 + 1/(r0^2 - 2i * L/k))^(-1) - 2i * L/k;
%atr = sqrt(1 + 4*L^2/(k*r0*rM)^2 + 2*1i*L/k/rM^2);
%rtr_square =(1/rM^2+1/(r0^2-2*1i*L/k))^-1 + 2*1i*L/k;
gamma2 = 2*sigma^2*zc/xc^2;
ra_square = 48/L/gamma2/omega^2;
mean_wave_0_rand = 1/atr * exp(-x.^2/rtr_square) .* exp(-x.^2/ra_square);

%figure(2); plot(x, real(U_0_rand), x, real(mean_wave_0_rand));
figure(3); plot(x, abs(U_0_rand), x, abs(mean_wave_0_rand));
legend('empirical','theoretical')
title('Mean refocused wave profile in random medium')

%% Mean transmitted wave profile
rt = r0*sqrt(1 + 2*1i*L/k/r0^2);
gamma0 = sigma^2*zc;
mean_wave_L = r0/rt * exp(-x.^2/rt^2) * exp(-gamma0*omega^2*L/8);

%mean_wave_L = r0/rt * exp(-x.^2/rt^2);
%figure(1); plot(x, imag(U_L), x, imag(mean_wave_L))
figure(2); plot(x, real(U_L), x, real(mean_wave_L))
figure(3); plot(x, abs(U_L), x, abs(mean_wave_L))

legend('empirical','theoretical')
title('Mean transmitted wave profile in random medium')

%% mean refocused wave profile in z=0 (homogeneous medium)
mean_wave_0_homo = 1/atr * exp(-x.^2/rtr_square) .* exp(-gamma0*omega^2*L/8);
figure(1); plot(x, imag(U_0_homo), x, imag(mean_wave_0_homo));
figure(2); plot(x, real(U_0_homo), x, real(mean_wave_0_homo));
figure(3); plot(x, abs(U_0_homo), x, abs(mean_wave_0_homo));
legend('empirical','theoretical')
title('Mean refocused wave profile in homegeneous medium')

%% Time reversal for time-dependent waves in a random medium.
omega0 = 1;
B = 0.75;
nb_discr = 20;
omega_discr = linspace(omega0-B,omega0+B,nb_discr);

U_L_w = zeros(nb_discr, N); % Transmitted wave profile
U_0_w = zeros(nb_discr, N); % Refocused wave profile random medium

nb_GP = round(L / zc); % Number of Gaussian processes
GP_seq = sample_GP(x, sigma, xc, nb_GP);
for w = 1:nb_discr
    omega = omega_discr(w);
    k = omega_discr(w);

    % Go forward in random medium
    U_L_w(w,:) = split_step_fourier_method(0, 1, round(L/h) - 1, u0, h, k, f, GP_seq);

    % Go reverse in same random medium
    u = conj(U_L_w(w,:)') .* mirror;
    U_0_w(w,:) = split_step_fourier_method(round(L/h) - 1, -1, 0, u, -h, k, f, GP_seq);
end

atr = (1 -4i * L/k/r0^2 -  4 * L^2/k^2/r0^2/rM^2 - 2i*L/k/rM^2)^0.5;
rtr_square = (1/rM^2 + 1/(r0^2 - 2i * L/k))^(-1) - 2i * L/k;
gamma2 = 2*sigma^2*zc/xc^2;
ra_square = 48/(L*gamma2*omega^2);
mean_wave_0_rand = 1/atr * exp(-x.^2/rtr_square) .* exp(-x.^2/ra_square);

U_0_w = mean(U_0_w, 1);
figure(4); plot(x, abs(U_0_w), x, abs(mean_wave_0_rand));
legend('empirical','theoretical')
title('Refocused time-dependent waves in random medium')