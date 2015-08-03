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

#ifndef LISNOCBASEMODULE_H_
#define LISNOCBASEMODULE_H_

#include <csimplemodule.h>

#include <LISNoCMessages.h>

namespace lisnoc {

  /**
   * Basic flow control handling
   *
   * This class provides the designer the basic flow control protocol
   * handling as employed by all modules. The class itself is
   * abstract, i.e., it cannot be instantiated. You need to derive
   * your module from this class and implement the following function:
   *
   * - `void handleIncomingFlit(LISNoCFlit *msg)`: Handle an incoming
   *     message after successfull flow control handshake
   *
   *
   */
  class LISNoCBaseModule: public cSimpleModule {
  public:
    virtual ~LISNoCBaseModule();
    virtual void finish();
  private:
    bool m_allowLateAck;
    cMessage *m_selfTrigger;
    LISNoCFlowControlRequest *m_delayedTransfer;
    simtime_t m_clock;
    
    bool m_activeRequest;
    std::pair<LISNoCFlowControlRequest*, simtime_t> m_pendingRequestWithLateAck;
    
    bool m_isInitialized;

    virtual LISNoCFlowControlRequest *createFlowControlRequest(LISNoCFlit *flit);
    virtual LISNoCFlowControlRequest *createFlowControlRequest(LISNoCFlowControlGrant *grant);
    virtual LISNoCFlowControlGrant *createFlowControlGrant(LISNoCFlowControlRequest *request);

  protected:
    virtual void initialize();
    virtual void allowLateAck();

    virtual void handleMessage(cMessage *msg);
    virtual void handleIncomingRequest(LISNoCFlowControlRequest *msg);
    virtual void handleIncomingGrant(LISNoCFlowControlGrant *msg);
    virtual void handleIncomingFlit(LISNoCFlit *msg) = 0;
    
    virtual void triggerSelf(unsigned int numcycles = 1, cMessage *msg = NULL);
    virtual void handleSelfMessage(cMessage *msg) = 0;
    
    virtual bool canRequestTransfer(LISNoCFlit *msg);
    virtual void requestTransfer(LISNoCFlit *msg);
    virtual void requestTransferAfter(LISNoCFlit *msg, unsigned int numcycles);
    virtual void delayedTransfer();
    virtual void doTransfer() = 0;
    
    virtual bool isRequestGranted(LISNoCFlowControlRequest *msg) = 0;
    virtual void tryLateGrant();
  };
  
} /* namespace lisnoc */

#endif /* LISNOCBASEMODULE_H_ */
