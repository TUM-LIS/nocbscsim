//
// This program is free software: you can redistribute it and/or modify
// it under the terms of the GNU Lesser General Public License as published by
// the Free Software Foundation, either version 3 of the License, or
// (at your option) any later version.
// 
// This program is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
// GNU Lesser General Public License for more details.
// 
// You should have received a copy of the GNU Lesser General Public License
// along with this program.  If not, see http://www.gnu.org/licenses/.
// 

// RoutingFunctionMeshXY.cc

#include "RoutingFunctionMeshXY.h"
#include <LISNoCMessages.h>

namespace lisnoc {

RoutingFunctionMeshXY::RoutingFunctionMeshXY(int columns, int routerId)
    : m_columns(columns)
{
    m_routerPosX = routerId%columns;
    m_routerPosY = routerId/columns;
}

void RoutingFunctionMeshXY::doRouting(LISNoCFlit *flit) {
    LISNoCFlitControlInfo *controlInfo = (LISNoCFlitControlInfo *) flit->getControlInfo();
    int dstId = controlInfo->getDstId();
    int dstPosX = dstId%m_columns;
    int dstPosY = dstId/m_columns;

    int outputPort;

    if(dstPosX > m_routerPosX) {
        outputPort = 2; // EAST
    } else if(dstPosX < m_routerPosX) {
        outputPort = 4; // WEST
    } else if(dstPosY > m_routerPosY) {
        outputPort = 3; // SOUTH
    } else if(dstPosY < m_routerPosY) {
        outputPort = 1; // NORTH
    } else {
        outputPort = 0; // LOCAL
    }

    controlInfo->setOutputPort(outputPort);
}

}
