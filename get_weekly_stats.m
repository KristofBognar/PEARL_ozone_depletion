function mean_out=get_weekly_stats(data,colname)

    bin_width=7; % must be odd number
    bin_min=3; % minimum number of datapoints to calculate mean in each bin
    bins=54:bin_width:131;

    yr_all=unique(data.year)';

    % initialize output array (year and days are fixed)
    mean_out=NaN(length(bins)*length(yr_all),6);
    tmp=repmat(yr_all, length(bins), 1);
    mean_out(:,1) = tmp(:);
    mean_out(:,2) = repmat(bins,1,length(yr_all))';

    % loop over each year
    for i=1:length(yr_all)

        % mean diurnal diffs
        for j=1:length(bins)

            save_ind=(i-1)*length(bins) + j;

            % select days within current bin
            ind=( abs(data.doy-bins(j))<bin_width/2 & ...
                  data.year==yr_all(i) & ...
                  ~isnan(data.(colname)));

            % take only the bins with enough days (number of datapoints
            % might be greater if averaging raw data, but it might all be
            % one day -- notgreat for weekly average)
%             if sum(ind)>=bin_min
            if length(unique(data.doy(ind)))>=bin_min
                mean_out(save_ind,3)=mean(data.(colname)(ind));
                mean_out(save_ind,4)=std(data.(colname)(ind));
                mean_out(save_ind,5)=min(data.(colname)(ind));
                mean_out(save_ind,6)=max(data.(colname)(ind));
            end

        end
    end

    mean_out=array2table(mean_out,'variablenames',{'year','doy',colname,'std','min','max'});

end
