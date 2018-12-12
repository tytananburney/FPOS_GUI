# FPOS_GUI
A data collection GUI developed in the Space Systems Design Studio for the project: Flux-Pinning for Orbiting Sample capture (FPOS). 

The GUI interface was developed in MATLAB while scripts interacting with the remote Raspberry Pi microcontroller were developed in Python.

This GUI was used to collect and display data on a Zero-G microgravity flight from two IMUs (accelerometer + gyroscope), a VICON camera tracking system, and temperature sensors (called the SROA). I personally developed the scripts for the IMUs ("IMU_scripts/" and "PythonFiles/"), and was heavily involved in architecting the button callback functions in fposGUI3.m. 

The code in this repository is from my local directory at the time I graduated from Cornell University in May 2017, and does not reflect any changes that have been made by the team since. 

fposGUI3.m creates the GUI and performs all initializations. Note - button callbacks may not work because no sensors are present.
