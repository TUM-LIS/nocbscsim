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

#include "FaultModel.h"

namespace lisnoc {

FaultModelRegistry* FaultModelRegistry::s_registry = NULL;

FaultModelRegistry* FaultModelRegistry::s_getFaultModelRegistry() {
    if (s_registry == NULL) {
        s_registry = new FaultModelRegistry;
    }
    return s_registry;
}

void FaultModelRegistry::registerRouterFaultModel(int routerId, FaultModelBase* faultModel) {
    ASSERT(m_routerFaultModels.find(routerId) == m_routerFaultModels.end());
    m_routerFaultModels[routerId] = faultModel;
}

FaultModelBase *FaultModelRegistry::getRouterFaultModel(int routerId) {
    ASSERT(m_routerFaultModels.find(routerId) != m_routerFaultModels.end());
    ASSERT(m_routerFaultModels[routerId]);
    return m_routerFaultModels[routerId];
}

void FaultModelBase::initialize(int stage)
{
    ASSERT(stage == 0);
    FaultModelRegistry::s_getFaultModelRegistry()->registerRouterFaultModel(par("routerId"), this);
}

void FaultModelBase::handleMessage(cMessage *msg)
{
    ASSERT(false);
}

void FaultModelBase::finish()
{

}

}; // namespace
