# Models

 For the moment, only two models are experimented.

 If run together those two models will compete for ressources
 however it is also possible to run them separately.

 ## Test Node Program

 The first is a pure (Node.js (JavaScript) agent. It is developed to get familiar with the dataset and test a few things.

## Stand-alone C Program

### Description

 The second model is like the first one, but instead of being written in JS
 it generates instead a stand-alone C program, then run it to compute the actual flight prediction.

### Design:

 To keep it simple, the program will predict one single flight at a time.

 To make it predict a full dataset, one will have to run it many times eg. with a basic shell command.

 Since the system is certainly non-stationary (ie. flights are not independent and influence each others during the day) it might be interesting to know the list of other flights of the day, or at least the ones previously predicted.
 (maybe this should be in the dataset too?)

