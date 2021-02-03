function load_PEARL_data()
%COLLECT_DATA Load/save all datasets used in PEARL ozone depletion study
%

main_dir='/home/kristof/work/';
du=2.687e16;

% last day of each year to be included (month and day)
mm=5;
dd=5;

% HCl filter (empty string for regular filters)
hcl_filt='_neg_VMR_included';

% SLIMCAT ClOOCl quantum yield
qy='1';

%% calculate last date in various formats

% last acceptable date/time in ~local time
last_date=datetime(0,mm,dd+1)+hours(5);

% last acceptable doy (local day)
last_day=datenum(datetime(0,mm,dd))-1; % year 0 is leap year, convert to non-leap doy

%% GBS data

% merged GBS data (from merge_reanalysis_VCDs.m and merge_GBS.m)
%%% includes temporary 2020 data (RD works for NO2, but sondes needed for O3)
%%% sonde data used for O3 up to and including day 106
load([main_dir 'PEARL_ozone_depletion/GBS_O3.mat'])
load([main_dir 'PEARL_ozone_depletion/GBS_NO2.mat'])
% load([main_dir 'PEARL_ozone_depletion/GBS_NO2_UV.mat'])

% keep spring data only
gbs_o3(( (mod(gbs_o3.year,4)==0 & gbs_o3.day>last_day+1) |...
         (mod(gbs_o3.year,4)~=0 & gbs_o3.day>last_day) ),:)=[];
gbs_no2(( (mod(gbs_no2.year,4)==0 & gbs_no2.day>last_day+1) |...
          (mod(gbs_no2.year,4)~=0 & gbs_no2.day>last_day) ),:)=[];

% % remove single twilights for NO2 (should be very few, if any)
% % result of filtering (if one twilight has large error, it's removed)
% yd=gbs_no2.year*1000+gbs_no2.day;
% tmp=unique(yd);
% 
% count=histc(yd,tmp);
% tmp=tmp(count==1);
% 
% if ~isempty(tmp)
%     for i=tmp'
%         gbs_no2(yd==i,:)=[];
%         yd(yd==i,:)=[];
%     end
% end

%% GBS OClO and BrO data
load([main_dir 'PEARL_ozone_depletion/GBS_OClO_BrO.mat'])

gbs_oclo(( (mod(gbs_oclo.year,4)==0 & gbs_oclo.day>last_day+1) |...
         (mod(gbs_oclo.year,4)~=0 & gbs_oclo.day>last_day) ),:)=[];
gbs_bro(( (mod(gbs_bro.year,4)==0 & gbs_bro.day>last_day+1) |...
          (mod(gbs_bro.year,4)~=0 & gbs_bro.day>last_day) ),:)=[];

% remove three suspect BrO datapoints
gbs_bro(gbs_bro.dscd>5e14,:)=[];

%% SAOZ data
load([main_dir 'SAOZ/saoz_o3.mat'])
saoz_o3=saoz;

load([main_dir 'SAOZ/saoz_no2.mat'])
saoz_no2=saoz;

% keep spring data only
saoz_o3(( (mod(saoz_o3.year,4)==0 & saoz_o3.day>last_day+1) |...
          (mod(saoz_o3.year,4)~=0 & saoz_o3.day>last_day) ),:)=[];
saoz_no2(( (mod(saoz_no2.year,4)==0 & saoz_no2.day>last_day+1) |...
           (mod(saoz_no2.year,4)~=0 & saoz_no2.day>last_day) ),:)=[];

% remove d54 for 2011 (negative NO2 column)
saoz_no2((saoz_no2.year==2011 & saoz_no2.day==54),:)=[];


%% bruker data
bruker_tg={'O3','NO2','HCl','HNO3','ClONO2','HF','N2O'};

bruker_struct=struct();

for i=1:length(bruker_tg)
    
    % load data file
    if strcmpi(bruker_tg{i},'hcl')
        disp(['Reading HCl data with filter: ' hcl_filt])
        load([main_dir 'bruker/PEARL_ozone_depletion/bruker_' lower(bruker_tg{i}) hcl_filt '.mat']);
    else
        load([main_dir 'bruker/PEARL_ozone_depletion/bruker_' lower(bruker_tg{i}) '.mat']);
    end
    
    % select spring measurements only
    tmp=bruker.DateTime;
    tmp.Year=0;
    bruker(tmp>last_date,:)=[];
    
    % add DOFS info
    if strcmpi(bruker_tg{i},'hcl')
        [~,~,~,~,~,dofs]=read_bruker_prof_avk(lower(bruker_tg{i}),...
                                              [main_dir 'bruker/PEARL_ozone_depletion/'],...
                                              bruker.mjd2k,'bruker',hcl_filt);
    else
        [~,~,~,~,~,dofs]=read_bruker_prof_avk(lower(bruker_tg{i}),...
                                              [main_dir 'bruker/PEARL_ozone_depletion/'],...
                                              bruker.mjd2k,'bruker','');
    end
    
    bruker.dofs=dofs;
    
    % save in structure
    bruker_struct.(lower(bruker_tg{i}))=bruker;
    
end

bruker=bruker_struct;
clearvars bruker_struct

% remove few outlying HCl datapoints
bruker.hcl(bruker.hcl.tot_col>1e16,:)=[];


%% brewer #69 data

load([main_dir 'brewer/brewer69_2001-2020.mat'])
brewer=brewer_ds;

% brewer filters:
%   AMF<5, stdO3<2.5: as recommended by Xiaoyi
%       More lenient filter: AMF<6, stdO3<3 (doesn't add many points)
%   SO2<40: very few points, gets rid of remaining anomalous O3 values
brewer=brewer(brewer.Airmass<5 & brewer.StdDevO3<2.5 & brewer.ColumnSO2<40,:);

% select spring measurements
tmp=brewer.DateTime;
tmp.Year=0;
brewer(tmp>last_date,:)=[];

% add extra fields
brewer.year=brewer.DateTime.Year;
brewer.mjd2k=mjd2k(brewer.DateTime);
brewer.fractional_time=mjd2k_to_ft(brewer.mjd2k);


%% Pandora 144 data

load('/home/kristof/work/PEARL_ozone_depletion/PGN/Pandora122_ozone_corrected.mat')
pandora=Pandora_corrected;


% filter data (L2 flag)
% high quality: 0,10,20; medium: 1,11,21, low: 2,12,22
pandora=pandora((pandora.L2==0 | pandora.L2==10 | pandora.L2==20),:);

tmp=pandora.UTC;
tmp.Year=0;
pandora(tmp>last_date,:)=[];

% add extra fields
pandora.Properties.VariableNames{1} = 'DateTime';
pandora.year=pandora.DateTime.Year;
pandora.mjd2k=mjd2k(pandora.DateTime);
pandora.fractional_time=mjd2k_to_ft(pandora.mjd2k);


%% SLIMCAT data

load([main_dir 'models/SLIMCAT/QY_' qy '/slimcat_columns_midpoint.mat'])

slimcat(isnan(slimcat.o3),:)=[];

% select spring measurements
tmp=slimcat.DateTime;
tmp.Year=0;
slimcat(tmp>last_date,:)=[];

%% scale NO2 to local noon

tmp=scale_no2_column(gbs_no2.mjd2k);
gbs_no2.model_no2=tmp(:,1);
gbs_no2.scale_factor=tmp(:,2);
gbs_no2.tot_col_scaled=gbs_no2.mean_vcd.*gbs_no2.scale_factor;

tmp=scale_no2_column(saoz_no2.mjd2k);
saoz_no2.model_no2=tmp(:,1);
saoz_no2.scale_factor=tmp(:,2);
saoz_no2.tot_col_scaled=saoz_no2.mean_vcd.*saoz_no2.scale_factor;

tmp=scale_no2_column(bruker.no2.mjd2k);
bruker.no2.model_no2=tmp(:,1);
bruker.no2.scale_factor=tmp(:,2);
bruker.no2.tot_col_scaled=bruker.no2.tot_col.*bruker.no2.scale_factor;


%% match to DMPs

alt_dmp=[14:2:22];

[spv,temperature,theta,lat,lon]=...
    match_DMP_all(gbs_o3.fractional_time,gbs_o3.year,'DOAS_O3_VIS',alt_dmp);
gbs_o3.T=temperature;
gbs_o3.spv=spv;
gbs_o3.lat_dmp=lat;
gbs_o3.lon_dmp=lon;

[spv,temperature,theta,lat,lon]=...
    match_DMP_all(gbs_no2.fractional_time,gbs_no2.year,'DOAS_NO2_VIS',alt_dmp);
gbs_no2.T=temperature;
gbs_no2.spv=spv;
gbs_no2.lat_dmp=lat;
gbs_no2.lon_dmp=lon;

[spv,temperature,theta,lat,lon]=...
    match_DMP_all(saoz_o3.fractional_time,saoz_o3.year,'DOAS_O3_VIS',alt_dmp);
saoz_o3.T=temperature;
saoz_o3.spv=spv;
saoz_o3.lat_dmp=lat;
saoz_o3.lon_dmp=lon;

[spv,temperature,theta,lat,lon]=...
    match_DMP_all(saoz_no2.fractional_time,saoz_no2.year,'DOAS_NO2_VIS',alt_dmp);
saoz_no2.T=temperature;
saoz_no2.spv=spv;
saoz_no2.lat_dmp=lat;
saoz_no2.lon_dmp=lon;

%%%

%%%%%%%%% GBS OClO, BrO: use NO2-UV DMPs -- if there are UV measurements,
%%%%%%%%% the VCD retrieval was at least attempted: DMP should be there (add
%%%%%%%%% time threshold to DMP code anyway?)
[spv,temperature,theta,lat,lon]=...
    match_DMP_all(gbs_oclo.fractional_time,gbs_oclo.year,'DOAS_NO2_UV',alt_dmp);
gbs_oclo.T=temperature;
gbs_oclo.spv=spv;
gbs_oclo.lat_dmp=lat;
gbs_oclo.lon_dmp=lon;

[spv,temperature,theta,lat,lon]=...
    match_DMP_all(gbs_bro.fractional_time,gbs_bro.year,'DOAS_NO2_UV',alt_dmp);
gbs_bro.T=temperature;
gbs_bro.spv=spv;
gbs_bro.lat_dmp=lat;
gbs_bro.lon_dmp=lon;

%%%

for i=1:length(bruker_tg)
    
    [spv,temperature,theta,lat,lon]=...
        match_DMP_all(bruker.(lower(bruker_tg{i})).fractional_time,...
                         bruker.(lower(bruker_tg{i})).year,...
                         'BRUKER',alt_dmp);

    bruker.(lower(bruker_tg{i})).T=temperature;
    bruker.(lower(bruker_tg{i})).spv=spv;
    bruker.(lower(bruker_tg{i})).lat_dmp=lat;
    bruker.(lower(bruker_tg{i})).lon_dmp=lon;
    
end

%%%

[spv,temperature,theta,lat,lon]=...
    match_DMP_all(brewer.fractional_time,brewer.year,'BREWER69',alt_dmp);
brewer.T=temperature;
brewer.spv=spv;
brewer.lat_dmp=lat;
brewer.lon_dmp=lon;

%%%

[spv,temperature,theta,lat,lon]=...
    match_DMP_all(pandora.fractional_time,pandora.year,'PANDORA144',alt_dmp);
pandora.T=temperature;
pandora.spv=spv;
pandora.lat_dmp=lat;
pandora.lon_dmp=lon;

%%%

[spv,temperature,theta,lat,lon]=...
    match_DMP_all(slimcat.fractional_time,slimcat.year,'VERTICAL_EWS',alt_dmp);
slimcat.T=temperature;
slimcat.spv=spv;

%% final touches

%%% pair bruker HF measurements to other tracegases (for normalization)

% retrievals not simultaneous, need a cutoff time (in days):
dt=2/24;

for i=fieldnames(bruker)'
    if strcmp(i{1},'hf'), continue, end
    bruker.(i{1}) = merge_asof(bruker.(i{1}), bruker.hf, 'mjd2k', 'tot_col', dt, '_hf');
    if strcmp(i,'no2')
        bruker.(i{1}).tot_col_hf_scaled=bruker.(i{1}).tot_col_scaled./bruker.(i{1}).tot_col_hf;
    else
        bruker.(i{1}).tot_col_hf_scaled=bruker.(i{1}).tot_col./bruker.(i{1}).tot_col_hf;
    end
end

%%% rename columns for ease of plotting, and convert ozone to DU
gbs_o3.tot_col=gbs_o3.mean_vcd./du;
gbs_o3.sigma_mean_vcd=gbs_o3.sigma_mean_vcd./du;
gbs_o3.std_vcd=gbs_o3.std_vcd./du;
gbs_no2.tot_col=gbs_no2.mean_vcd;

saoz_o3.tot_col=saoz_o3.mean_vcd;
saoz_no2.tot_col=saoz_no2.mean_vcd;
brewer.tot_col=brewer.ColumnO3;
pandora.tot_col=pandora.O3_VCD_corrected;

bruker.o3.tot_col=bruker.o3.tot_col./du;
bruker.o3.tot_col_err_rand=bruker.o3.tot_col_err_rand./du;
bruker.o3.tot_col_err_sys=bruker.o3.tot_col_err_sys./du;

%%% match SLIMCAT data
gbs_o3.tot_col_passive=interp1(slimcat.mjd2k,slimcat.o3_passive,gbs_o3.mjd2k);
gbs_o3.tot_col_active=interp1(slimcat.mjd2k,slimcat.o3,gbs_o3.mjd2k);

saoz_o3.tot_col_passive=interp1(slimcat.mjd2k,slimcat.o3_passive,saoz_o3.mjd2k);
saoz_o3.tot_col_active=interp1(slimcat.mjd2k,slimcat.o3,saoz_o3.mjd2k);

for i=fieldnames(bruker)'
    if ~strcmp(i,'no2') % skip NO2, cannot interpolate due to diurnal variability
        bruker.(i{1}).tot_col_active=...
            interp1(slimcat.mjd2k,slimcat.(i{1}),bruker.(i{1}).mjd2k);
    end
end
bruker.o3.tot_col_passive=interp1(slimcat.mjd2k,slimcat.o3_passive,bruker.o3.mjd2k);

brewer.tot_col_passive=interp1(slimcat.mjd2k,slimcat.o3_passive,brewer.mjd2k);
brewer.tot_col_active=interp1(slimcat.mjd2k,slimcat.o3,brewer.mjd2k);

pandora.tot_col_passive=interp1(slimcat.mjd2k,slimcat.o3_passive,pandora.mjd2k);
pandora.tot_col_active=interp1(slimcat.mjd2k,slimcat.o3,pandora.mjd2k);


%% save data 
save([main_dir 'PEARL_ozone_depletion/PEARL_dataset_qy' qy '.mat'],...
     'alt_dmp', 'gbs_o3', 'gbs_no2', 'saoz_o3', 'saoz_no2',...
     'gbs_oclo', 'gbs_bro', 'bruker', 'brewer', 'pandora', 'slimcat','qy');

end

