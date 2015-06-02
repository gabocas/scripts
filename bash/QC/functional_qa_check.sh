#!/bin/bash
Usage() {
    cat <<EOF


Usage: ./functional_qa_check.sh <input_directory> <subjects_prefix> <dparsf_flag> <anat_folder> <epi_folder> <output_dir> <subjId1> <subjId2> <subjId3> .........
e.g.   ./functional_qa_check.sh /Volumes/L-HIPP/Datasets/GIPSI/analysis TAB_M 1 T1ImgCoreg FunImgAR functional_qa_report 1 2 3


EOF
    exit 1
}

[ "$6" = "" ] && Usage

data_dir=$1; shift
sub_id_pref=$1; shift
dparsf_flag=$1; shift
t1_folder=$1; shift
epi_folder=$1; shift
output_dir=$1; shift
output_dir=$data_dir/${output_dir}
mkdir $output_dir
touch $output_dir/files_info.txt
for sub_id in $@ ; do
	sid=`zeropad $sub_id 3`;
	echo $sid
	#funct_file=$data_dir/00${sub_id}/session_1/rest_1/rest.nii.gz
	#anat_file=$data_dir/00${sub_id}/session_1/anat_1/mprage.nii.gz
	if [ $dparsf_flag -eq 1 ] ; then
		funct_file=`ls ${data_dir}/${epi_folder}/${sub_id_pref}${sid}/*nii*`
		anat_file=`ls ${data_dir}/${t1_folder}/${sub_id_pref}${sid}/*nii*`
	else
		funct_file=`ls ${data_dir}/${sub_id_pref}${sid}/${epi_folder}/*nii*`
		anat_file=`ls ${data_dir}/${sub_id_pref}${sid}/${t1_folder}/*nii*`
	fi
	#echo $funct_file
	(echo -ne $sid"\t"; ./general_qa_check.sh $funct_file) >> $data_dir/functional_qa_report/files_info.txt
	fslmaths $funct_file -Tmean $output_dir/${sub_id_pref}${sid}
	x=$((`fslinfo $output_dir/${sub_id_pref}${sid} | sed -n 2p | awk '{print $2}'`/2))
	y=$((`fslinfo $output_dir/${sub_id_pref}${sid} | sed -n 3p | awk '{print $2}'`/2))
	z=$((`fslinfo $output_dir/${sub_id_pref}${sid} | sed -n 4p | awk '{print $2}'`/2))
	slicer $output_dir/${sub_id_pref}${sid} -x -$x $output_dir/f${sub_id_pref}${sid}_x.png -y -$y $output_dir/f${sub_id_pref}${sid}_y.png -z -$z $output_dir/f${sub_id_pref}${sid}_z.png ;
	xa=$((`fslinfo $anat_file | sed -n 2p | awk '{print $2}'`/2))
	ya=$((`fslinfo $anat_file | sed -n 3p | awk '{print $2}'`/2))
	za=$((`fslinfo $anat_file | sed -n 4p | awk '{print $2}'`/2))
	#sx=$((x/xa))
	sy=`bc -l <<< "$y/$ya"`
	#sz=$((z/za))
	#echo $sy
	slicer $anat_file -s $sy -x -$xa $output_dir/a${sub_id_pref}${sid}_x.png -y -$ya $output_dir/a${sub_id_pref}${sid}_y.png -z -$za $output_dir/a${sub_id_pref}${sid}_z.png ;
	pngappend $output_dir/f${sub_id_pref}${sid}_x.png + $output_dir/f${sub_id_pref}${sid}_y.png + $output_dir/f${sub_id_pref}${sid}_z.png + $output_dir/a${sub_id_pref}${sid}_x.png + $output_dir/a${sub_id_pref}${sid}_y.png + $output_dir/a${sub_id_pref}${sid}_z.png $output_dir/${sub_id_pref}${sid}.png ;
	rm -r $output_dir/*${sub_id_pref}${sid}_*
	rm -r $output_dir/${sub_id_pref}${sid}.nii*
done
	