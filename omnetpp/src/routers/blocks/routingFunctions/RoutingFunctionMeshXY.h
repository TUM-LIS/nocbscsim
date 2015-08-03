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

// RoutingFunctionMeshXY.h

#ifndef ROUTINGFUNCTIONMESHXY_H_
#define ROUTINGFUNCTIONMESHXY_H_

#include "RoutingFunctionBase.h"

namespace lisnoc {

class RoutingFunctionMeshXY : public RoutingFunctionBase {
public:
    RoutingFunctionMeshXY(int columns, int routerId);
    virtual void doRouting(LISNoCFlit *flit);

private:
    int m_columns;

    int m_routerPosX;
    int m_routerPosY;
};

}



#endif /* ROUTINGFUNCTIONMESHXY_H_ */
