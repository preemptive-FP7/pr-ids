# PR-IDS tool: Process Related Intrusion Detection System

This repository hosts scripts and source code related to PR-IDS tool developed by [Grupo AIA](http://aia.es/) as part of the [PREEMPTIVE FP7 project](http://preemptive.eu).

The goal of PREEMPTIVE is to provide an innovative solution for enhancing existing methods and conceiving tools to prevent against cyber attacks, that target utility networks.

The **Process Related Intrusion Detection System** (PR-IDS) tool analyses data at the industrial process level, i.e. the physical domain.

The tool is designed to raise an alarm or warning as soon as it detects an abnormal behaviour in the monitored process(es). The PR-IDS tool receives from the control system all the measurement variables available from the network in real-time.

The PR-IDS tool bases its detection capabilities on the Negative Selection Algorithm (NSA) [Forrest et al., 1994], that belongs to the group of Artificial Immune Systems computational techniques.
The V-detector algorithm implementation of a NSA is used as the base algorithm for detection ([see Zhou Ji website, 2014](http://zhouji.net.s3-website-us-east-1.amazonaws.com/vdetector.html) for details).

----

This work has been supported by the European Commission through project FP7-SEC-607093-PREEMPTIVE funded by the 7th Framework Program.

----

See other contributions by AIA available on Github [\@grupoaia](https://github.com/grupoaia).