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

% --- This script calculates the results for an 8-by-8 2D-mesh used for the
% submisstion:
% "An Analytic Approach on End-to-end Packet Error Rate Estimation for 
% Network-on-Chip" at 2015 Euromicro DSD/SEAA


%% --- compute the routes using xy-routing;
tic
N = 8;
numRouters = N^2;
% NOTE: matlab's default matrix index enumeration is column-wise and starts
% with index 1. E.g. the mesh index structure for a 3x3 mesh is
% 1 - 4 - 7
% 2 - 5 - 8
% 3 - 6 - 9
% -- cycle through all combinations of sources and destiniations;
routes = cell(numRouters, numRouters);    % alloc empty cell structure
%    as routes differ, src -- dest ~= dest -- src
for src = 1:numRouters
    for dest = 1:numRouters
        
        pos = src;                                      % position at the beginning of each connection
        [rowPos, colPos] = ind2sub( [N, N], pos);       % current position (source) row and column index
        [rowDest, colDest] = ind2sub( [N, N], dest);    % destination row and column index
        
        while pos ~= dest
            
            routes{src, dest} = [routes{src, dest}, pos];   % add current position to route

            % -- decrease the column (X) distance first
            if colPos ~= colDest
                if colDest > colPos
                    colPos = colPos + 1;    % go right
                else
                    colPos = colPos - 1;    % go left
                end
                
            % -- decrease the row (Y) distance next
            elseif rowPos ~= rowDest
                if rowDest > rowPos
                    rowPos = rowPos + 1;    % go up
                else
                    rowPos = rowPos - 1;    % go down
                end
            end
            
            pos = sub2ind( [N, N], rowPos, colPos); % update position
        end
        
        routes{src, dest} = [routes{src, dest}, dest];  % finally add the destination to the route
        
    end
end


%% NoC router ids
noc_idx = reshape( [1:numRouters] - 1, N, N);
% clc
noc_idx = noc_idx';
matlab_idx = reshape( [1:numRouters], N, N);

tSetup = toc;


%% --- analytical calculation : hops, no bg
tic
% clc;
disp('nobg')
B = 32;

% F = 8
for l = [2, 4, 8, 16]
    F = l;

LOut = 10.^[-6:-1:-10];
SRC = 1;
DEST = [ 9; 25; matlab_idx(2:2:end, 5)]';

POut = zeros(1, length(DEST));
for k = 1:length(LOut)
    
    LSucc = 1 - LOut(k);
    ROut = LOut(k);
    RSucc = LSucc;
    
    for ksrc = 1:length(SRC)
        src = SRC(ksrc);
        for kdest = 1:length(DEST)
            dest = DEST(kdest);
            
            % compute success probability
            POut(kdest) = 1 - ( ( 1 + ...
                (2 * RSucc - 1) .^ (2*length(routes{src, dest})) .* ...
                (2 * LSucc - 1) .^ (length(routes{src, dest})-1) )./2 ).^(B*F);
            
        end
    end
    
    if F == 8
    POut(end)
    end
    
end
end

tNobg = toc;


%% --- bg: hops and packet size results
clc;
disp('bg')
tic;
B = 32;

LOut = 10.^[-5:-1:-8];
packetSizes = [2, 4, 8, 16];
SRC = 1;
DEST = [ 9; 25; matlab_idx(2:2:end, 5)]'; % 40

pSucc = zeros( length(SRC), length(DEST));  % mem alloc array for success probabilities
POut = zeros(length(packetSizes), length(DEST), length(LOut));

% - heatmap
% heatmap = ones(size(R.heatmap));        % no heatmap (i.e. all routers have service time of 1 (no bg traffic)
load('heatmap_euromicroDSDSEAA');       % get heatmap extracted from a quick Omnett++ run

for kpasi = 1:length(packetSizes)
    F = packetSizes(kpasi);     % current packet size
    
    for kdest = 1:length(DEST)
        % current source and destination
        src = SRC;          % only 1 source, but could be extended easily
        dest = DEST(kdest); % current destination
        
        for klout = 1:length(LOut)
            % compute current link and router error probabilities
            LSucc = 1 - LOut(klout);
            ROut = 1 - ( LSucc ) .^ heatmap;
            RSucc = 1 - ROut;
            
            % compute error probability
            if src ~= dest
                POut(kpasi, kdest, klout) = 1 - ( ( 1 + ...
                    prod( (2 * RSucc(routes{src, dest}) - 1) ) .* ...
                    prod( (2 * RSucc(routes{src, dest}) - 1) ) .* ...
                    (2 * LSucc - 1) .^ (length(routes{src, dest})-1) )./2 ).^(B*F);
                
            end
        end
    end
end

tBg = toc;


%% hops
fid = fopen('hop_analytic.plot', 'w+');

% column headers
fprintf(fid, '%6s %11s %4s ', 'source', 'destination', 'hops');
for k = 1:size(POut, 3)
    fprintf(fid, '%14s ', sprintf('POut%1.0e', L(k)));
end
fprintf(fid, '\n');

% values
for kdest = 1:size(POut, 2)
    fprintf(fid, '% 6d ', SRC);
    fprintf(fid, '% 11d ', DEST(kdest));
    fprintf(fid, '% 4d ', length(routes{SRC, DEST(kdest)}));
    for k = 1:size(POut, 3)
        fprintf(fid, '%9.8e ', POut(3, kdest, k)); % packet size is fixed to 8 flits here (index 3, see above)
    end
    
    fprintf(fid, '\n');
end

fclose(fid);


%% packetsize
fid = fopen('packetsize_analytic.plot', 'w+');

% column headers
fprintf(fid, '%10s ', 'packetsize');
for k = 1:size(POut, 3)
    fprintf(fid, '%14s ', sprintf('POut%1.0e', L(k)));
end
fprintf(fid, '\n');

% values
for kpasi = 1:size(POut, 1)
    fprintf(fid, '% 10d ', packetSizes(kpasi));
    for k = 1:size(POut, 3)
        fprintf(fid, '%9.8e ', POut(kpasi, size(POut, 2), k)); % destination is fixed (longest path)
    end
    
    fprintf(fid, '\n');
end

fclose(fid);


%% console output
fprintf(1, '*** The calculation times are\n');
fprintf(1, '*** \tSetup         : %f seconds\n', tSetup);
fprintf(1, '*** \tNoBg (+Setup) : %f (%f) seconds\n', tNobg, tNobg + tSetup);
fprintf(1, '*** \tBg (+Setup)   : %f (%f) seconds\n', tBg, tBg + tSetup);












































