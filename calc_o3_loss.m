% function [ output_args ] = calc_o3_loss( input_args )
%CALC_O3_LOSS Summary of this function goes here
%   Detailed explanation goes here

mean_loss=0;
max_loss=0;
max_loss_day=0;
daily_loss=1;
passive_comp=0;

% load tagged file
load('/home/kristof/work/PEARL_ozone_depletion/PEARL_dataset_tagged.mat')

%% add loss values
    
gbs_o3.abs_loss=gbs_o3.tot_col_passive-gbs_o3.tot_col;
gbs_o3.rel_loss=100*(gbs_o3.tot_col_passive-gbs_o3.tot_col)./gbs_o3.tot_col_passive;

saoz_o3.abs_loss=saoz_o3.tot_col_passive-saoz_o3.tot_col;
saoz_o3.rel_loss=100*(saoz_o3.tot_col_passive-saoz_o3.tot_col)./saoz_o3.tot_col_passive;

bruker.o3.abs_loss=bruker.o3.tot_col_passive-bruker.o3.tot_col;
bruker.o3.rel_loss=100*(bruker.o3.tot_col_passive-...
    bruker.o3.tot_col)./bruker.o3.tot_col_passive;

brewer.abs_loss=brewer.tot_col_passive-brewer.tot_col;
brewer.rel_loss=100*(brewer.tot_col_passive-brewer.tot_col)./brewer.tot_col_passive;

%%
if mean_loss
    data=gbs_o3;

    %%% last 10 days of in-vortex meas for 2011, similar for 2020
    % ind=(data.day>=71 & data.day<=80 & data.year==2011 & data.in_edge_out==-1);
    % ind=(data.day>=72 & data.day<=81 & data.year==2020 & data.in_edge_out==-1);

    %%% last 10 days of in-vortex meas for 2020
    % ind=(data.day>=81 & data.day<=90 & data.year==2020 & data.in_edge_out==-1);

    %%% april measurements in 2020
    % ind=(data.day>=100 & data.day<=109 & data.year==2020 & data.in_edge_out==-1);
    % ind=(data.day>=92 & data.day<=121 & data.year==2020 & data.in_edge_out==-1);

    % ind=(data.in_edge_out==-1 & (data.year==2000 | data.year==2005 | data.year==2007 | data.year==2014 | ...
    %                             (data.year==2011 & data.fractional_time<71.25) | ...
    %                             (data.year==2020 & data.fractional_time<66.25) ));

    %%

    % data=bruker.o3;
    % ind=(data.year==2011 & data.in_edge_out==-1);

    %%

    % data=brewer;
    % ind=(data.year==2020 & data.in_edge_out==-1 & data.fractional_time>92.25);
    % ind=(data.year==2020 & data.in_edge_out==-1 & ...
    %      data.fractional_time>99.25 & data.fractional_time<109.25);

    %%
    fprintf('%3.1f DU (%2.1f%%)\n', [nanmean(data.abs_loss(ind)), nanmean(data.rel_loss(ind))])

end

if daily_loss
    
%     data=gbs_o3;
%     data.err=sqrt(gbs_o3.sigma_mean_vcd.^2 + gbs_o3.std_vcd.^2);
%     data.err=100*sqrt(gbs_o3.sigma_mean_vcd.^2 + gbs_o3.std_vcd.^2)./gbs_o3.tot_col;
    
    data=saoz_o3;
%     data.err=saoz_o3.std_vcd;
    data.err=100*saoz_o3.std_vcd./saoz_o3.tot_col;
%     
%     data=bruker.o3;
%     data.err=sqrt(bruker.o3.tot_col_err_rand.^2 + bruker.o3.tot_col_err_sys.^2);
%     data.err=100*sqrt(bruker.o3.tot_col_err_rand.^2 + bruker.o3.tot_col_err_sys.^2)./bruker.o3.tot_col;
    
%     data=brewer;
%     data.err=brewer.StdDevO3;
%     data.err=brewer.StdDevO3./brewer.ColumnO3;
    
    vortex='in';
    type='rel';
    
    if strcmp(type,'rel')
        bins=-40:3:20;
        o3_loss=data.rel_loss;
    elseif strcmp(type,'abs')
        bins=-200:20:0;
        o3_loss=data.abs_loss;
    end
    
    for yr=[2011,2020]
        if strcmp(vortex,'all')
            ind=data.year==yr;
        elseif strcmp(vortex,'in')
            ind=(data.year==yr & data.in_edge_out<0 & data.in_edge_out_slimcat==-1);
        elseif strcmp(vortex,'out')
            ind=(data.year==yr & data.in_edge_out>0);
        elseif strcmp(vortex,'out+edge')
            ind=(data.year==yr & data.in_edge_out>=0);
        end

        tmp_in=array2table([data.fractional_time(ind),-1*o3_loss(ind),data.err(ind)],...
            'VariableNames',{'fractional_time','col','err'});
        dmean=get_daily_stats(tmp_in,'col',1,1);

        xx=ft_to_date(dmean.doy-0.5,yr);
        xx.Year=0;
        
        if yr==2011
            xx_11=xx;
            dmean_11=dmean;
        elseif yr==2020
            xx_20=xx;
            dmean_20=dmean;
        end
    end
    
    figure()
    subplot(211)
    plot(xx_11,dmean_11.mean,'s-','color','b','linewidth',1.5), hold on
    plot(xx_20,dmean_20.mean,'s-','color','r','linewidth',1.5), hold on

    subplot(212)
    histogram(dmean_11.mean,bins,'normalization','probability'); hold on
    histogram(dmean_20.mean,bins,'normalization','probability');
    
end

%% max loss in any one measurement
if max_loss
    for yr=[2011,2020]

        ind=find(data.year==yr & data.in_edge_out==-1);

        [tmp1,ind1]=max(data.abs_loss(ind));
        [tmp2,ind2]=max(data.rel_loss(ind));

        disp(' ')
        disp(num2str(yr))
        date_tmp=mjd2k_to_date(data.mjd2k(ind(ind1)));
        fprintf(['Max abs loss: %3.1f DU on ' datestr(date_tmp,'mmm dd HH:MM') '\n'], tmp1)

        date_tmp=mjd2k_to_date(data.mjd2k(ind(ind2)));
        fprintf(['Max rel loss: %2.1f%% on ' datestr(date_tmp,'mmm dd HH:MM') '\n'], tmp2)
        disp(' ')

    end
end

%% max ozone loss on single day
if max_loss_day
    for yr=[2011,2020]

        dmean_abs=get_daily_stats(data(data.year==yr & data.in_edge_out==-1,:),'abs_loss',1,0);
        dmean_rel=get_daily_stats(data(data.year==yr & data.in_edge_out==-1,:),'rel_loss',1,0);


        disp(' ')

        [tmp,ind]=max(dmean_abs.mean);
        disp(num2str(yr))
        date_tmp=dayofyear_inverse(yr,dmean_abs.doy(ind));
        date_tmp=datetime(date_tmp.year,date_tmp.month,date_tmp.day);
        fprintf(['Max abs loss: %3.1f DU on ' datestr(date_tmp,'mmm dd') '\n'], tmp)

        [tmp,ind]=max(dmean_rel.mean);
        date_tmp=dayofyear_inverse(yr,dmean_rel.doy(ind));
        date_tmp=datetime(date_tmp.year,date_tmp.month,date_tmp.day);
        fprintf(['Max rel loss: %2.1f%% on ' datestr(date_tmp,'mmm dd') '\n'], tmp)

    end
end

%% slimcat vs ozonesonde
if passive_comp
    figure()
    load('sonde_table.mat')
    load('PEARL_dataset_tagged.mat')
    
    ind=(sonde.doy>=335);
    % ind=(sonde.doy>=335 & sonde.year<2019); % no impact
    
    rel_diff=100*(sonde.o3_passive-sonde.o3)./sonde.o3;
    plot(sonde.fractional_time(ind), rel_diff(ind),'ko')
    nanmean(rel_diff(ind))
    nanstd(rel_diff(ind))/sqrt(sum(ind))
    
    abs_diff=(sonde.o3_passive-sonde.o3);
    nanmean(abs_diff(ind))
    nanstd(abs_diff(ind))/sqrt(sum(ind))
end

%% pathlength differences
% ind=(gbs_o3.year==2020 & gbs_o3.day>92 & gbs_o3.day<121);
% mean(distance(gbs_o3.lat_dmp(ind,2),gbs_o3.lon_dmp(ind,2),...
%               gbs_o3.lat_dmp(ind,4),gbs_o3.lon_dmp(ind,4))* (pi/180) * R_e)
% 
% ind=(brewer.year==2020 & brewer.fractional_time>99.25 & brewer.fractional_time<109.25);
% mean(distance(brewer.lat_dmp(ind,2),brewer.lon_dmp(ind,2),...
%               brewer.lat_dmp(ind,4),brewer.lon_dmp(ind,4))* (pi/180) * R_e)

% end

