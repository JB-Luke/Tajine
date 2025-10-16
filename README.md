# Mango
## Purpose

This script provides post-processing of acoustic measurements performed with the sine sweep technique.
The traditional workflows, such as the use of a DAW (like Adobe Audition 3.0) alongside acoustic elaboration plugins (like Aurora) are cumersome and require many manual steps which highly prone to user errors.

The main purpose of this script is to embrace all the manual step leaving to the user just few manual visual or auditory checks that simplify the procedure but leaving control to the operator.

## Workflow

- **Input**: Multichannel audio data acquired through an audio interface from multiple microphones (transducers), inverse sweep.

- **Deconvolution**: Each transducer channel is deconvolved with the inverse of the excitation sweep to obtain the corresponding Impulse Response (IR).

- **Computation**: Each tranducers set of signals is processed by AcouPar to obtain specific acoustic parameters.

- **Output**: For each transducer, a dedicated audio file is created, containing the IRs, as well as a set of text files containing the acoustic parameters and a wrap-up spreadsheet file

## Output

- A set of WAV files each file includes all elaborated IR  belonging to a single transducer (monoaural omnidirectional, binaural dummyhead, ambeo VR mic).
- A set of txt files containig the acoustic parameters belonging to a single transducer
- A wrap-up excel with containing the parameters organized in different tables, one per each transducers

## How-to

1. Specify the path of the file to elaborate `inputFile` 
2. Specify the path of the Inverse Sweep file `invSeepFile`
3. Specify the output folder name `outputFolder` (usually the name of the measured environment e.g.: *zagreb-national-thater*)
4. Specify the name of the output files in `probeLabel` (e.g.: *p1-gallery-bis*)
5. Launch the script


The script will run entierly

### Manual check
- The user shall perform a visual check of the input file audio plot in Figure 1 (sweep recording)
- The user shall perform a visual check of the found Impulse Response and its trimmed version (Figure 2)

