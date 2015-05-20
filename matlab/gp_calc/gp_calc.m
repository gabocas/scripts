function [ gps ] = gp_calc( input_dir, z_flag, groups, sid_pat, gps_strings, abs_flag, varargin )
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here
if z_flag file_pattern='*FisherZ_'; else file_pattern='ROICorrelation_'; end
[s, files]=system(['ls -d ' input_dir filesep file_pattern sid_pat '*.mat']);
files=files(1:end-1);
if s error(files); else files=strsplit(files); end

%GP
addpath(genpath('2012-12-04_BCT'))%Load BCT lib
load(files{1});
[m,~]=size(ROICorrelation); %number of nodes
n=numel(files); %number of subjects
if nargin>6
    CMs=nan(varargin{1},varargin{1},n);
    m=varargin{1};
else
    CMs=nan(m,m,n);
end
n_gp=numel(gps_strings); %number of graph properties
gps=nan(m*n_gp,n);
ROICorrelation_struct=struct('ROICorrelation',[]);
parfor i=1:n
    ROICorrelation_struct(i)=load(files{i});
    if abs_flag
        ROICorrelation_struct(i).ROICorrelation=abs(ROICorrelation_struct(i).ROICorrelation);
    else
        ROICorrelation_struct(i).ROICorrelation(ROICorrelation_struct(i).ROICorrelation<0)=0;
    end
    display(['Subject ' num2str(i) ' - nVert=' num2str(size(ROICorrelation_struct(i).ROICorrelation,1))]);
    CMs(:,:,i)=ROICorrelation_struct(i).ROICorrelation(1:m,1:m);
    gp=extract_gps(CMs(:,:,i),gps_strings);
    gps(:,i)=gp(:);
end
    


function gps=extract_gps(CM,gps_strings)
CM_norm=weight_conversion(CM,'normalize');
CM=CM_norm;%comment
L=weight_conversion(CM,'lengths');
n_gp=numel(gps_strings);
[n_nodes,~]=size(CM);
gps=nan(n_nodes,n_gp);
for i=1:n_gp
    if strcmp(gps_strings{i},'betweenness_wei')
        gps(:,i)=eval([gps_strings{i} '(L)']);
    elseif strcmp(gps_strings{i},'efficiency_wei')
        gps(:,i)=eval([gps_strings{i} '(CM_norm,1)']);
    else
        gps(:,i)=eval([gps_strings{i} '(CM)']);
    end
end

    