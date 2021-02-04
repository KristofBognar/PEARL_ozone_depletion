

data=brewer;

years=unique(data.year)';
hf_mean=NaN(size(years));
hf_std=NaN(size(years));
hf_err=NaN(size(years));

for i=1:length(years)

    hf_mean(i)=mean(data.tot_col(data.year==years(i) & data.in_edge_out==1));
    hf_std(i)=std(data.tot_col(data.year==years(i) & data.in_edge_out==1));
    hf_err(i)=hf_std(i)/sqrt(sum(data.year==years(i)));
    
end

ind=isnan(hf_mean);
years(ind)=[];
hf_mean(ind)=[];
hf_std(ind)=[];
hf_err(ind)=[];

times=ft_to_mjd2k(zeros(size(years)),years);

[rfit,lfit]=TrendAnalysis(times',hf_mean');

fit=rfit;


fprintf('%1.3g +- %1.3g molec cm^{-2} yr^{-1}\n', [fit.trend, fit.trend_sig*fit.corr_factor])

fprintf('%1.1f years needed, have %2i\n', [fit.years_needed, length(years)])
