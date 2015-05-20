%% Vars initialization
data_dir='/Users/gabocas/Documents/MATLAB/GraphVar_beta_v_06/workspaces/tms_fc_1-6/data/Signals/pos2';
wind_length=40;
step_size=10;
n_dyns=600;
n_vert=264;
n_wind=(n_dyns-wind_length)/step_size;
data=struct([]);

%% Calculation
[~,files]=system(['ls ' data_dir '/*mat']);
files=strsplit(files);
n_subj=numel(files)-1;
CMs=nan(n_vert,n_vert,n_wind);
cc=nan(n_vert,n_wind);
ge=nan(1,n_wind);
strength=nan(n_vert,n_wind);
for fId=1:n_subj
    display(['Subject ' num2str(fId)])
    load(files{fId});
    %t_pointer=1;
    CMs=nan(n_vert,n_vert,n_wind);
    cc=nan(n_vert,n_wind);
    ge=nan(1,n_wind);
    strength=nan(n_vert,n_wind);
    for  wId=1:step_size:n_dyns-wind_length
        t_pointer=((wId-1)/10)+1;
        CMs(:,:,t_pointer)=(corr(ROISignals(wId:wId+wind_length-1,:))+1)./2;%data(fId).
        cc(:,t_pointer)=clustering_coef_wu(CMs(:,:,t_pointer));%clust. coef
        ge(:,t_pointer)=efficiency_wei(weight_conversion(CMs(:,:,t_pointer),'normalize'));%global eff.
        strength(:,t_pointer)=strengths_und(CMs(:,:,t_pointer));%strength
    end
    data(fId).CMs=CMs;%nan(n_vert,n_vert,n_wind);
    data(fId).cc=cc;%nan(n_vert,n_wind);
    data(fId).ge=ge;%nan(1,n_wind);
    data(fId).strength=strength;
    %t_pointer=t_pointer+1;
end

%% Stats
gp_labels={'Strength','Clustering coef.','Global efficiency'};
N=[6 6 6];
n_groups=numel(N);
ind=1;
var_cc=nan(n_vert,n_subj);
var_ge=nan(1,n_subj);
var_st=nan(n_vert,n_subj);
for gId=1:n_groups
    for sId=ind:ind+N(gId)-1
        var_cc(:,sId)=var(data(sId).cc');
        var_ge(:,sId)=var(data(sId).ge');
        var_st(:,sId)=var(data(sId).strength');
    end
    ind=ind+N(gId);
end
G=[ones(1,N(1)), 2*ones(1,N(1)), 3*ones(1,N(1))];
subplot(1,3,1), boxplot(var_st,G), title(gp_labels{1}), ylabel('variance')
set(gca,'Xtick',1:numel(N),'XtickLabel',{'preTMS','pos1','pos2'});
subplot(1,3,2), boxplot(var_cc,G), title(gp_labels{2}), ylabel('variance')
set(gca,'Xtick',1:numel(N),'XtickLabel',{'preTMS','pos1','pos2'});
subplot(1,3,3), boxplot(var_ge,G), title(gp_labels{3}), ylabel('variance')
set(gca,'Xtick',1:numel(N),'XtickLabel',{'preTMS','pos1','pos2'});
set(gcf,'color',[1 1 1]);
        