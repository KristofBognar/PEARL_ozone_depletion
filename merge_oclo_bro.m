function merge_oclo_bro(dscd_dir,save_dir)
%MERGE_OCLO_BRO Summary of this function goes here
%   Detailed explanation goes here


% load data
p_files=get_file_list(dscd_dir,'mat','PGBS*');

pgbs=[];

for ff=p_files
    
    load([dscd_dir ff{1}]);
    pgbs=[pgbs; data];
    
end

% calculate twilight averages
% [ut_oclo,ut_bro] = filter_and_average(utgbs);
[p_oclo,p_bro] = filter_and_average(pgbs);

% merge datasets
% gbs_oclo=merge(ut_oclo,p_oclo);
% gbs_bro=merge(ut_bro,p_bro);
gbs_oclo=p_oclo;
gbs_bro=p_bro;

% save
save([save_dir 'GBS_OClO_BrO.mat'], 'gbs_oclo', 'gbs_bro')

end

function [oclo_out, bro_out] = filter_and_average(table_in)
    
    %% fix spectra with bad times
    % bug in preprocs code: bins that straddle midnight still have
    % arithmetic time average, not proper datetime avg
    %
    % relevant spectra and SZA are fine, and were processed with the
    % correct reference (they still ended up in the correct daily file)
    %
    % bad lines identifiable by negative TotalExperimentTimesec
    
    table_in = correct_avg_twilight_time( table_in );

    %% filter data 
    %(use NO2-UV, RMS thresholds of 0.002 for SZA<87 and 0.003 for SZA>=87)
    % interested in 89-91 only, need RMS<0.003 RMS 
    % filters need to be applied separately
    table_in.OClOSlColoclo(table_in.OClORMS>=0.003)=NaN;
    table_in.BrOSlColbro(table_in.BrORMS>=0.003)=NaN;

    %% remove data outside desired SZA range 
    %%% preprocs code creates 0.5 deg bins centered on even or half degrees,
    %%% but the actual SZA recorded is the mean SZA of measurements in each
    %%% bin --> actual grid is not evenly spaced (offsets of 0.1-0.2 deg
    %%% common)
    %
    %%% 3 measurements around 90: real range is ~ 89.15-90.85 --> OK
    %                             includes +- half bin width
    %                             cutoff: 89.2-90.8
    %%% 5 measurements around 90: real range is ~ 89.55-91.45 --> too wide

    table_in(abs(table_in.SZA-90)>0.8,:)=[];
    
    %%% bad, need det lim for individual meas, THEN average
%     detlim_oclo=sqrt((mean(data_new.OClOSlErroclo(ind)))^2+(std(data_new.OClOSlColoclo(ind)))^2);
%     detlim_bro=sqrt((mean(data_new.BrOSlErrbro(ind)))^2+(std(data_new.BrOSlColbro(ind)))^2);

    %% break up by twilight, calculate mean dSCD
    
    % values to keep from each fitting window
    oclo_vars={'Year','Fractionalday','SZA','OClORefZm','OClORMS','OClOSlColoclo','OClOSlErroclo'};
    bro_vars={'Year','Fractionalday','SZA','BrORefZm','BrORMS','BrOSlColbro','BrOSlErrbro'};
    
    % initialize output
    oclo_out=[];
    bro_out=[];

    
    % convert utc to local day of year (Fractionalday has Jan. 1, 00:00 = 1!)
    doy=floor(table_in.Fractionalday-(5.75/24));
    
    % convert SAA to ampm index
    saa=table_in.SolarAzimuthAngle;
    saa(table_in.SolarAzimuthAngle<0)=0;
    saa(table_in.SolarAzimuthAngle>0)=1;
    
    % loop over each year
    for yr=unique(table_in.Year)'
        
        % loop over each day
        for dd=unique(doy(table_in.Year==yr))';
            
            %%% add noon sza filter here!!!
            
            % loop over twilights
            for ampm=0:1
                
                % need to separte OClO and BrO since RMS filter is independent
                oclo=table_in(table_in.Year==yr & doy==dd & saa==ampm,...
                                 oclo_vars);
                bro=table_in(table_in.Year==yr & doy==dd & saa==ampm,...
                                 bro_vars);

                % remove NaNs if any
                oclo(isnan(oclo.OClOSlColoclo),:)=[];
                bro(isnan(bro.BrOSlColbro),:)=[];

                % calculate average if:
                %   have more that 1 meas. and SZA range is greater than 1, OR
                %   have 1 meas only and it's close to 90, OR
                %   none of the above, but have at least 1 meas close to 90
				%
				% take average of fitting errors, so that the value still
				% characterizes the fitting error of the mean dscd, instead
				% of the uncertainty of the mean
                if ( (length(oclo.SZA)>1 && abs(min(oclo.SZA)-max(oclo.SZA))>1) || ...
                     (length(oclo.SZA)==1 && abs(oclo.SZA-90)<0.1) )
                    
                    % average values, add doy and ampm, add std of dSCDs
                    oclo_out=[oclo_out;[mean(oclo{:,:},1),std(oclo.OClOSlColoclo),dd,ampm]];
                    
                elseif any(abs(oclo.SZA-90)<0.1)
                    
                    % pick 90deg value(s) only, add doy and ampm, add std of dSCDs
                    ind=abs(oclo.SZA-90)<0.1;
                    oclo_out=[oclo_out;[mean(oclo{ind,:},1),std(oclo.OClOSlColoclo(ind)),dd,ampm]];
                    
                end

                if ( (length(bro.SZA)>1 && abs(min(bro.SZA)-max(bro.SZA))>1) || ...
                     (length(bro.SZA)==1 && abs(bro.SZA-90)<0.1) )
                    
                    % average values, add doy and ampm, add std of dSCDs
                    bro_out=[bro_out;[mean(bro{:,:},1),std(bro.BrOSlColbro),dd,ampm]];
                    
                elseif any(abs(bro.SZA-90)<0.1)
                    
                    % pick 90deg value(s) only, add doy and ampm, add std of dSCDs
                    ind=abs(bro.SZA-90)<0.1;
                    bro_out=[bro_out;[mean(bro{ind,:},1),std(bro.BrOSlColbro(ind)),dd,ampm]];
                    
                end
            end
        end
    end

    %% reorganize variables 
    
    % variable names in new table (so OClO and BrO match)
    varnames={'year','fractional_time','SZA','RefZm','RMS','dscd','dscd_err',...
              'dscd_std','day','ampm'};
    
    if length(varnames)-3~=length(oclo_vars), error('Double check table column naming!'), end
    
    % convert output to table
    oclo_out=array2table(oclo_out,'VariableNames',varnames);
    bro_out=array2table(bro_out,'VariableNames',varnames);
    
    % original column is QDOAS fractional day
    oclo_out.fractional_time=oclo_out.fractional_time-1;
    bro_out.fractional_time=bro_out.fractional_time-1;
    
    % add mjd2k values
    oclo_out.mjd2k=ft_to_mjd2k(oclo_out.fractional_time,oclo_out.year);
    bro_out.mjd2k=ft_to_mjd2k(bro_out.fractional_time,bro_out.year);
    
    % filter std values (when using single meas. instead of average, std=0)
    oclo_out.dscd_std(oclo_out.dscd_std==0)=NaN;
    bro_out.dscd_std(bro_out.dscd_std==0)=NaN;
    
end

function out = merge(t1,t2)
    
    % find matching twilights
    [~,ind1,ind2]=intersect(t1{:,{'year','day','ampm'}},t2{:,{'year','day','ampm'}},'rows');

    if ~isempty(in1) % if there is some overlap, average common twilights
        
        % average matching values 
        out=(t1{ind1,:}+t2{ind2,:})/2;
        out=array2table(out,'VariableNames',t1.Properties.VariableNames);

        % replace error average with quadrature
        out.dscd_err=sqrt( t1.dscd_err(ind1).^2 +t2.dscd_err(ind2).^2 )/2; 
        out.dscd_std=sqrt( t1.dscd_std(ind1).^2 +t2.dscd_std(ind2).^2 )/2; 

        % add rest of data
        ind12 = setdiff(1:height(t1), ind1);
        ind22 = setdiff(1:height(t2), ind2);

        out=[out; t1(ind12,:); t2(ind22,:)];

    else % if there is no overlap, just merge tables
        
        out=[t1;t2];
        
    end
    
    % sort by time
    out=sortrows(out,'mjd2k');
    
end





