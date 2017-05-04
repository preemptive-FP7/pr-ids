# PR-IDS preprocessing functions and scripts

In this folder the `R` scripts and functions used for preprocessing the data before introducing them in the V-detector algorithm can be found.

Main scripts:

- `Preprocessing_NormPcaSoftmax.R` normalizes the data with a given window of size, reduces the dimension by means of PCA transformation, and applies a SoftMax transformation to make values range between 0 and 1 (requirement of the V-detector algorithm). Data are saved to be used as training (and test) input for V-detector java program and all information regarding the various transformations are saved in files (*.txt) to be used as input configurations by STORM V-detector. 

----

This work has been supported by the European Commission through project FP7-SEC-607093-PREEMPTIVE funded by the 7th Framework Program.

----

See other contributions by AIA available on Github [\@grupoaia](https://github.com/grupoaia).