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

function [ routes ] = getRoutes_ring_bidirectional( N )
%GETROUTES_RING_BIDIRECTIONAL Compute the routes for all
% source-destination pairs in a bidirectional ring network.
%
% Syntax:
%   [ routes ] = getRoutes_ring_unidirectional( N )
%       Returns an N x N cell array for every pair of routers in a
%       bidirectional ring with N routers.
%

%% variable assignment
numRouters = N;                         % number of routers in a 2D-mesh network
routes = cell(numRouters, numRouters);  % alloc empty cell structure

%% compute routes
% we assume that the routers are connected in an index increasing fashion,
% i.e. a 4 node network is connected like
% 1 > 2 > 3 > 4 > 1
% cycle through all router pairs
for src = 1:numRouters
    for dest = 1:numRouters
        
        if src == dest
            routes{src, dest} = src;                                    % route is trivial
            
        elseif dest > src
            if dest - src <= numRouters/2
                routes{src, dest} = src:dest;                           % router index increases till destination is reached
            else
                routes{src, dest} = [src:-1:1, numRouters:-1:dest];     % router index decreases till destination is reached
            end
            
        else
            if src - dest >= numRouters/2
                routes{src, dest} = [src:numRouters, 1:dest];           % router index increases till destination is reached
            else
                routes{src, dest} = [src:-1:dest];                      % router index decreases till destination is reached
            end
            
        end
        
    end
end

end

