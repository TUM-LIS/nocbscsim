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

function [ routes ] = getRoutes_2dmesh_xy( N, varargin )
%GETROUTES_2DMESH_XY Compute the routes for all source-destination pairs in
% a N x M 2D-mesh network using xy-routing.
%
% Syntax:
%   routes = getRoutes_2dmesh_xy( N )
%       Returns an N^2 x N^2 cell array of the routes for every pair of 
%       routers in a square 2D-mesh with N rows and columns.
%   routes = getRoutes_2dmesh_xy( [N, M] ) or
%   routes = getRoutes_2dmesh_xy( N, M )
%       Returns an N*M x N*M cell array of routes for every pair of routers
%       in a rectangular 2D-mesh with N rows and M columns.
%
%
% Note on router enumeration:
%   - Enumeration starts at index 1.
%   - Matlab uses column first enumeration
% Example: In a 3x3 mesh, the router with index 3 is the lower left corner.
%

%% input
% determine mesh shape
if nargin == 1
    if isscalar(N)
        M = N;          % square 2D-mesh
    else
        M = N(2);       % rectangular 2D-mesh
        N = N(1);       % rectangular 2D-mesh
    end
elseif nargin == 2
    M = varargin{1};    % rectangular 2D-mesh
end

%% variable assignment
numRouters = N * M;                     % number of routers in a 2D-mesh network
routes = cell(numRouters, numRouters);  % alloc empty cell structure

%% compute routes
% we consider routers only, not links;
% links can be included in a straight-forward way from the routes result

% cycle through all combinations of sources and destiniations as routes 
% differ: route(src -- dest) ~= route(dest -- src)
for src = 1:numRouters
    for dest = 1:numRouters
        
        pos = src;                                      % position at the beginning of each connection
        [rowPos, colPos] = ind2sub( [N, M], pos);       % current position (source) row and column index
        [rowDest, colDest] = ind2sub( [N, M], dest);    % destination row and column index
        
        while pos ~= dest
            
            routes{src, dest} = [routes{src, dest}, pos];   % add current position to route
            
            % decrease the column (X) distance first
            if colPos ~= colDest
                if colDest > colPos
                    colPos = colPos + 1;    % go right
                else
                    colPos = colPos - 1;    % go left
                end
                
            % decrease the row (Y) distance next
            elseif rowPos ~= rowDest
                if rowDest > rowPos
                    rowPos = rowPos + 1;    % go up
                else
                    rowPos = rowPos - 1;    % go down
                end
            end
            
            pos = sub2ind( [N, M], rowPos, colPos);     % update position
            
        end
        
        routes{src, dest} = [routes{src, dest}, dest];  % finally add the destination to the route
        
    end
end

end

