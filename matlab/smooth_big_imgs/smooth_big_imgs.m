function smooth_big_imgs( input_dir, in_pre, out_pre, S )
%Inputs:
%   input_dir: complete path of the folder where the data are. E.g. FunImgRCFW
%   in_pre: input file's prefix. E.g s, w
%   out_pre: output file's prefix. E.g s, w
%   S: [sx sy sz] Gaussian filter width {FWHM} in mm (or edges)

%[s, msg]=system(['ls ' input_dir '/*/' prefix '*nii*']);
[s, dirs]=system(['ls -d ' input_dir '/*']);
if s
    error(dirs)
else
    dirs=strsplit(dirs);
end
curr_dir=pwd;
[output_dir, output_dirname]=spm_fileparts(input_dir);
output_dirname=[output_dirname upper(out_pre)];
[s, msg]=system(['mkdir ' output_dir '/' output_dirname]);
parfor i=1:numel(dirs)-1
    display(num2str(i))
    [s, msg]=system(['mkdir ' dirs{i} '/tmp']);
    [s, msg]=system(['cp ' dirs{i} '/' in_pre '*nii* ' dirs{i} '/tmp']);
    if s
        error(msg)
    end
    [s,filename]=system(['ls ' dirs{i} '/tmp/' in_pre '*nii*']);
    [s, msg]=system(['export FSLOUTPUTTYPE=NIFTI;cd ' dirs{i} '/tmp; fslsplit ' filename]);
    if s
        error(msg)
    end
    [files,~] = spm_select('FPList',[dirs{i} '/tmp'],'^vol.*\.nii*');
    for j=1:size(files,1)
        curr=deblank(files(j,:));
        [p, nm, e, v]=spm_fileparts(curr);
        outfilename=[p filesep out_pre nm e];
        spm_smooth(curr,outfilename,S);
    end
    %%
    [~,subj_id]=spm_fileparts(dirs{i});
    [base_dir, output_filename]=spm_fileparts(filename);
    output_filename=[out_pre output_filename];
    [s, msg]=system(['mkdir ' output_dir filesep output_dirname filesep subj_id]);
    if s
        error(msg)
    end
    [s, msg]=system(['export FSLOUTPUTTYPE=NIFTI; fslmerge -a  ' output_dir filesep output_dirname, ...
        filesep subj_id filesep output_filename ' `ls ' dirs{i} '/tmp/s*.nii*`']);
    if s
        error(msg)
    end
    cd(curr_dir)
    [s, msg]=system(['rm -rf ' dirs{i} '/tmp']);
    if s
        error(msg)
    end
end
    