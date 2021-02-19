function update_data__sPV_o3loss(tag_alt_levels,T_alt,qy,corr_other)
%TAG_DATA_BY_SPV tag each measurement as inside/on the edge/outside of the
%polar vortexbased on line-of-dight DMP information
%
% Measurements are tagged in/out if sPV at all specified altitude levels is
% above/below edge values. Otherwise the measurement is tagged as edge
%
% A new column (in_edge_out) is appended to each table in the PEARL datset,
% and the tagged dataset is saved separately
%
% in_edge_out:
%   -1: iside the vortex
%    0: on the vortex edge
%    1: outside the vortex

%% input

% system path
main_dir='/home/kristof/work/';

% load data (saved by load_PEARL_data.m)
load([main_dir 'PEARL_ozone_depletion/PEARL_dataset_qy' qy '.mat'])

% altitude levels considered in vortex location tag
if nargin==0, tag_alt_levels=16:2:22; end

% check that altitude levels are present
if ~isempty(setdiff(tag_alt_levels,alt_dmp)), error('Can only select existing DMP levels'), end

% indices of selected levels
[~,~,alt_ind]=intersect(tag_alt_levels,alt_dmp);

% vortex edge definition
vortex_in=1.6e-4; % inside edge; sPV greater than this is inside of the vortex 
vortex_out=1.2e-4; % outslide edge; sPV less than this is outside of the vortex 

du=2.687e16;

%% get tags

% single table datasets
tags=get_tags(gbs_o3.spv(:,alt_ind),vortex_in,vortex_out);
gbs_o3.in_edge_out=tags;

tags=get_tags(gbs_no2.spv(:,alt_ind),vortex_in,vortex_out);
gbs_no2.in_edge_out=tags;

tags=get_tags(saoz_o3.spv(:,alt_ind),vortex_in,vortex_out);
saoz_o3.in_edge_out=tags;

tags=get_tags(saoz_no2.spv(:,alt_ind),vortex_in,vortex_out);
saoz_no2.in_edge_out=tags;

tags=get_tags(gbs_oclo.spv(:,alt_ind),vortex_in,vortex_out);
gbs_oclo.in_edge_out=tags;

tags=get_tags(gbs_bro.spv(:,alt_ind),vortex_in,vortex_out);
gbs_bro.in_edge_out=tags;

tags=get_tags(brewer.spv(:,alt_ind),vortex_in,vortex_out);
brewer.in_edge_out=tags;

tags=get_tags(pandora.spv(:,alt_ind),vortex_in,vortex_out);
pandora.in_edge_out=tags;

tags=get_tags(slimcat.spv(:,alt_ind),vortex_in,vortex_out);
slimcat.in_edge_out=tags;

% bruker data
for n=fieldnames(bruker)'
    tags=get_tags(bruker.(n{1}).spv(:,alt_ind),vortex_in,vortex_out);
    bruker.(n{1}).in_edge_out=tags;
    
end

%% tag interpolated results from SLIMCAT
% to identify when interpolation is between in-vortex and out-of-vortex
% points

gbs_o3.in_edge_out_slimcat=interp1(slimcat.mjd2k,slimcat.in_edge_out,gbs_o3.mjd2k);
saoz_o3.in_edge_out_slimcat=interp1(slimcat.mjd2k,slimcat.in_edge_out,saoz_o3.mjd2k);
bruker.o3.in_edge_out_slimcat=interp1(slimcat.mjd2k,slimcat.in_edge_out,bruker.o3.mjd2k);
brewer.in_edge_out_slimcat=interp1(slimcat.mjd2k,slimcat.in_edge_out,brewer.mjd2k);
pandora.in_edge_out_slimcat=interp1(slimcat.mjd2k,slimcat.in_edge_out,pandora.mjd2k);


%% add strat ozone, no2 column for bruker

% calculate 12-90 km ozone partial columns -- ignores actual tropopause height!
[alt_bk,layer_h,~,~,part_prof,dof]=...
    read_bruker_prof_avk('O3','/home/kristof/work/bruker/PEARL_ozone_depletion/',...
                         bruker.o3.mjd2k);
part_col_tmp=integrate_nonuniform(...
    alt_bk*1e5,part_prof,12e5,90e5,'midpoint', layer_h*1e5 );

bruker.o3.strat_col=part_col_tmp'./du;

% calculate 12-60 km NO2 partial columns to match DOAS
[alt_bk,layer_h,~,~,part_prof,dof]=...
    read_bruker_prof_avk('NO2','/home/kristof/work/bruker/PEARL_ozone_depletion/',...
                         bruker.no2.mjd2k);
part_col_tmp=integrate_nonuniform(...
    alt_bk*1e5,part_prof,12e5,60e5,'midpoint', layer_h*1e5 );

bruker.no2.strat_col=part_col_tmp';
bruker.no2.strat_col_scaled=bruker.no2.strat_col.*bruker.no2.scale_factor;


%% other additions

% select level for temperature plots
ind=find(alt_dmp==T_alt);

gbs_o3.T_1alt=gbs_o3.T(:,ind);
gbs_no2.T_1alt=gbs_no2.T(:,ind);
saoz_o3.T_1alt=saoz_o3.T(:,ind);
saoz_no2.T_1alt=saoz_no2.T(:,ind);
gbs_oclo.T_1alt=gbs_oclo.T(:,ind);
gbs_bro.T_1alt=gbs_bro.T(:,ind);
brewer.T_1alt=brewer.T(:,ind);
pandora.T_1alt=pandora.T(:,ind);

for i=fieldnames(bruker)'
    bruker.(i{1}).T_1alt=bruker.(i{1}).T(:,ind);
end
      
slimcat.T_1alt=slimcat.T(:,ind);

% select level for sPV plots
gbs_o3.spv_1alt=gbs_o3.spv(:,ind);
gbs_no2.spv_1alt=gbs_no2.spv(:,ind);
saoz_o3.spv_1alt=saoz_o3.spv(:,ind);
saoz_no2.spv_1alt=saoz_no2.spv(:,ind);
gbs_oclo.spv_1alt=gbs_oclo.spv(:,ind);
gbs_bro.spv_1alt=gbs_bro.spv(:,ind);
brewer.spv_1alt=brewer.spv(:,ind);
pandora.spv_1alt=pandora.spv(:,ind);

for i=fieldnames(bruker)'
    bruker.(i{1}).spv_1alt=bruker.(i{1}).spv(:,ind);
end
      
slimcat.spv_1alt=slimcat.spv(:,ind);


% calculate slimcat differences
gbs_o3.slimcat_absdiff=gbs_o3.tot_col_active-gbs_o3.tot_col;
gbs_o3.slimcat_reldiff=100*(gbs_o3.tot_col_active-gbs_o3.tot_col)./gbs_o3.tot_col;

saoz_o3.slimcat_absdiff=saoz_o3.tot_col_active-saoz_o3.tot_col;
saoz_o3.slimcat_reldiff=100*(saoz_o3.tot_col_active-saoz_o3.tot_col)./saoz_o3.tot_col;

brewer.slimcat_absdiff=brewer.tot_col_active-brewer.tot_col;
brewer.slimcat_reldiff=100*(brewer.tot_col_active-brewer.tot_col)./brewer.tot_col;

pandora.slimcat_absdiff=pandora.tot_col_active-pandora.tot_col;
pandora.slimcat_reldiff=100*(pandora.tot_col_active-pandora.tot_col)./pandora.tot_col;

for i=fieldnames(bruker)'
    if ~strcmp(i,'no2')
        bruker.(i{1}).slimcat_absdiff=bruker.(i{1}).tot_col_active-bruker.(i{1}).tot_col;
        bruker.(i{1}).slimcat_reldiff=...
            100*(bruker.(i{1}).tot_col_active-bruker.(i{1}).tot_col)./bruker.(i{1}).tot_col;
    end
end

%% correct for HCl, HNO3 trends

if strcmp(corr_other,'_corrected')
    
    yrs_corr=unique(bruker.hcl.year);
    [ correction ] = hf_trend(yrs_corr,bruker.hcl);
    [~,~,ind]=intersect_repeat(bruker.hcl.year,yrs_corr);
    tmp=correction(ind);
    bruker.hcl.tot_col=bruker.hcl.tot_col-tmp;

    yrs_corr=unique(bruker.hno3.year);
    [ correction ] = hf_trend(yrs_corr,bruker.hno3);
    [~,~,ind]=intersect_repeat(bruker.hno3.year,yrs_corr);
    tmp=correction(ind);
    bruker.hno3.tot_col=bruker.hno3.tot_col-tmp;
    
elseif isempty(corr_other)
    disp('No trend correction for HCl, HNO3')
else
    error('invalid option for HCl, HNO3 trend correction')
end
    
%% correct for HF trend
yrs_corr=unique(bruker.hf.year);
[ correction ] = hf_trend(yrs_corr,bruker.hf);

for i=fieldnames(bruker)'
    
    [~,~,ind]=intersect_repeat(bruker.(i{1}).year,yrs_corr);
    tmp=correction(ind);
    
    if strcmp(i{1},'hf')
        bruker.(i{1}).tot_col_corrected=bruker.(i{1}).tot_col-tmp;
    elseif strcmp(i,'no2')
        bruker.(i{1}).tot_col_hf_scaled_corrected=...
            bruker.(i{1}).tot_col_scaled./(bruker.(i{1}).tot_col_hf-tmp);
        bruker.(i{1}).strat_col_hf_scaled_corrected=...
            bruker.(i{1}).strat_col_scaled./(bruker.(i{1}).tot_col_hf-tmp);        
    elseif strcmp(i,'o3')
        bruker.(i{1}).tot_col_hf_scaled_corrected=...
            (bruker.(i{1}).tot_col*du)./(bruker.(i{1}).tot_col_hf-tmp);
    else
        bruker.(i{1}).tot_col_hf_scaled_corrected=...
            bruker.(i{1}).tot_col./(bruker.(i{1}).tot_col_hf-tmp);
    end
end



%% save updated file

save([main_dir 'PEARL_ozone_depletion/PEARL_dataset_tagged.mat'],...
     'alt_dmp', 'tag_alt_levels',...
     'gbs_o3', 'gbs_no2', 'saoz_o3', 'saoz_no2', 'gbs_oclo', 'gbs_bro',...
     'bruker', 'brewer', 'pandora', 'slimcat','qy');

end

%%
function tags=get_tags(spv_in,vortex_in,vortex_out)

    % get vortex position along line of sight:
    % if measurements at all altitude levels are inside:  tag = -1
    % if measurements at any level are on the edge:       tag = 0
    % if measurements at all altitude levels are outside: tag = 1

    tags=zeros(length(spv_in),1);
    
    tags(all(spv_in>vortex_in,2))=-1;
    tags(all(spv_in<vortex_out,2))=1;

end