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

function [ POut, tOut ] = bsc_based_noc_com( N, F, B, R, L, varargin )
%BSC_BASED_NOC_COM Calculates the end-to-end packet error probabilities for
% different NoCs based on BSCs and uncorrelated bit flip probabilities.
%
% Syntax:
%   [POut, tOut] = ...
%       bsc_based_noc_com( N, F, B, R, L, [ topology, routes, log] )
% 
% 
% MANDATORY INPUTS:
% N <scalar or 2 element vector> : number of routers
%   depends on the topology chosen
%   - 2D-mesh
%       - scalar : number of rows and columns in a square 2D-mesh
%       - vector : N(1) is the number of rows, N(2) is the number of
%                  columns in a rectangular N(1) x N(2) 2D-mesh
%   - single rings
%       - scalar : number of routers in the ring
%       - vector : not allowed in rings
%   - double ring
%       - scalar : number of routers in each of the two rings
%       - vector : N(1) is the number of routers in the first ring, N(2) is
%                  the number of routers in the second ring
% F <scalar or vector> : number of payload flits per packet
% B <scalar or vector> : link width / number of bits per flit
% R <empty, scalar, vector, string, or struct> : router properties
%   - empty      : routers are not modeled
%   - scalar     : all routers have the same error probability
%   - string     : special mode support; modes are
%       - 'link like' : treat routers as links; use the link probability
%   - numRouters-element vector : routers have different error 
%       probabilities
%   - struct with fields 'heatmap' and 'pOut'
%       heatmap 
%           is a numRouters-element array (numRouters vector or N(1) x N(2)
%           rectangular matrix) containing the average service times of the
%           routers
%       pOut 
%           error probability of a router within one cycle; can be scalar 
%           or a numRouters-element vector
% L <scalar, vector or matrix> : link error probability
%   - scalar : all links have the same error probability
%   - vector : probability sweep where all links have the same probability.
%       Sweeping is only supported for links. For every evaluation the same
%       router properties are used.
%   - numRouters x numRouters matrix : individual link error probabilities;
%       matrix must have adjacency structure
% 
% OPTIONAL INPUTS:
% topology <string> : specify the network topology;
%                       supported topologies are
%                       - '2d-mesh xy'  : 2D-mesh network using xy-routing
%                       - 'ring uni'    : unidirectional ring network
%                       - 'ring bi'     : bidirectional ring network
%                       - 'double ring' : network of 2 unidirectional rings
%                       - 'custom'      : use your own custom topology;
%                                         requires valid <routes> input
% routes <cell>     : routing information;
%                     highly recommended to speed-up sweeps;
%                     custom topologies / routing schemes are supported by
%                     providing this variable
% log <file id>     : log file id generated with fopen
%                     
% 
% DEFAULTS:
% Status messages are written to the command window.
% Topology is 2D-mesh.
% Routes are computed.
% 
% 
% OUTPUTS:
% POut : end-to-end packet error rates
% tOut : calculation time
% 
% 
% 
% REMARKS:
% Only symmetric errors supported yet.
% 


%% assign indices of optional variables
topology_input_idx  = [6, 1];
routes_input_idx    = [7, 2];
log_input_idx       = [8, 3];


%% omit input checking for source code publication
% integer parameter base validation
validateattributes(N, {'numeric'}, {'integer', 'nonnegative', 'vector'});
validateattributes(F, {'numeric'}, {'integer', 'nonnegative'});
validateattributes(B, {'numeric'}, {'integer', 'nonnegative'});

% logging
logId = 1;  % default log id: command window
if nargin == log_input_idx( 1 )
    logId = varargin{ log_input_idx( 2 ) };
end

% topology
expected_topologies = {'custom', '2d-mesh xy', 'ring uni', 'ring bi', 'double ring'};
topology = validate_toplogy( nargin );

% network size
numRouters = validate_network_size( nargin );

% determine the number of payload bits
if isscalar(F) && isscalar(B)
    numBitPayload = F*B;        % single evaluation
else
    [Fmg, Bmg] = meshgrid(F, B); % make all combinations of F and B vectors
    numBitPayload = Fmg .* Bmg; % calculate the number of payload bits
end

% router properties variable
ROut = validate_R;

% check link variable
validateattributes(L, {'numeric'}, {'nonnegative', '<=', 1}); % probability validation
enableRecursion = false;
LOut = validateL;


%% --- compute the routes using xy-routing;
% NOTE: matlab's default matrix index enumeration is column-wise and starts
% with index 1. E.g. the mesh index structure for a 3x3 mesh is
% 1 - 4 - 7
% 2 - 5 - 8
% 3 - 6 - 9
%
% only routers considered, not links
routes = validate_routes( nargin );


%% main: analytical calculation
if ~enableRecursion 
    
RSucc = 1 - ROut;   % router succes probability
LSucc = 1 - LOut;   % link success probability

fprintf(logId, 'Calculating all error probabilities...');

tic;    % start timer for analytical calculation

% calculate single bit success probability relation matrix
pSucc = zeros(numRouters, numRouters);  % mem alloc array for success probabilities
for src = 1:numRouters
    for dest = 1:numRouters
        if src == dest
            
            pSucc(src, dest) = 1;   % no error; just for consistency
            
        else
            
            % compute link part
            if isscalar(LOut)
                pSuccL = (2 * LSucc - 1) ^ (length(routes{src, dest})-1);
            else
                % get the links that are traversed going from src to dest
                % linksInvolved = [routes{src, dest}(1:(end-1)); ...
                %                  routes{src, dest}(2:end)];   % subscripts of adjacency matrix
                linksInvolved = sub2ind([numRouters, numRouters], ...
                    routes{src, dest}(1:(end-1)), ...
                    routes{src, dest}(2:end));   % linear index of adjacency matrix
                pSuccL = prod( (2 * LSucc(linksInvolved) - 1) );
            end
            
            % compute router part
            if isscalar(ROut)
                pSuccR = (2 * RSucc - 1) ^ (length(routes{src, dest}));
            else
                pSuccR = prod( (2 * RSucc(routes{src, dest}) - 1) );
            end
            
            % compute success probability
            pSucc(src, dest) = ( 1 + pSuccR * pSuccL )./2;
            
        end
    end
end


if isscalar(numBitPayload)
    PSucc = pSucc.^(numBitPayload); % calculate packet success probability relation matrix
    POut = 1 - PSucc;               % calculate packet error probability relation matrix
else
    PSucc = arrayfun(@(x) pSucc.^x, numBitPayload, 'UniformOutput', false);
    POut = cellfun(@(x) 1 - x, PSucc, 'UniformOutput', false);
end

tOut = toc;    % stop timer for analytical calculation
fprintf(logId, 'Done.\n');

fprintf(logId, 'Calculation time was %f seconds.\n', tOut);

else
    
    KSweep = length( LOut );    % number of 
    POut = cell(1, KSweep);     % output cell
    tOut = zeros(1, KSweep);    % output times
    
    fprintf(logId, '*** Starting sweep over %d link probabilities.\n', KSweep);
    for kSweep = 1:KSweep
        
        [POut{kSweep}, tOut(kSweep)] = bsc_based_noc_com( N, F, B, R, LOut(kSweep), topology, routes, logId );
        
    end
    
end


%% nested functions go here
function topology = validate_toplogy( nIn )
    topology = expected_topologies{ 2 };    % default topology: xy-routed 2d-mesh
    if nIn >= topology_input_idx( 1 )
        % input validation
        topology = validatestring( varargin{ topology_input_idx( 2 ) }, ...
            expected_topologies );
    end
end

function numRouters = validate_network_size( nIn )
    if strcmpi( topology, 'custom' )
        % custom topology
        if nIn < routes_input_idx( 1 )
            error('Invalid input. Expected cell-array <routes> for option <custom> topology.');
        end
        numRouters = size( varargin{ routes_input_idx( 2 ) }, 1);   % size of routes
        
    elseif strcmpi( topology, '2d-mesh xy' )
        % 2d mesh topology
        if isscalar(N)
            numRouters = N^2;               % square mesh
        elseif numel(N) == 2
            numRouters = N(1) * N(2);       % rectangular mesh
        else
            error('Invalid input <N>. Expected scalar or 2-element vector input.');
        end
        
    elseif strcmpi(topology, 'double ring')
        % double ring
            if isscalar(N)
                numRouters = 2 * N;         % 2 rings with N routers each
            elseif numel(N) == 2
                numRouters = N(1) + N(2);   % 2 rings, having N(1) and N(2) routers
            else
                error('Invalid input <N>. Expected scalar or 2-element vector input.');
            end
            
    else
        % uni- or bidirectional ring
        if ~isscalar(N)
            error('Invalid input <N>. Expected scalar input.');
        else
            numRouters = N;                 % ring having N routers
        end
            
    end
end

function ROut = validate_R(  )
    % - no router modeling
    if isempty( R ) || islogical( R ) && ~R
        
        fprintf(logId, 'Routers will not be modeled.\n');
        ROut = 0;
        
    elseif isstruct( R )
        % - service time based router errors
        fprintf(logId, 'Service time based router errors.\n');
        if ~isfield(R, 'heatmap') && ~isfield(R, 'pOut')
            error('Invalid input <R>. Expected structure with fields <heatmap> and <pOut>.');
        end
        
        % heatmap and probability validation
        validateattributes( R.heatmap, {'numeric'}, {'positive', 'numel', numRouters});
        validateattributes( R.pOut, {'numeric'}, {'nonnegative', '<=', 1});
        
        if ~( isscalar(R.pOut) || all(size(R.pOut) == size(R.heatmap) ) )
            error('Invalid input <R.pOut>. Expected scalar or numRouter-element vector base probability input.');
        end
        ROut = 1 - ( 1 - R.pOut) .^ R.heatmap;    % service time based router error probability (prob. that an error happened in at least one cycle)
        
    elseif ischar( R )
        % - mode based router errors
        expected_router_modes = {'link like'};
        if ~any(strcmpi(R, expected_router_modes))
            error(sprintf('Invalid input <R>. Unsupported router mode <%s> (see the help for supported modes).', R)); %#ok<SPERR>
        end
        
        switch R
            case expected_router_modes{1}
                ROut = L;
        end
        
    elseif isscalar( R )
        % - routers have fixed common error        
        validateattributes(R, {'numeric'}, {'nonnegative', '<=', 1});   % probability validation
        fprintf(logId, 'All routers have a common bit flip probability.\n');
        ROut = R;
        
    else
        % - routers have fixed individual errors        
        validateattributes(R, {'numeric'}, {'nonnegative', '<=', 1, 'vector', 'numel', numRouters});   % probability and size validation
        fprintf(logId, 'Routers have specified bit flip probabilities.\n');
        ROut = R;
        
    end
end

function LOut = validateL()
    if isvector( L )
        if ~isscalar( L )
            enableRecursion = true;
        end
    else
        if ~(isscalar( L ) || all(size(L) == [numRouters, numRouters]))
            error('Expected scalar or adjacency matrix of size (numRouters)x(numRouters) like input.');
        end
    end
    
    LOut = L;
    
end

function routes = validate_routes( nIn )
    
    if nIn >= routes_input_idx( 1 )
        % routes variable provided
        routes = varargin{ routes_input_idx( 2 ) };
        
    else
        % compute the routes based on the topology input
        fprintf(logId, 'Computing network routes...');
        
        switch topology
            case 'custom'
                error('Invalid input. Expected cell-array <routes> for option <custom> topology.');
            case '2d-mesh xy'
                routes = getRoutes_2dmesh_xy( N );
            case 'ring uni'
                routes = getRoutes_ring_unidirectional( N );
            case 'ring bi'
                routes = getRoutes_ring_bidirectional( N );
            case 'double ring'
                routes = getRoutes_ring_double( N );
        end
        
        fprintf(logId, 'Done.\n');
        
    end
end

end

