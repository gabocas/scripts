function boxplots_gps(files,boxplot_flag,options)
% Function boxplots_gps generates the violinplots grouped by time and group
%   Inputs:
%       *files: struct with the fields
%           - tp1: cell array with the mat filepaths where the variable gps 
%             are stored for the time point 1, one per group
%           - tpn: [...] for the time point n, one per group
%       Example:
%         files.tp1={'/Users/gabocas/Documents/Datasets/Prisma/TAB/TAB1/gps.mat', ...
%              '/Users/gabocas/Documents/Datasets/Prisma/EZQ/EZQ1/gps.mat'};
%         files.tp2={'/Users/gabocas/Documents/Datasets/Prisma/TAB/TAB2/gps.mat', ...
%              '/Users/gabocas/Documents/Datasets/Prisma/EZQ/EZQ2/gps.mat'};
%       *boxplot_flag: 0 if you want to plot violinplots
%       *catIdx: column vector with size n_grp*number of subjects per group ? {1,2,...n_grp}
%       *options: struct with the next fields:
%           - max_length: For unpaired groups, this value should be the
%             the number of subj of the bigger group * num of vertex 
%           - gps_labels: graph properties labels, eg.
%           options.gps_labels={'strength', 'clust. coef.'};
%           - grp_labels: group labels, eg. options.grp_labels={'TAB','EZQ'};
%           - tp_labels: time points labels, eg.
%           options.tp_labels={'TP1','TP2'};
%          - N: number of subjects per group , eg. options.N=[17 42 5];
addpath(genpath('plotSpread'));%Add plotSpread function developed by Jonas (2009) 
max_length=options.max_length;%19536;%Max length of the number of subj * num of vertex (264*74)
grp_labels=options.grp_labels;
tp_labels=options.tp_labels;%{'TP_1','TP_2'};
gps_labels=options.gps_labels;
N=options.N;
n_ver=options.n_vert;
n_grp=numel(grp_labels);
n_tp=numel(tp_labels);%2;
n_gp=numel(gps_labels);%4;
bp_mat=nan(sum(N)*n_ver,n_tp,n_gp);%bp_mat=nan(max_length*n_grp,n_tp,n_gp);
catIdx=[];
for iGrp=1:n_grp
    catIdx=[catIdx; iGrp*ones(N(iGrp)*n_ver,1)];
end
%catIdx=[zeros(max_length,1);ones(max_length,1)];
catIdx=repmat(catIdx,n_tp,1);
%cat markers
category_m={'o','+','s','*'};
category_c={'r','b','g','m'};
gp_ind=0;
for j=1:n_gp
    for i=1:n_tp
        grp_ind=0;
        for k=1:n_grp
            load(files.(['tp' num2str(i)]){k});
%             if k==1
%                 [m,n]=size(gps);
%                 n_ver=m/n_gp;
%             end
            %display(['max. val. ' files.(['tp' num2str(i)]){k} ' : ' num2str(max(gps(:)))])
            gp=gps(gp_ind+1:gp_ind+n_ver,:);
            bp_mat(grp_ind+1:grp_ind+numel(gp(:)),i,j)=gp(:);
            grp_ind=grp_ind+max_length;
        end
        
        
    end
    subplot(1,n_gp,j)%1 or n_tp
    if boxplot_flag
        %boxplot(bp_mat)
    else
        plotSpread(bp_mat(:,:,j),'categoryIdx',catIdx,...
            'categoryMarkers',category_m(1:n_grp),'categoryColors', ...
            category_m(1:n_grp),'xNames',tp_labels)
    end
    title([gps_labels{j} ' tp ' num2str(i)],'Interpreter','none')
    ylabel(gps_labels{j},'Interpreter','none')
    legend(grp_labels)
    gp_ind=gp_ind+n_ver;
end
set(gcf,'Color',[1 1 1])



