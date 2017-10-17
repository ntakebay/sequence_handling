#!/bin/bash

#   Check to make sure our samples exist
function checkSamples() {
    local sample_list="$1" # Sample ist
    if [[ -f "${sample_list}" ]] # If the sample list exists
    then
        if [[ -r "${sample_list}" ]] # If the sample list is readable
        then
            for sample in $(cat "${sample_list}") # For each sample in the sample list
            do
                if ! [[ -f "${sample}" ]] # If the sample doesn't exist
                then
                    echo "${sample} does not exist, exiting..." >&2 # Exit out with error
                    return 1
                else
                    if ! [[ -r "${sample}" ]] # If the sample isn't readable
                    then 
                        echo "${sample} does not have read permissions, exiting..." >&2
                        return 1
                    fi
                fi
            done
        else # If the sample isn't readable
            echo "${sample_list} does not have read permissions, exiting..." >&2
            return 1
        fi
    else # If the sample list doesn't exist
        echo "$sample_list does not exist, exiting..." >&2 # Exit out with error
        return 1
    fi
}

#   Export the function to be used elsewhere
export -f checkSamples

#   Check to make sure our dependencies are installed
function checkDependencies() {
    local dependencies=("${!1}") # BASH array to hold dependencies
    for dep in "${dependencies[@]}" # For each dependency
    do
        if ! `command -v "$dep" > /dev/null 2> /dev/null` # If it's not installed
        then
            echo "Failed to find $dep installation, exiting..." >&2 # Write error message
            return 1 # Exit out with error
        fi
    done
}

#   Export the function to be used elsewhere
export -f checkDependencies

#   Check versions of tools
function checkVersion() {
    local tool="$1"
    local version="$2"
    "${tool}" --version | grep "${version}" > /dev/null 2> /dev/null || return 1
}

#   Export the function to be used elsewhere
export -f checkVersion

#   Figure out memory requirements based on Qsub settings
#   This code written by Paul Hoffman for the RNA version of sequence handling at https://github.com/LappalainenLab/sequence_handling/
function getMemory() {
    local qsub="$1" # What are the Qsub settings for this job?
    MEM_RAW=$(echo "${qsub}" | grep -oE 'mem=[[:alnum:]]+' | cut -f 2 -d '=')
    MEM_DIGITS=$(echo "${MEM_RAW}" | grep -oE '[[:digit:]]+')
    if $(echo "${MEM_RAW}" | grep -i 'g' > /dev/null 2> /dev/null)
    then
        MAX_MEM="${MEM_DIGITS}G"
    elif $(echo "${MEM_RAW}" | grep -i 'm' > /dev/null 2> /dev/null)
    then
        MAX_MEM="${MEM_DIGITS}M"
    elif $(echo "${MEM_RAW}" | grep -i 'k' > /dev/null 2> /dev/null)
    then
        MAX_MEM="${MEM_DIGITS}K"
    else
        MAX_MEM="${MEM_DIGITS}"
    fi
    echo "${MAX_MEM}" # Return just the memory setting
}

#   Export the function to be used elsewhere
export -f getMemory

#   A function to check to make sure Picard is where it actually is
function checkPicard() {
    local Picard="$1" # Where is Picard?
    if ! [[ -f "${Picard}" ]]; then echo "Failed to find Picard, exiting..." >&2; return 1; fi # If we can't find Picard, exit with error
}

#   Export the function
export -f checkPicard

#   A function to check to make sure Picard is where it actually is
function checkGATK() {
    local GATK="$1" # Where is GATK?
    if ! [[ -f "${GATK}" ]]; then echo "Failed to find GATK, exiting..." >&2; return 1; fi # If we can't find GATK, exit with error
}

#   Export the function to be used elsewhere
export -f checkGATK