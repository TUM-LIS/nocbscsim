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

// FaultModelZimmerJantsch.h

#ifndef FAULTMODELZIMMERJANTSCH_H_
#define FAULTMODELZIMMERJANTSCH_H_

#include <FaultModel.h>

#include <random>

namespace lisnoc {

class FaultModelZimmerJantsch: public lisnoc::FaultModelBase {
private:
    typedef int Pw_t;
    typedef int Pt_t;
    typedef std::pair<Pw_t, Pt_t> Pentry_t;
    typedef std::vector<Pentry_t> P_t;
    P_t m_P3;

    double m_p_faultLink;
    double m_p_faultBuffer;

    std::discrete_distribution<int64_t> *m_sampleFaultDistributionLink;
    std::discrete_distribution<int64_t> *m_sampleFaultDistributionBuffer;
    std::discrete_distribution<int64_t> *m_sampleCharacteristicDistribution;

protected:
    virtual void initialize(int stage);
public:
    virtual bool sampleFaultLink();
    virtual bool sampleFaultBuffer();
    virtual void sampleFaultCharacteristics(std::vector<struct FaultCharacteristics> &faultVector);
};

} /* namespace lisnoc */

#endif /* FAULTMODELZIMMERJANTSCH_H_ */
