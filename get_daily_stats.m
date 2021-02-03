function dmean=get_daily_stats(data,colname,show_gaps,add_single)

    data(isnan(data.(colname)),:)=[];

    try
        do_err=1;
        err=data.err;
    catch
        do_err=0;
    end
    
    % find unique days
    % convert ft to local day of year (assuming midnight is at 05:48)
    data.fractional_time=floor(data.fractional_time+(18.2/24)); 
    unique_days=unique(data.fractional_time); 
   
    % what to do with data gaps?
    if show_gaps % days with no data recorded as nan
        all_days=[unique_days(1):unique_days(end)]';
    else % only use days with data (plot doesn't show gaps)
        all_days=unique_days;
    end
    
    % initialize array
    dmean=NaN(length(all_days),6);

    % loop over unique days
    for i=1:length(all_days)

        % find data for given day
        ind=data.fractional_time==all_days(i);
        tmp=data.(colname)(ind);

        % save if data exists 
        if length(tmp)==1 && add_single % save individual value if specified
            dmean(i,1)=tmp;
            dmean(i,2)=0;
            if do_err, dmean(i,6)=err(ind); end
        elseif length(tmp)>1 % average of more than 1 point
            dmean(i,1)=nanmean(tmp);
            if length(tmp)>2 % save std only if more than 2 points
                dmean(i,2)=nanstd(tmp);
            else
                dmean(i,2)=0;
            end
            dmean(i,3)=min(tmp);
            dmean(i,4)=max(tmp);
            dmean(i,5)=std(tmp)/sqrt(length(tmp));
            if do_err, dmean(i,6)=sqrt(sum(err(ind).^2))/length(tmp); end
        end
        
    end
    
    dmean=array2table([all_days,dmean],'variablenames',{'doy','mean','std','min','max',...
        'std_err','propagated_err'}); 

end
