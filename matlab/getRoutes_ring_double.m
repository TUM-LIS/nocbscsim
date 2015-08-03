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

function [ routes ] = getRoutes_ring_double( N )
%GETROUTES_RING_DOUBLE Compute the routes for all
% source-destination pairs in a double ring network.
%
% Syntax:
%   [ routes ] = getRoutes_ring_double( N )
%       Returns an 2N x 2N cell array for every pair of routers in a
%       network with 2 unidirectional rings with N routers each.
%
%   [ routes ] = getRoutes_ring_double( [N, M] )
%       Returns an (N + M) x (N + M) cell array for every pair of routers 
%       in a network with 2 unidirectional rings with N and M routers.
%

%% variable assignment
tmp = N .* [1, 1];                      % ensure that tmp is a 2-element vector; either [N, M] or [N, N]
N = tmp(1);                             % assign N
M = tmp(2);                             % assign M
numRouters = N + M;                     % number of routers in a 2D-mesh network
routes = cell(numRouters, numRouters);  % alloc empty cell structure

%% compute routes
% we assume that the routers of ring 1 have indices 1:N, and the routers of
% ring 2 have indices (N + 1):(N + M).
% furthermore, the rings are connected bidercionally at nodes 1 and N+1

tmpRoutesN = getRoutes_ring_unidirectional(N);  % get the routes for first unidirectional ring
tmpRoutesM = getRoutes_ring_unidirectional(M);  % get the routes for second unidirectional ring

% cycle through all router pairs
for src = 1:numRouters
    for dest = 1:numRouters
        
        if src == dest
            routes{src, dest} = src;                        % route is trivial
        elseif src <= N
            % src is in ring 1
            if dest <= N
                % dest is also in ring 1
                routes{src, dest} = tmpRoutesN{src, dest};  % result is the same as for the unidirectional ring with N nodes
            else
                % dest is in ring 2
                routes{src, dest} = [tmpRoutesN{src, 1}, [tmpRoutesM{1, dest-N} + N] ];  % goto connecting node in ring 1 (1); then proceed to destination in ring 2; biasing with N is due to the index bases
            end
        else
            % src is in ring 2
            if dest <= N
                % dest is in ring 1
                routes{src, dest} = [[tmpRoutesM{src-N, 1} + N], tmpRoutesN{1, dest} ]; % goto connecting node (1) in ring 2; then proceed to destination in ring 1
            else
                % dest is also in ring 2
                routes{src, dest} = tmpRoutesM{src-N, dest-N} + N;
            end
        end
        
    end
end



end

