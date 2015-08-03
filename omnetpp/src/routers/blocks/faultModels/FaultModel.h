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

// faultModel.h

#ifndef FAULTMODEL_H_
#define FAULTMODEL_H_

#include <omnetpp.h>

namespace lisnoc {

    typedef enum FaultEffect {
        INVERSION,
        STUCKATZERO,
        STUCKATONE,
        RANDOM,
        BRIDGE,
        DELAY
    } FaultEffect;

    struct FaultCharacteristics {
        int wire;
        int numWires;
        int duration;
        FaultEffect effect;
    };

    class FaultModelBase : public cSimpleModule
    {
    protected:
        virtual void initialize(int stage);
        virtual int getNumStages() const { return 1; }
        virtual void handleMessage(cMessage *msg);
        virtual void finish();
    public:
        virtual bool sampleFaultLink() = 0;
        virtual bool sampleFaultBuffer() = 0;
        virtual void sampleFaultCharacteristics(std::vector<struct FaultCharacteristics> &faultVector) = 0;
    };

    class FaultModelRegistry
    {
    public:
        static FaultModelRegistry* s_getFaultModelRegistry();

        void registerRouterFaultModel(int routerId, FaultModelBase* faultModel);
        FaultModelBase *getRouterFaultModel(int routerId);
    private:
        std::map<int, FaultModelBase*> m_routerFaultModels;
        FaultModelRegistry() {}
        static FaultModelRegistry *s_registry;

    };

}; // namespace

#endif /* FAULTMODEL_H_ */
