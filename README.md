# Complete History of Interaction-Powered Supernovae (CHIPS)

This is a tool for obtaining the whole history of the progenitors of
interaction-powered transients. Coupling the MESA stellar evolution
code and several codes implemented by the authors, the user can obtain the
circumstellar matter profile and light curves of the interaction-powered
supernovae, for a selected mass and metallicity of the progenitor star.

## What can CHIPS do?

CHIPS can generate a realistic CSM from a model-agnostic mass eruption calculation, which can serve as a reference for observers to compare with various observations of the CSM. It can also generate bolometric light curves from CSM interaction, which observers can also compare with the observed light curves.

## Pre-reqs

The requirement for running CHIPS is quite minimal. One needs only the standard gcc and gfortran, and python3 with numpy installed.

## Steps for running CHIPS:
1. First download and install MESA. Please see <http://mesa.sourceforge.net/prereqs.html> for details.
2. Also install mesa_reader, a module that lets us easily extract data from the mesa output. This is used in some of our Python scripts. Please see <http://mesa.sourceforge.net/output.html> for details.
3. git clone this repository in the mesa-rXXXXX/star repository
4. Compile the scripts for the light curve.

	`python lcsetup.py install`

5-a. Execute the script run.py with initial mass and metallicity as arguments. For example, to calculate the history of a 15Msun star with metallicity 0.02 (~ solar) run

	`python run.py --zams-m 15 --zams-z 0.02 --inlist-file /path/to/inlist_file`

   There is an example inlist file in the "example_make_pre_ccsn" repository. If using this one, the command is

	`python run.py --zams-m 15 --zams-z 0.02 --inlist-file example_make_pre_ccsn/inlist_common`

5-b. Alternatively, one can use the MESA pre-SN models generated by us to completely skip the MESA calculation. (NOT DEVELOPED YET)

## References:
1. Kuriyama, Shigeyama (2020), A&A, 635, 127
2. Takei, Shigeyama (2020), PASJ 72, 67
