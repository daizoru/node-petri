
## Model

### Description

 The model generates instead a stand-alone C program, then run it to compute the actual flight prediction.

### Design:

 To keep it simple, the program will predict one single flight at a time.

 To make it predict a full dataset, one will have to run it many times eg. with a basic shell command.

  Of course this means we will load the dataset everytime, but actually this is not a problem because:
  - It will load smartly the dataset, using a search algorithm, so it will have a low memory footprint
  - This way we will be able to simulate and evolve many agents at the same time
  - This way it will run easily on embedded hardware
 Since the system is certainly non-stationary (ie. flights are not independent and influence each others during the day) it might be interesting - for the algorithm - to have access to the list of other flights of the day, or at least the ones previously predicted (maybe this should be in the dataset too?).

