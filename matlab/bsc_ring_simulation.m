% Copyright (c) 2015 by the author(s)
%
% This program is free software: you can redistribute it and/or modify it
% under the terms of the GNU Lesser General Public License as published by
% the Free Software Foundation, either version 3 of the License, or (at your
% option) any later version.
% 
% This program is distributed in the hope that it will be useful, but
% WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY
% or FITNESS FOR A PARTICULAR PURPOSE. See the GNU Lesser General Public License
% for more details.
% 
% You should have received a copy of the GNU Lesser General Public License along
% with this program.  If not, see http://www.gnu.org/licenses/.
% 
% Author(s):
%   Michael Vonbun	(michael.vonbun@tum.de)
%

function [  ] = bsc_ring_simulation( varargin )
%BSC_RING_SIMULATION Simulate the ring topologies based on the bsc model.
%
% Syntax:
%   bsc_ring_simulation( N, F, B, L )
%       N : ring size
%       F : number of flits
%       B : number of bits per flit
%       L : link sweep error probabilities

% Main function call
%   [POut, tOut] = ...
%       bsc_based_noc_com( N, F, B, R, L, [ topology, routes, log] )


%% inputs
scaleFactor = 1/3;
if nargin >= 4
    N = varargin{1};
    F = varargin{2};
    B = varargin{3};
    L = varargin{4};
end

if nargin == 5
    scaleFactor = varargin{5};
end

if nargin < 4
    fprintf(2, 'Not enough input arguments, using defaults instead.\n');
    N = 8;
    F = 8;
    B = 32;
    L = 10.^[-4:-1:-15];
end

R = [];

szL = length(L);


%% calculations
[POutRingUni, tOutRingUni] = bsc_based_noc_com( N, F, B, R, L, 'ring uni' );
[POutRingBi, tOutRingBi] = bsc_based_noc_com( N, F, B, R, L, 'ring bi' );
[POutRingDouble, tOutRingDouble] = bsc_based_noc_com( N, F, B, R, L, 'double ring' );


%% write plot files
saveFilename = sprintf('_%d_%d_%d', N, B, F );

fidRingUni = fopen(['bscRingUni', saveFilename, '.plot'], 'w+');
fidRingBi = fopen(['bscRingBi', saveFilename, '.plot'], 'w+');
fidRingDouble = fopen(['bscRingDouble', saveFilename, '.plot'], 'w+');


%% unidirectional ring
fprintf(fidRingUni, '%10s %7s %17s %17s %17s %17s\n',...
    'tSim', 'pout', 'hopMax', 'hopMean', 'hopMaxScaled', 'hopMeanScaled' );

% compute maximum and mean hop communication pairs
r = getRoutes_ring_unidirectional(N);
szr = zeros(size(r));

for k = 1:size(r, 1)
    for l = 1:size(r, 2)
        szr(k, l) = length(r{k, l});
    end
end

[~, idx] = max(szr(:));
[maxConFrom, maxConTo] = ind2sub(size(szr), idx);

meanHops = round(mean(mean(szr-1)));
[meanConFrom, meanConTo] = find((szr-1) == meanHops, 1);

% data write out
POutRingUniHopMax = zeros(1, szL);
POutRingUniHopMean = zeros(1, szL);

for k = 1:szL
    
    POutRingUniHopMax(k) = POutRingUni{k}(maxConFrom, maxConTo);
    POutRingUniHopMean(k) = POutRingUni{k}(meanConFrom, meanConTo);
    
    fprintf(fidRingUni, '%5.4e ', tOutRingUni(k));
    fprintf(fidRingUni, '%2.1e ', L(k));
    fprintf(fidRingUni, '%12.11e ', POutRingUniHopMax(k));
    fprintf(fidRingUni, '%12.11e ', POutRingUniHopMean(k));
    fprintf(fidRingUni, '%12.11e ', POutRingUniHopMax(k) .^ scaleFactor);
    fprintf(fidRingUni, '%12.11e ', POutRingUniHopMean(k) .^ scaleFactor);
    
    fprintf(fidRingUni, '\n');
    
end


%% bidirectional ring
fprintf(fidRingBi, '%10s %7s %17s %17s %17s %17s\n',...
    'tSim', 'pout', 'hopMax', 'hopMean', 'hopMaxScaled', 'hopMeanScaled' );

% compute maximum and mean hop communication pairs
r = getRoutes_ring_bidirectional(N);
szr = zeros(size(r));

for k = 1:size(r, 1)
    for l = 1:size(r, 2)
        szr(k, l) = length(r{k, l});
    end
end

[~, idx] = max(szr(:));
[maxConFrom, maxConTo] = ind2sub(size(szr), idx);

meanHops = round(mean(mean(szr-1)));
[meanConFrom, meanConTo] = find((szr-1) == meanHops, 1);

% data write out
POutRingBiHopMax = zeros(1, szL);
POutRingBiHopMean = zeros(1, szL);

for k = 1:szL
    
    POutRingBiHopMax(k) = POutRingBi{k}(maxConFrom, maxConTo);
    POutRingBiHopMean(k) = POutRingBi{k}(meanConFrom, meanConTo);
    
    fprintf(fidRingBi, '%5.4e ', tOutRingBi(k));
    fprintf(fidRingBi, '%2.1e ', L(k));
    fprintf(fidRingBi, '%12.11e ', POutRingBiHopMax(k));
    fprintf(fidRingBi, '%12.11e ', POutRingBiHopMean(k));
    fprintf(fidRingBi, '%12.11e ', POutRingBiHopMax(k) .^ scaleFactor);
    fprintf(fidRingBi, '%12.11e ', POutRingBiHopMean(k) .^ scaleFactor);
    
    fprintf(fidRingBi, '\n');
    
end


%% double ring
fprintf(fidRingDouble, '%10s %7s %17s %17s %17s %17s\n',...
    'tSim', 'pout', 'hopMax', 'hopMean', 'hopMaxScaled', 'hopMeanScaled' );

% compute maximum and mean hop communication pairs
r = getRoutes_ring_double(N);
szr = zeros(size(r));

for k = 1:size(r, 1)
    for l = 1:size(r, 2)
        szr(k, l) = length(r{k, l});
    end
end

[~, idx] = max(szr(:));
[maxConFrom, maxConTo] = ind2sub(size(szr), idx);

meanHops = round(mean(mean(szr-1)));
[meanConFrom, meanConTo] = find((szr-1) == meanHops, 1);

% data write out
POutRingDoubleHopMax = zeros(1, szL);
POutRingDoubleHopMean = zeros(1, szL);

for k = 1:szL
    
    POutRingDoubleHopMax(k) = POutRingDouble{k}(maxConFrom, maxConTo);
    POutRingDoubleHopMean(k) = POutRingDouble{k}(meanConFrom, meanConTo);
    
    fprintf(fidRingDouble, '%5.4e ', tOutRingDouble(k));
    fprintf(fidRingDouble, '%2.1e ', L(k));
    fprintf(fidRingDouble, '%12.11e ', POutRingDoubleHopMax(k));
    fprintf(fidRingDouble, '%12.11e ', POutRingDoubleHopMean(k));
    fprintf(fidRingDouble, '%12.11e ', POutRingDoubleHopMax(k) .^ scaleFactor);
    fprintf(fidRingDouble, '%12.11e ', POutRingDoubleHopMean(k) .^ scaleFactor);
    
    fprintf(fidRingDouble, '\n');
    
end


%% close plot files
fclose(fidRingUni);
fclose(fidRingBi);
fclose(fidRingDouble);


end

