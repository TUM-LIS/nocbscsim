# nocbscsim

This project models end-to-end packet error rates for Network-on-Chip (NoC).

Contributers:
Michael Vonbun (michael.vonbun@tum.de)
Stefan Wallentowitz (stefan.wallentowitz@tum.de)
Andreas Oeldemann (andreas.oeldemann@tum.de)

For details on the model see:
"An Analytic Approach on End-to-end Packet Error Rate Estimation for
Network-on-Chip", Michael Vonbun, Stefan Wallentowitz, Andreas Oeldemann, Andreas Herkersdorf, in Proceedings of Euromicro Conference on Digital
Systems Design, August 2015.

It consists of two modules:
- matlab / analytic
  Analytic equations based on modeling NoC entities as binary symmetric
  channels (BSCs) are used to provide estimates on the end-to-end packet
  error rates.
- omnet++ / simulative
  A Omnet++ based NoC model with random bit-flips in routers and links.
