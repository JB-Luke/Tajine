# Diaco script

## Purpose

This script provides a first attempt to automate the post-processing of acoustic measurements performed with the sine sweep technique.
Traditional workflows, such as the use of Aurora plugins in Adobe Audition 3.0, are now obsolete, requiring many manual steps. This makes the process slow and highly prone to user errors.

## Workflow

- **Input**: Multichannel audio data acquired through an audio interface from multiple microphones (transducers).

- **Deconvolution**: Each channel is deconvolved with the excitation sweep to obtain the corresponding Impulse Response (IR).

- **Grouping**: Since the measurements may involve transducers with a different number of capsules, the resulting IRs are grouped by transducer.

- **Output**: For each transducer, a dedicated WAV file is created, containing all IR channels associated with that device.

## Output

- A set of WAV files - one per transducer - each file includes all elaborated IR capsule channels belonging to that transducer.
- A set of txt files - one per transducer -  containig the acoustic parameters 
- A summary excel with 

## How-to

1. Specify the path of the file to elaborate `inputFile` 
2. Specify the path of the Inverse Sweep file `invSeepFile`
3. Specify the output folder name `outputFolder` (usually the name of the measured environment e.g.: *zagreb-national-thater*)
4. Specify the name of the output files in `probeLabel` 
5. Launch the script

-  the user is asked to perform a visual check of the input file audio (sweep recording) plot 
- the user is asked to perform a visual check of the found Impulse Response and its trimmed version. 

## CHANGELOG

