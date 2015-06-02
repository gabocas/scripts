#!/bin/bash
filenames=`ls $1`
#report=$2
#filenames=`ls ${input_folder}/Col*/*ol*/*/*VOL_AX*nii*`
for file in ${filenames[*]}; do
	fslinfo $file  | awk '{print $2}' | awk '{ for (j=1; j<=NF; j++) printf "%s\t", $j}'; fslstats $file -M
done 