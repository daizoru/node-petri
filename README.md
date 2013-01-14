#node-substrate
===============

*experimental framework for evolving artificial lifeforms*

Like the Autoverse, only simpler. And in JavaScript.

## Description

Work in progress

## Design goals

node-substrate is a an experimental framework for building evolutionary multi-agent systems. Focus is made on how could multiple "species" compete or collaborate for survival.

Species can be heterogeneous (eg. different reproduction strategies, algorithms or behaviors) and may share the same limited resources (eg. computing power). Programs that have energy are running, when energy is exhausted the program is terminated. 
Thus as a consequence, species or societies that developed good enough energy-gathering strategies will survive, others will strive or disappear.

Energy is the unit used for doing everything: forking, sending messages,
executing actions.. the logical consequence is that errors cost energy too.

Energy gathering may be done in a variety of ways: first by searching, extracting, stealing or buying it, then sharing, donating or selling it.
This way, many different kind of organized systems can be grown: specialized, cooperative, parasitic, symbiotic, society-like..  

Prey-predator models can also emerge with this approach: strategies where agents gave energy then die as a response to an 'attack' (a message). "Fair" players organization will resist, will cheaters (algorithms that do not respect the death rule) will collapse.

## Comment

This is an on-going project and not ready for wide spreading outside my own use. The prototype is written for Node.js plateform for various reasons (the goal is to allow open-ended evolution: using a dynamical language like JS allow artificial lifeforms to do crazy things like reprogramming, evolving themselves at runtime, talking to native libraries or colonizing web browsers. I tried to do these sort of things in other languages but it was impractical) 

## Installation

  not yet

## Documentation

To be continued

## Changelog

### 0.0.0

 * initial, experimental version

### Interesting readings

 * https://en.wikipedia.org/wiki/Genetic_programming for the historical background
 * BUT also https://en.wikipedia.org/wiki/Genetic_engineering which I find closer to this project's goals
 * The part on the Autoverse: https://en.wikipedia.org/wiki/Permutation_City
 * Q6 at: http://gregegan.customer.netspace.net.au/PERMUTATION/FAQ/FAQ.html