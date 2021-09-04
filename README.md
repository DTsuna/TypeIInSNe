# Complete History of Interaction-Powered Supernovae (CHIPS)

CHIPS is a tool for obtaining the whole history of the progenitors of
interaction-powered transients. Coupling the MESA stellar evolution
code and several codes implemented by the authors, the user can obtain the
circumstellar matter profile and light curves of the interaction-powered
supernovae, for a selected mass and metallicity of the progenitor star.

## What can CHIPS do?

CHIPS can generate a realistic CSM from a model-agnostic mass eruption calculation (reference 1), which can serve as a reference for observers to compare with various observations of the CSM. It can also generate bolometric light curves from CSM interaction (reference 2), which can also be compared with observed light curves. The calculation of mass eruption and light curve typically takes respectively half a day and half an hour on modern CPUs.

## Pre-reqs

The requirement for running CHIPS is quite minimal. One needs only the standard gcc and gfortran, python3 with numpy and scipy, and mesa_reader (modules for reading MESA output files) installed. If matplotlib is installed, one can also obtain some plots that are automatically generated by CHIPS.

For installation of mesa_reader, please see <http://mesa.sourceforge.net/output.html> for details.

## Steps for running CHIPS:
1. git clone this repository

	`git clone https://github.com/DTsuna/CHIPS.git`

2. At the top directory, compile the scripts for the mass eruption and light curve.

	`make`

3. Execute the script run.py. For example, to simulate an interaction-powered SN of a star with ZAMS mass 15 Msun and solar metallicity (assumed to be 0.014) which experiences mass eruption 5 years before core-collapse with energy injection of 0.3 times the envelope's binding energy, and finally explodes with energy 1e51 erg, run

	`python run.py --tinj 5 --finj 0.3 --Eexp 1e51 --stellar-model input/mesa_models/15Msun_Z0.014_preccsn.data --analytical-CSM`


The argument tinj and finj are required, and can be given only once. The argument Eexp can be given multiple times to simulate explosions with different explosion energies.

For the argument --stellar-model, one can read in their MESA stellar model generated on their own. Alternatively, one can use the MESA pre-SN models generated by us. 

Our sample models cover stars of solar metallicity with ZAMS mass range 13-26 Msun, with 1 Msun interval up to 20 Msun and 2 Msun interval from 20 to 26 Msun. The pre-SN models are in a zip file in the directory input/mesa_models/. Once you un-zip this file, you will find MESA data files with the naming showing the mass and metallicity at ZAMS.

Although this is not the recommended way, one can also do the MESA calculation inside run.py with additional arguments --run-mesa and --mesa-path


	python run.py --tinj 5 --finj 0.3 --Eexp 1e51 --stellar-model /output/MESA/model --run-mesa --mesa-path /path/to/execution/directory --analytical-CSM 

The argument --stellar-model should be the output file from this MESA calculation that one would like to be using as input for CHIPS. The argument --mesa-path should specify the relative path to where the calling scripts (mk, rn) for the MESA calculation is.

We strongly advise to use an analytical CSM model (reference 3) that corrects the artifical shock-compressions that arise from the adiabatic mass eruption code. This can be done with the argument --analytical-CSM.


### Using an already obtained CSM for light curve calculation
While the mass eruption calculation is running, files with names intermediateXXyr.txt, which record the envelope profile XX years after energy injection, are created. If these files are available, for calculations of the light curve one can skip the mass-eruption calculation and obtain the light curve using the code after_snhyd.py.


	python after_eruption.py --Eexp 1e51 --stellar-model input/mesa_models/15Msun_Z0.014_preccsn.data --profile-at-cc EruptionFiles/intermediate10yr.txt --analytical-CSM

The file given as profile-at-cc argument specifies how much time elapsed between mass eruption and core-collapse. The files are produced at an interval of 1 year.

### Multi-band light curves
The CHIPS code can obtain multi-band light curves if ray-tracing radiation transfer is turned on. To do this, add the argument --calc-multiband when running run.py or after_eruption.py.

## References:
1. Kuriyama, Shigeyama (2020), A&A, 635, 127 (for mass eruption)
2. Takei, Shigeyama (2020), PASJ 72, 67 (for light curve)
3. Tsuna, Takei, Kuriyama, Shigeyama (2021), PASJ 73, 1128 (analytical CSM model) 


## Contact
For questions, comments about the CHIPS code or possible collaboration, please email us from the following email address:
chips___at___resceu.s.u-tokyo.ac.jp
