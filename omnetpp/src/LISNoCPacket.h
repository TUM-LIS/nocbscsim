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

#ifndef LISNOCPACKET_H_
#define LISNOCPACKET_H_

class LISNoCPacket {
  public:
    LISNoCPacket(int id) {
        m_id = id;
        m_isFaulty = false;
    }

    int getId() {
        return m_id;
    }

    void setFaulty() {
        m_isFaulty = true;
    }

    bool isFaulty() {
        return m_isFaulty;
    }

  private:
    int m_id;
    bool m_isFaulty;
};



#endif /* LISNOCPACKET_H_ */
