function PEARL_vortex_plots()
%

%% select plots to show

o3_all=0;
no2_all=0;
other_all=0;
o3_loss=0;
tg_corr_all=0;

slimcat_o3=0;
slimcat_other=0;

other_hf=1;
corr_str='_corrected'; % '' for standard HF data, '_corrected' for HF trend correction


slimcat_vs_T=0;
tg_corr=0;
hist_o3=0;

%%% save plots? 1: bitmap pdf; 2: pdf; 3:jpg; 4: png
%%% simple PDF doesn't work with fill or colormap: use bitmap or jpg
save_figs=0;

%%% slimcat version
qy='1';

%% plotting setup

highlight=[2000,2005,2007,2011,2014,2015,2020];

plot_gray=[.65 .65 .65];  

plot_colors=flipud(parula(length(highlight)+1));
plot_colors(1,:)=[];
plot_colors(highlight==2011,:)=plot_colors(highlight==2020,:);
plot_colors(highlight==2020,:)=[1 .1 0];

% x_lim=[50,145];
x_lim=[50,125]; % could do 125, or even less
xlim_arr=[51,61,70,80,92,101,111,122,131,141];

global yr_fontsize
yr_fontsize=12;
txt_x=1.08;

fig_font='Arial'; % font for plotting

T_alt=18;

%% load data

% update vortex position tags
update_data__sPV_o3loss([16,18,20],T_alt,qy);

% load tagged file
load('/home/kristof/work/PEARL_ozone_depletion/PEARL_dataset_tagged.mat')

%%
if o3_all

    figure
    set(gcf, 'Position', [100, 100, 1000, 600]);
    fig_ax = tight_subplot(2,1,[0.07,0.07],[0.1,0.08],[0.08,0.13]);


    yr_all=unique(gbs_o3.year)';
    
    % merge non-vortex year ozone data
    data_in=struct();
    data_in.field1=gbs_o3;
    data_in.field2=saoz_o3;
    data_in.field3=bruker.o3;
    data_in.field4=brewer;

    axes(fig_ax(1))

    % add markers for legend
    plot(1,1,'ks'), hold on
    plot(1,1,'kd'), hold on
    plot(1,1,'kx'), hold on
    plot(1,1,'k+'), hold on
    plot(1,1,'k.','markersize',10), hold on
    legend({'GBS','SAOZ','Bruker FTIR','Brewer #69','Pandora'},'orientation','vertical',...
        'FontName',fig_font,'Position',[0.887 0.22 0.094 0.16]);
    
    % plot non-vortex avg
    plot_gray_area(data_in, 'tot_col', plot_gray, plot_gray+0.2, 1)
    
    % add explanatory text
    text(txt_x,0.87,sprintf('Outside the\nvortex:\n1999-2019'),...
         'units','normalized','fontweight','bold',...
         'fontsize',yr_fontsize,'color',plot_gray,'horizontalalignment','center',...
         'FontName',fig_font)

    text(txt_x,0.7,'2020',...
         'units','normalized','fontweight','bold',...
         'fontsize',yr_fontsize,'color',plot_gray-0.2,'horizontalalignment','center',...
         'FontName',fig_font)
     
    text(txt_x,0.53,sprintf('Inside the\nvortex:'),...
         'units','normalized','fontweight','bold',...
         'fontsize',yr_fontsize,'color',[.2 .2 .2],'horizontalalignment','center',...
         'FontName',fig_font)
     
    txt_y=0.38;

    % plot highlighted years in color
    for i=1:length(highlight)

        yr=highlight(i);

        %%% ozone plot
        axes(fig_ax(1))

        plot_yearly(yr,gbs_o3,'tot_col','s',plot_colors(i,:),'in')  
        plot_yearly(yr,saoz_o3,'tot_col','d',plot_colors(i,:),'in')  
        plot_yearly(yr,bruker.o3,'tot_col','x',plot_colors(i,:),'in')  
        plot_yearly(yr,brewer,'tot_col','+',plot_colors(i,:),'in')  
        plot_yearly(yr,pandora,'tot_col','.',plot_colors(i,:)-[.4 0 0],'in')  
        
        if yr==2020
            plot_yearly(yr,gbs_o3,'tot_col','s',plot_gray-0.2,'out')  
            plot_yearly(yr,saoz_o3,'tot_col','d',plot_gray-0.2,'out')  
            plot_yearly(yr,brewer,'tot_col','+',plot_gray-0.2,'out')  
        end
        
        % print selected year on the side
        text(txt_x,txt_y,num2str(yr),'units','normalized','fontweight','bold',...
             'fontsize',yr_fontsize,'color',plot_colors(i,:),...
             'horizontalalignment','center','FontName',fig_font)
        txt_y=txt_y-0.11;
        
    end
    
    
    axes(fig_ax(1))
    add_label('a)', 1)
    ylabel('O_3 column (DU)')
    grid on
    set(gca,'XTick',xlim_arr)
    set(gca,'XTickLabel',cellstr(ft_to_date(xlim_arr-1,0),'MMM dd'))
    ylim([150,600])
    xlim(x_lim)

    %plot 2020 ozonesondes
    axes(fig_ax(2))
    plot_o3sonde(2020,[50,150],3.5,1)
%     plot_o3sonde(2020,[50,150],1e30,0)
    add_label('b)', 1)
    grid on
    box on
    set(gca,'XTick',xlim_arr)
    set(gca,'XTickLabel',cellstr(ft_to_date(xlim_arr-1,0),'MMM dd'))
    xlabel('Date (EST)')
    xlim(x_lim)
    
    %%%
    set(findall(gcf,'-property','FontName'),'FontName',fig_font)
    save_pdf(save_figs, 'o3_all')

end


%%
if no2_all
    
    figure
    set(gcf, 'Position', [100, 100, 1000, 600]);
    fig_ax = tight_subplot(2,1,[0.07,0.07],[0.1,0.08],[0.08,0.13]);

    txt_y=0.97;
    
    % plot mean for diurnal differences?
    do_mean=1;
    
    % merge non-vortex year NO2 data
    data_in=struct();
    data_in.field1=gbs_no2;
    data_in.field2=saoz_no2;
    data_in.field3=bruker.no2;

    axes(fig_ax(1))
    
    plot(1,1,'ks'), hold on
    plot(1,1,'kd'), hold on
    plot(1,1,'kx'), hold on
    legend({'GBS','SAOZ','Bruker FTIR'},'orientation','vertical',...
        'FontName',fig_font,'Position',[0.887 0.26 0.094 0.12])
    
    plot_gray_area(data_in, 'tot_col_scaled', plot_gray, plot_gray+0.2, 1)
         
    % add explanatory text
    text(txt_x,0.87,sprintf('Outside the\nvortex:\n1999-2019'),...
         'units','normalized','fontweight','bold',...
         'fontsize',yr_fontsize,'color',plot_gray,'horizontalalignment','center',...
         'FontName',fig_font)

    text(txt_x,0.7,'2020',...
         'units','normalized','fontweight','bold',...
         'fontsize',yr_fontsize,'color',plot_gray-0.2,'horizontalalignment','center',...
         'FontName',fig_font)
     
    text(txt_x,0.53,sprintf('Inside the\nvortex:'),...
         'units','normalized','fontweight','bold',...
         'fontsize',yr_fontsize,'color',[.2 .2 .2],'horizontalalignment','center',...
         'FontName',fig_font)
     
    txt_y=0.38;
    
    % get diurnal differences (outside the vortex only)
    diff_gbs_out=get_no2_diff(gbs_no2(gbs_no2.in_edge_out>0,:),do_mean);
    diff_saoz=get_no2_diff(saoz_no2(saoz_no2.in_edge_out>0,:),do_mean);
        
    % add dummy columns for ploting function (keep ft in ~UTC, doy is recalculated from ft)
    diff_gbs_out.in_edge_out=ones(size(diff_gbs_out.diff));
    diff_gbs_out.fractional_time=diff_gbs_out.doy-(7/24);
    diff_saoz.in_edge_out=ones(size(diff_saoz.diff));
    diff_saoz.fractional_time=diff_saoz.doy-(7/24);
    
    data_in=struct();
    data_in.field1=diff_gbs_out;
    data_in.field2=diff_saoz;
    
    axes(fig_ax(2))
    plot_gray_area(data_in, 'diff', plot_gray, plot_gray+0.2, 0)

    % get diurnal differences (inside the vortex only)
    diff_gbs_in=get_no2_diff(gbs_no2(gbs_no2.in_edge_out<0,:),do_mean);
    diff_saoz=get_no2_diff(saoz_no2(saoz_no2.in_edge_out<0,:),do_mean);
    
    for i=1:length(highlight)

        yr=highlight(i);
        
        %%% NO2 plot
        axes(fig_ax(1))

        plot_yearly(yr,gbs_no2,'tot_col_scaled','s',plot_colors(i,:),'in')  
        plot_yearly(yr,saoz_no2,'tot_col_scaled','d',plot_colors(i,:),'in')  
        plot_yearly(yr,bruker.no2,'tot_col_scaled','x',plot_colors(i,:),'in')

        if yr==2020
           plot_yearly(yr,gbs_no2,'tot_col_scaled','s',plot_gray-0.2,'out')   
        end
        
        % print selected year on the side
        text(txt_x,txt_y,num2str(yr),'units','normalized','fontweight','bold',...
             'fontsize',yr_fontsize,'color',plot_colors(i,:),...
             'horizontalalignment','center','FontName',fig_font)
        txt_y=txt_y-0.11;
    
        axes(fig_ax(2))
        % adjust doy to matlab datenum for plotting on datetime axis!!
        ind=(diff_gbs_in.year==yr);
        plot(diff_gbs_in.doy(ind)+0.5,diff_gbs_in.diff(ind),...
            's-','color',plot_colors(i,:),...
            'linewidth',1.2,'markerfacecolor',plot_colors(i,:)), hold on
        
        ind=(diff_saoz.year==yr);
        plot(diff_saoz.doy(ind)+0.5,diff_saoz.diff(ind),...
            'd-','color',plot_colors(i,:),...
            'linewidth',1.2,'markerfacecolor',plot_colors(i,:)), hold on

        if yr==2020
            ind=(diff_gbs_out.year==yr);
            plot(diff_gbs_out.doy(ind)+0.5,diff_gbs_out.diff(ind),...
                's-','color',plot_gray-0.2,...
                'linewidth',1.2,'markerfacecolor',plot_gray-0.2), hold on
        end
    end

% % %     %%% plot years on the side
% % %     axes(fig_ax(1))
% % %     for yr=unique(gbs_no2.year)'
% % %         ind=find(highlight==yr);
% % %         if ~isempty(ind)
% % %             plot_c=plot_colors(ind,:);
% % %         else
% % %             plot_c=plot_gray;
% % %         end
% % %         text(1.05,txt_y,num2str(yr),'units','normalized','fontweight','bold',...
% % %              'fontsize',yr_fontsize,'color',plot_c)
% % %         txt_y=txt_y-0.11;
% % %     end
    
        
    axes(fig_ax(1))
    add_label('a)', 1)
    grid on
    set(gca,'XTick',xlim_arr)
    set(gca,'XTickLabel',cellstr(ft_to_date(xlim_arr-1,0),'MMM dd'))
    ylabel('NO_2 column (molec cm^{-2})')
    ylim([-0.2,5.6]*1e15)
    xlim(x_lim)
     
    axes(fig_ax(2))
    add_label('b)', 1)
    grid on
    set(gca,'XTick',xlim_arr)
    set(gca,'XTickLabel',cellstr(ft_to_date(xlim_arr-1,0),'MMM dd'))
    xlabel('Date (EST)')
    ylabel('\DeltaNO_2 (molec cm^{-2})')
    ylim([-2,10]*1e14)
    xlim(x_lim)

    %%%
    set(findall(gcf,'-property','FontName'),'FontName',fig_font)
    save_pdf(save_figs, 'no2_all')
    
end

%%
if other_all

    figure
    set(gcf, 'Position', [100, 100, 1000, 750]);
    fig_ax = tight_subplot(6,1,[0.01,0.07],[0.08,0.06],[0.1,0.13]);
        
    axes(fig_ax(1))
    plot(1,1,'ks'), hold on
    plot(1,1,'kx'), hold on
    plot(1,1,'pentagram','color','k'), hold on
    legend({'GBS','Bruker FTIR','Radiosonde'},'orientation','vertical',...
        'FontName',fig_font,'Position',[0.887 0.52 0.094 0.068])
    
    plot_gray_area(gbs_bro, 'dscd', plot_gray, plot_gray+0.2, 1)
    detlim=nanmean(sqrt(gbs_bro.dscd_err.^2 + gbs_bro.dscd_std.^2))*3;
    plot([52,108],[detlim,detlim],'k--')

    axes(fig_ax(2))
    plot_gray_area(gbs_oclo, 'dscd', plot_gray, plot_gray+0.2, 1)
    detlim=nanmean(sqrt(gbs_oclo.dscd_err.^2 + gbs_oclo.dscd_std.^2))*3;
    plot([52,108],[detlim,detlim],'k--')
    
    axes(fig_ax(3))
    plot_gray_area(bruker.hcl, 'tot_col', plot_gray, plot_gray+0.2, 1)

    axes(fig_ax(4))
    plot_gray_area(bruker.clono2, 'tot_col', plot_gray, plot_gray+0.2, 1)

    axes(fig_ax(5))
    plot_gray_area(bruker.hno3, 'tot_col', plot_gray, plot_gray+0.2, 1)
    
    % plot non-vortex temperatures
    data_in=struct();
    data_in.field1=gbs_o3;
    data_in.field3=bruker.o3;
    axes(fig_ax(6))
    plot_gray_area(data_in, 'T_1alt', plot_gray, plot_gray+0.2, 1)
        
    % add explanatory text
    axes(fig_ax(1))
    text(txt_x,0.7,sprintf('Outside the\nvortex:\n2007-2019'),...
         'units','normalized','fontweight','bold',...
         'fontsize',yr_fontsize,'color',plot_gray,'horizontalalignment','center',...
         'FontName',fig_font)

    text(txt_x,0.3,'2020',...
         'units','normalized','fontweight','bold',...
         'fontsize',yr_fontsize,'color',plot_gray-0.2,'horizontalalignment','center',...
         'FontName',fig_font)
     
    text(txt_x,-0.1,sprintf('Inside the\nvortex:'),...
         'units','normalized','fontweight','bold',...
         'fontsize',yr_fontsize,'color',[.2 .2 .2],'horizontalalignment','center',...
         'FontName',fig_font)
     
    txt_y=-0.4;
    
    for i=3:length(highlight)

        yr=highlight(i);
        
        %%% BrO plot
        axes(fig_ax(1))
        plot_yearly(yr,gbs_bro,'dscd','s',plot_colors(i,:),'in')  
        text(txt_x,txt_y,num2str(yr),'units','normalized','fontweight','bold',...
             'fontsize',yr_fontsize,'color',plot_colors(i,:),...
             'horizontalalignment','center','FontName',fig_font)
        txt_y=txt_y-0.22;
        
        %%% OClO plot
        axes(fig_ax(2))
        plot_yearly(yr,gbs_oclo,'dscd','s',plot_colors(i,:),'in')  
        
        %%% HCl plot
        axes(fig_ax(3))
        plot_yearly(yr,bruker.hcl,'tot_col','x',plot_colors(i,:),'in')  
                 
        %%% ClONO2 plot
        axes(fig_ax(4))
        plot_yearly(yr,bruker.clono2,'tot_col','x',plot_colors(i,:),'in')  
        
        %%% HNO3 plot
        axes(fig_ax(5))
        plot_yearly(yr,bruker.hno3,'tot_col','x',plot_colors(i,:),'in')  
        
        %%% temperature plot
        axes(fig_ax(6))
        
        % Plot with OClO DMPs here?
        plot_yearly(yr,gbs_o3,'T_1alt','s',plot_colors(i,:),'in')  
        plot_yearly(yr,bruker.o3,'T_1alt','x',plot_colors(i,:),'in')  
                
        if yr==2020
            plot_yearly(yr,gbs_o3,'T_1alt','s',plot_gray-0.2,'out')  
            
            plot_radiosonde(yr,T_alt,plot_colors(i,:))
            
        end
        
    end
    
    %%% BrO plot
    axes(fig_ax(1));
    ax=gca; ax.YAxis.Exponent = 0;    
    add_label('a) BrO dSCD', 3)
    ylabel('molec cm^{-2}')
    grid on
    set(gca,'XTick',xlim_arr)
    set(gca,'XTicklabel',[])
    ylim([-1.3,4]*1e14)
    xlim(x_lim)

    %%% OClO plot
    axes(fig_ax(2));
    ax=gca; ax.YAxis.Exponent = 0;    
    add_label('b) OClO dSCD', 3)
    ylabel('molec cm^{-2}')
    grid on
    set(gca,'XTick',xlim_arr)
    set(gca,'XTicklabel',[])
    ylim([-0.75,2]*1e14)
    xlim(x_lim)

    %%% HCl plot
    axes(fig_ax(3));
    ax=gca; ax.YAxis.Exponent = 0;    
    add_label('c) HCl', 5)
    ylabel('molec cm^{-2}')
    grid on
    set(gca,'XTick',xlim_arr)
    set(gca,'XTicklabel',[])
    ylim([1,8]*1e15)
    xlim(x_lim)

    %%% ClONO2 plot
    axes(fig_ax(4));
    ax=gca; ax.YAxis.Exponent = 0;    
    add_label('d) ClONO_2', 3)
    ylabel('molec cm^{-2}')
    grid on
    set(gca,'XTick',xlim_arr)
    set(gca,'XTicklabel',[])    
    ylim([0,5]*1e15)
    xlim(x_lim)

    %%% HNO3 plot
    axes(fig_ax(5));
    ax=gca; ax.YAxis.Exponent = 0;    
    add_label('e) HNO_3', 3)
    ylabel('molec cm^{-2}')
    grid on
    set(gca,'XTick',xlim_arr)
    set(gca,'XTicklabel',[])
    ylim([0.8,4.7]*1e16)
    xlim(x_lim)

    %%% Temperature plot
    axes(fig_ax(6))
    add_label(['f) T_{' num2str(T_alt) 'km}'], 5)
    ylabel('K')    
    xlabel('Date (EST)')
    grid on
    set(gca,'XTick',xlim_arr)
    set(gca,'XTickLabel',cellstr(ft_to_date(xlim_arr-1,0),'MMM dd'))    
    plot([1,200],[195,195],'k--')
    ylim([185,245])
    xlim(x_lim)
   
    %%%
    set(findall(gcf,'-property','FontName'),'FontName',fig_font)
    save_pdf(save_figs, 'other_all')
    
end


if other_hf
    
    figure
    set(gcf, 'Position', [100, 100, 1000, 750]);
    fig_ax = tight_subplot(6,1,[0.01,0.07],[0.08,0.06],[0.1,0.13]);
    
%     figure
%     set(gcf, 'Position', [100, 100, 1000, 650]);
%     fig_ax = tight_subplot(5,1,[0.012,0.07],[0.08,0.06],[0.1,0.13]);
        
    axes(fig_ax(1))
    plot_gray_area(bruker.hf, ['tot_col' corr_str], plot_gray, plot_gray+0.2, 1)

    axes(fig_ax(2))
    plot_gray_area(bruker.o3, ['tot_col_hf_scaled' corr_str], plot_gray, plot_gray+0.2, 1)

    axes(fig_ax(3))
    plot_gray_area(bruker.no2, ['tot_col_hf_scaled' corr_str], plot_gray, plot_gray+0.2, 1)

    axes(fig_ax(4))
    plot_gray_area(bruker.hcl, ['tot_col_hf_scaled' corr_str], plot_gray, plot_gray+0.2, 1)

    axes(fig_ax(5))
    plot_gray_area(bruker.clono2, ['tot_col_hf_scaled' corr_str], plot_gray, plot_gray+0.2, 1)
    
    axes(fig_ax(6))
    plot_gray_area(bruker.hno3, ['tot_col_hf_scaled' corr_str], plot_gray, plot_gray+0.2, 1)
    
    % add explanatory text
    axes(fig_ax(1))
    text(txt_x,0.7,sprintf('Outside the\nvortex:\n2007-2019'),...
         'units','normalized','fontweight','bold',...
         'fontsize',yr_fontsize,'color',plot_gray,'horizontalalignment','center',...
         'FontName',fig_font)

    text(txt_x,0.3,'2020',...
         'units','normalized','fontweight','bold',...
         'fontsize',yr_fontsize,'color',plot_gray-0.2,'horizontalalignment','center',...
         'FontName',fig_font)
     
    text(txt_x,-0.1,sprintf('Inside the\nvortex:'),...
         'units','normalized','fontweight','bold',...
         'fontsize',yr_fontsize,'color',[.2 .2 .2],'horizontalalignment','center',...
         'FontName',fig_font)
     
    txt_y=-0.4;
    
    for i=3:length(highlight)

        yr=highlight(i);
        
        axes(fig_ax(1))
        text(txt_x,txt_y,num2str(yr),'units','normalized','fontweight','bold',...
             'fontsize',yr_fontsize,'color',plot_colors(i,:),...
             'horizontalalignment','center','FontName',fig_font)
        txt_y=txt_y-0.22;
        
        %%% HF plot
        axes(fig_ax(1))
        
        plot_yearly(yr,bruker.hf,['tot_col' corr_str],'x',plot_colors(i,:),'in')  
        
        %%% O3 plot
        axes(fig_ax(2))

        plot_yearly(yr,bruker.o3,['tot_col_hf_scaled' corr_str],'x',plot_colors(i,:),'in')  

        %%% NO2 plot
        axes(fig_ax(3))

        plot_yearly(yr,bruker.no2,['tot_col_hf_scaled' corr_str],'x',plot_colors(i,:),'in')  

        %%% HCl plot
        axes(fig_ax(4))

        plot_yearly(yr,bruker.hcl,['tot_col_hf_scaled' corr_str],'x',plot_colors(i,:),'in')  
                 
        %%% ClONO2 plot
        axes(fig_ax(5))

        plot_yearly(yr,bruker.clono2,['tot_col_hf_scaled' corr_str],'x',plot_colors(i,:),'in')  
        
        %%% HNO3 plot
        axes(fig_ax(6))

        plot_yearly(yr,bruker.hno3,['tot_col_hf_scaled' corr_str],'x',plot_colors(i,:),'in')  
        
    end
    
    %%% HF plot
    axes(fig_ax(1));
    add_label('a) HF', 3)
    ylabel('molec cm^{-2}')
    grid on
    set(gca,'XTick',xlim_arr)
    set(gca,'XTicklabel',[])
    ylim([1.4,4.2]*1e15)
    xlim(x_lim)

    %%% O3 plot
    axes(fig_ax(2));
    ax=gca; ax.YAxis.Exponent = 0;    
    add_label('b) O3/HF', 5)
    ylabel('Ratio')
    grid on
    set(gca,'XTick',xlim_arr)
    set(gca,'XTicklabel',[])
    ylim([1500,8500])
    xlim(x_lim)

    %%% NO2 plot
    axes(fig_ax(3));
    ax=gca; ax.YAxis.Exponent = 0;    
    add_label('c) NO2/HF', 5)
    ylabel('Ratio')
    grid on
    set(gca,'XTick',xlim_arr)
    set(gca,'XTicklabel',[])
    ylim([-0.1,2.5])
    xlim(x_lim)

    %%% HCl plot
    axes(fig_ax(4));
    ax=gca; ax.YAxis.Exponent = 0;    
    add_label('d) HCl/HF', 5)
    ylabel('Ratio')
    grid on
    set(gca,'XTick',xlim_arr)
    set(gca,'XTicklabel',[])
    ylim([0,3.5])
    xlim(x_lim)

    %%% ClONO2 plot
    axes(fig_ax(5));
    ax=gca; ax.YAxis.Exponent = 0;    
    add_label('e) ClONO_2/HF', 3)
    ylabel('Ratio')
    grid on
    set(gca,'XTick',xlim_arr)
    set(gca,'XTicklabel',[])
    ylim([0.2,1.7])
    xlim(x_lim)
    
    %%% HNO3 plot
    axes(fig_ax(6));
    ax=gca; ax.YAxis.Exponent = 0;    
    add_label('f) HNO_3/HF', 5)
    ylabel('Ratio')
    grid on
    set(gca,'XTick',xlim_arr)
    set(gca,'XTickLabel',cellstr(ft_to_date(xlim_arr-1,0),'MMM dd'))    
    xlabel('Date (EST)')
    ylim([2.5,22])
    xlim(x_lim)

    %%%
    set(findall(gcf,'-property','FontName'),'FontName',fig_font)
    save_pdf(save_figs, ['other_hf' corr_str])
    
end

%%
if o3_loss
    
    figure
    set(gcf, 'Position', [100, 100, 1000, 600]);
    fig_ax = tight_subplot(3,1,[0.02,0.07],[0.1,0.08],[0.08,0.04]);

    % temporary table for plottong
    slimcat_tmp=slimcat;
    % to avoid year switch when converting to EST
    slimcat_tmp(slimcat_tmp.fractional_time<2,:)=[];
    % remove any in vortex profiles (when data is available)
    slimcat_tmp(slimcat_tmp.in_edge_out==-1,:)=[];
    
    % remove any years with the vortex above eureka (mostly no vertical DMP info)
    for yr=highlight
        slimcat_tmp(slimcat_tmp.year==yr,:)=[];
    end

    % redo vortex tag for plotting (assume all profs are outside the vortex)
    slimcat_tmp.in_edge_out=repmat(-99,height(slimcat_tmp),1);

    axes(fig_ax(1))
    plot(1,1,'.','color',plot_colors(highlight==2011,:),'markersize',12), hold on
    plot(1,1,'.','color',plot_colors(highlight==2020,:),'markersize',12)
    plot(1,1,'ks'), hold on
    plot(1,1,'kd'), hold on
    plot(1,1,'kx'), hold on
    plot(1,1,'k+'), hold on
    plot(1,1,'ko'), hold on
    plot(1,1,'k:','linewidth',2), hold on
    plot(1,1,'k-','linewidth',2), hold on
    ll=legend({'2011','2020','GBS','SAOZ','Bruker FTIR','Brewer #69','Pandora',...
               'SLIMCAT 2011','SLIMCAT 2020'},'orientation','horizontal',...
               'location','northeast','FontName',fig_font);
    ll.Position=[0.202 0.934 0.627 0.039];
           
    plot_gray_area(slimcat_tmp, 'o3_passive', plot_gray, plot_gray+0.2, 1, 'slimcat_all')
    
% % %     % add explanatory text
% % %     text(txt_x,0.8,sprintf('Outside the\nvortex:\n2000-2019'),...
% % %          'units','normalized','fontweight','bold',...
% % %          'fontsize',yr_fontsize,'color',plot_gray,'horizontalalignment','center',...
% % %          'FontName',fig_font)
% % % 
% % %     text(txt_x,0.4,sprintf('Inside the\nvortex:'),...
% % %          'units','normalized','fontweight','bold',...
% % %          'fontsize',yr_fontsize,'color',[.2 .2 .2],'horizontalalignment','center',...
% % %          'FontName',fig_font)
% % %          
% % %     txt_y=0.19;
    
    for yr=[2011,2020]
        
        vortex_pos='in';
        data_select='day';
        ls='-';
        
        if yr==2011
            slimcat_ls=':';
        elseif yr==2020
            slimcat_ls='-';
        end
        
        axes(fig_ax(1))
        
% % %         text(txt_x,txt_y,num2str(yr),'units','normalized','fontweight','bold',...
% % %              'fontsize',yr_fontsize,'color',plot_colors(highlight==yr,:),...
% % %              'horizontalalignment','center','FontName',fig_font)
% % %         txt_y=txt_y-0.15;

        ind=(slimcat.year==yr & slimcat.in_edge_out==-1);
        xx=mjd2k_to_date(slimcat.mjd2k-(5/24));
        xx.Year=0;

        plot(xx(ind),slimcat.o3_passive(ind),'.','color',plot_colors(highlight==yr,:),...
            'markersize',12)

        axes(fig_ax(2))
        plot_yearly_loss(yr,slimcat,'o3',slimcat_ls,'k','in','abs','all',2)  
        plot_yearly_loss(yr,gbs_o3,'tot_col',['s' ls],...
                         plot_colors(highlight==yr,:),vortex_pos,'abs',data_select,1.2)  
        plot_yearly_loss(yr,saoz_o3,'tot_col',['d' ls],...
                         plot_colors(highlight==yr,:),vortex_pos,'abs',data_select,1.2)  
        plot_yearly_loss(yr,bruker.o3,'tot_col',['x' ls],...
                         plot_colors(highlight==yr,:),vortex_pos,'abs',data_select,1.2)  
        plot_yearly_loss(yr,brewer,'tot_col',['+' ls],...
                         plot_colors(highlight==yr,:),vortex_pos,'abs',data_select,1.2)  

        if yr==2020
            plot_yearly_loss(yr,pandora,'tot_col',['o' ls],...
                         plot_colors(highlight==yr,:),vortex_pos,'abs',data_select,1.2)  
        end
        
        axes(fig_ax(3))
        plot_yearly_loss(yr,slimcat,'o3',slimcat_ls,'k','in','rel','all',2)  
        plot_yearly_loss(yr,gbs_o3,'tot_col',['s' ls],...
                         plot_colors(highlight==yr,:),vortex_pos,'rel',data_select,1.2)  
        plot_yearly_loss(yr,saoz_o3,'tot_col',['d' ls],...
                         plot_colors(highlight==yr,:),vortex_pos,'rel',data_select,1.2)  
        plot_yearly_loss(yr,bruker.o3,'tot_col',['x' ls],...
                         plot_colors(highlight==yr,:),vortex_pos,'rel',data_select,1.2)  
        plot_yearly_loss(yr,brewer,'tot_col',['+' ls],...
                         plot_colors(highlight==yr,:),vortex_pos,'rel',data_select,1.2)  
        if yr==2020
            plot_yearly_loss(yr,pandora,'tot_col',['o' ls],...
                         plot_colors(highlight==yr,:),vortex_pos,'rel',data_select,1.2)  
        end
                     
    end

    axes(fig_ax(1))    
    add_label('a) Passive O_3', 1.5)
    grid on
    xlim(x_lim)
    ylim([250,750])
    set(gca,'XTick',xlim_arr)
    set(gca,'XTicklabel',[])
    ylabel('DU')
    
    axes(fig_ax(2))    
    add_label('b) Abs. O_3 loss', 8)    
    grid on
    xlim(x_lim)
    ylim([-200,20])
    set(gca,'XTick',xlim_arr)
    set(gca,'XTicklabel',[])
    ylabel('DU')

    axes(fig_ax(3))    
    add_label('c) Rel. O_3 loss', 8)    
    grid on
    xlim(x_lim)
    ylim([-45,5])
    set(gca,'XTick',xlim_arr)
    set(gca,'XTickLabel',cellstr(ft_to_date(xlim_arr-1,0),'MMM dd'))
    ylabel('%') 
    xlabel('Date (EST)')

    %%%
    set(findall(gcf,'-property','FontName'),'FontName',fig_font)
    save_pdf(save_figs, 'o3_loss')
    
end

%%
if slimcat_o3
        
    for rel_abs_loop={'reldiff','absdiff'}
        
        rel_abs=rel_abs_loop{1};
        
        figure
        set(gcf, 'Position', [100, 100, 1000, 600]);
        fig_ax = tight_subplot(4,1,[0.012,0.07],[0.08,0.06],[0.1,0.13]);
        
        data_in=struct();
        data_in.field1=gbs_o3;
        data_in.field2=saoz_o3;
        data_in.field3=bruker.o3;
        data_in.field4=brewer;
        names=fieldnames(data_in);

        % label for mean differences on the side
        axes(fig_ax(1))
        plot(1,1), hold on
        if strcmp(rel_abs,'reldiff')
            unit_str='%%';
        elseif strcmp(rel_abs,'absdiff')
            unit_str='DU';
        end

        text(txt_x,0.9,sprintf(['mean \\pm \\sigma (' unit_str ')']),...
             'units','normalized','fontweight','bold',...
             'fontsize',yr_fontsize,'color','k','horizontalalignment','center',...
             'FontName',fig_font)

        % legend with correct facealpha
        axes(fig_ax(4))
        fill([1,2,2,1],[1,1,2,2],plot_gray,'LineStyle','none'), hold on
        fill([1,2,2,1],[1,1,2,2],[1 0 0],'LineStyle','none','FaceAlpha',0.75)
        [~,h2] = legend({'Outside the vortex','Inside the vortex'},'location','southwest',...
            'FontName',fig_font);
        PatchInLegend = findobj(h2, 'type', 'patch');
        set(PatchInLegend(2), 'FaceAlpha', 0.75);

        % plot each instrument
        for i=1:length(names)

            axes(fig_ax(i))
            
            % plot zero line
            plot(x_lim,zeros(size(x_lim)),'k--'), hold on
            
            % plot in/out of vortex diffs as area
            plot_gray_area(data_in.(names{i}), ['slimcat_' rel_abs], plot_gray, plot_gray+0.2, 1, 'slimcat_out')
            plot_gray_area(data_in.(names{i}), ['slimcat_' rel_abs], [1 0 0], plot_gray-0.2, 1, 'slimcat_in')

            % add mean +- std
            tmp=nanmean(data_in.(names{i}).(['slimcat_' rel_abs])(data_in.(names{i}).in_edge_out==1));
            tmp2=nanstd(data_in.(names{i}).(['slimcat_' rel_abs])(data_in.(names{i}).in_edge_out==1));
            text(txt_x,0.6,sprintf('%2.1f\\pm%2.1f',[tmp,tmp2]),...
                 'units','normalized','fontweight','bold',...
                 'fontsize',yr_fontsize,'color',plot_gray-0.2,'horizontalalignment','center',...
                 'FontName',fig_font)

            tmp=nanmean(data_in.(names{i}).(['slimcat_' rel_abs])(data_in.(names{i}).in_edge_out==-1));
            tmp2=nanstd(data_in.(names{i}).(['slimcat_' rel_abs])(data_in.(names{i}).in_edge_out==-1));
            text(txt_x,0.4,sprintf('%2.1f\\pm%2.1f',[tmp,tmp2]),...
                 'units','normalized','fontweight','bold',...
                 'fontsize',yr_fontsize,'color',[1 0 0],'horizontalalignment','center',...
                 'FontName',fig_font)

            grid on
            if strcmp(rel_abs,'reldiff')
                ylabel('\Delta_{rel} (%)')
                ylim([-25,36])
            elseif strcmp(rel_abs,'absdiff')
                ylabel('\Delta_{abs} (DU)')
                ylim([-120,120])
            end
            set(gca,'XTick',xlim_arr)
            set(gca,'XTickLabel',[])
            xlim(x_lim)
            

        end

        if strcmp(rel_abs,'reldiff')
            
            axes(fig_ax(1))    
            add_label('a) GBS',3)

            axes(fig_ax(2))    
            add_label('b) SAOZ',3)

            axes(fig_ax(3))    
            add_label('c) Bruker FTIR',3)

            axes(fig_ax(4))    
            add_label('d) Brewer #69',3)
            
            xlabel('Date (EST)')
            set(gca,'XTickLabel',cellstr(ft_to_date(xlim_arr-1,0),'MMM dd'))

            %%%
            set(findall(gcf,'-property','FontName'),'FontName',fig_font)
            save_pdf(save_figs, 'slimcat_o3_rel')

        elseif strcmp(rel_abs,'absdiff')
            
            axes(fig_ax(1))    
            add_label('a) GBS',3)
            
            axes(fig_ax(2))    
            add_label('b) SAOZ',3)

            axes(fig_ax(3))    
            add_label('c) Bruker FTIR',3)

            axes(fig_ax(4))    
            add_label('d) Brewer #69',3)
            
            xlabel('Date (EST)')
            set(gca,'XTickLabel',cellstr(ft_to_date(xlim_arr-1,0),'MMM dd'))

            %%%
            set(findall(gcf,'-property','FontName'),'FontName',fig_font)
            save_pdf(save_figs, 'slimcat_o3_abs')
            
        end
        
    end
    
end

%%
if slimcat_other
        
    for rel_abs_loop={'reldiff','absdiff'}
        
        rel_abs=rel_abs_loop{1};

        figure
        set(gcf, 'Position', [100, 100, 1000, 600]);
        if strcmp(rel_abs,'reldiff')
            fig_ax = tight_subplot(3,1,[0.012,0.07],[0.08,0.06],[0.1,0.13]);
        elseif strcmp(rel_abs,'absdiff')
            fig_ax = tight_subplot(3,1,[0.012,0.07],[0.08,0.06],[0.12,0.16]);
            txt_x=txt_x+0.03;
        end
        
        data_in=struct();
        data_in.field1=bruker.hcl;
        data_in.field2=bruker.clono2;
        data_in.field3=bruker.hno3;
        names=fieldnames(data_in);

        % label for mean differences on the side
        axes(fig_ax(1))
        plot(1,1), hold on
        if strcmp(rel_abs,'reldiff')
            text(txt_x,0.9,sprintf('mean \\pm \\sigma (%%)'),...
                 'units','normalized','fontweight','bold',...
                 'fontsize',yr_fontsize,'color','k','horizontalalignment','center',...
                 'FontName',fig_font)
            form_str='%2.1f\\pm%2.1f';
            legend_loc='northeast';
        elseif strcmp(rel_abs,'absdiff')
            text(txt_x,0.9,sprintf('mean \\pm \\sigma\n(molec cm^{-2})'),...
                 'units','normalized','fontweight','bold',...
                 'fontsize',yr_fontsize,'color','k','horizontalalignment','center',...
                 'FontName',fig_font)
            form_str='%0.2g\\pm%0.2g';
            legend_loc='southeast';
        end

        % legend with correct facealpha 
        axes(fig_ax(3))
        fill([1,2,2,1],[1,1,2,2],plot_gray,'LineStyle','none'), hold on
        fill([1,2,2,1],[1,1,2,2],[1 0 0],'LineStyle','none','FaceAlpha',0.75)
        [~,h2] = legend({'Outside the vortex','Inside the vortex'},'location',legend_loc,...
            'FontName',fig_font);
        PatchInLegend = findobj(h2, 'type', 'patch');
        set(PatchInLegend(2), 'FaceAlpha', 0.75);

        for i=1:length(names)

            % plot each trace gas
            axes(fig_ax(i))
            
            % plot zero line
            plot(x_lim,zeros(size(x_lim)),'k--'), hold on

            plot_gray_area(data_in.(names{i}), ['slimcat_' rel_abs], plot_gray, plot_gray+0.2, 1, 'slimcat_out')
            plot_gray_area(data_in.(names{i}), ['slimcat_' rel_abs], [1 0 0], plot_gray-0.2, 1, 'slimcat_in')

            % add mean +- std
            tmp=nanmean(data_in.(names{i}).(['slimcat_' rel_abs])(data_in.(names{i}).in_edge_out==1));
            tmp2=nanstd(data_in.(names{i}).(['slimcat_' rel_abs])(data_in.(names{i}).in_edge_out==1));
            text(txt_x,0.6,sprintf(form_str,[tmp,tmp2]),...
                 'units','normalized','fontweight','bold',...
                 'fontsize',yr_fontsize,'color',plot_gray-0.2,'horizontalalignment','center',...
                 'FontName',fig_font)

            tmp=nanmean(data_in.(names{i}).(['slimcat_' rel_abs])(data_in.(names{i}).in_edge_out==-1));
            tmp2=nanstd(data_in.(names{i}).(['slimcat_' rel_abs])(data_in.(names{i}).in_edge_out==-1));
            text(txt_x,0.4,sprintf(form_str,[tmp,tmp2]),...
                 'units','normalized','fontweight','bold',...
                 'fontsize',yr_fontsize,'color',[1 0 0],'horizontalalignment','center',...
                 'FontName',fig_font)

            grid on
            if strcmp(rel_abs,'reldiff')
                ylabel('\Delta_{rel} (%)')
            elseif strcmp(rel_abs,'absdiff')
                ylabel('\Delta_{abs} (molec cm^{-2})')
            end

            set(gca,'XTick',xlim_arr)
            set(gca,'XTickLabel',[])

            xlim(x_lim)
            
        end

        if strcmp(rel_abs,'reldiff')

            axes(fig_ax(1))         
            add_label('a) HCl',1)
            ylim([-27,23])

            axes(fig_ax(2))    
            add_label('b) ClONO_2',1)
            ylim([-65,135])

            axes(fig_ax(3))    
            add_label('c) HNO_3',1)
            ylim([-40,40])
            xlabel('Date (EST)')
            set(gca,'XTickLabel',cellstr(ft_to_date(xlim_arr-1,0),'MMM dd'))

            %%%
            set(findall(gcf,'-property','FontName'),'FontName',fig_font)
            save_pdf(save_figs, 'slimcat_other_rel')

        elseif strcmp(rel_abs,'absdiff')

            axes(fig_ax(1))
            ax=gca; ax.YAxis.Exponent = 0;        
            add_label('a) HCl',1)
            ylim([-1.15,0.5]*1e15)

            axes(fig_ax(2))    
            ax=gca; ax.YAxis.Exponent = 0;        
            add_label('b) ClONO_2',1)
            ylim([-1,1.7]*1e15)

            axes(fig_ax(3))    
            ax=gca; ax.YAxis.Exponent = 0;        
            add_label('c) HNO_3',1)
            ylim([-1.3,0.4]*1e16)

            xlabel('Date (EST)')
            set(gca,'XTickLabel',cellstr(ft_to_date(xlim_arr-1,0),'MMM dd'))

            %%%
            set(findall(gcf,'-property','FontName'),'FontName',fig_font)
            save_pdf(save_figs, 'slimcat_other_abs')

        end
    end
end


%%
if slimcat_vs_T

    rel_abs='absdiff';
    
    figure
    set(gcf, 'Position', [100, 100, 1000, 600]);
    if strcmp(rel_abs,'reldiff')    
        fig_ax = tight_subplot(2,2,[0.012,0.05],[0.1,0.06],[0.08,0.05]);
    elseif strcmp(rel_abs,'absdiff')    
        fig_ax = tight_subplot(2,2,[0.07,0.045],[0.1,0.06],[0.08,0.05]);
    end
    
    x_lim_tmp=[189,245];
    
    n=0;
    for i={'o3','hcl','clono2','hno3'}
        
        n=n+1;
        axes(fig_ax(n))
        if n==1 && strcmp(rel_abs,'absdiff')
            mult=2.687e16;
        else
            mult=1;
        end
        
        ind=(bruker.(i{1}).in_edge_out==1);
        plot(bruker.(i{1}).T_1alt(ind), bruker.(i{1}).(['slimcat_' rel_abs])(ind)*mult,'o',...
            'markerfacecolor', plot_gray-0.5,'markeredgecolor', plot_gray+0.2), hold on
        ind=(bruker.(i{1}).in_edge_out==-1);
        plot(bruker.(i{1}).T_1alt(ind), bruker.(i{1}).(['slimcat_' rel_abs])(ind)*mult,'o',...
            'markerfacecolor', plot_colors(highlight==2020,:),...
            'markeredgecolor', plot_gray+0.2), hold on

        grid on
        
        if n==1
            legend({'Outside the vortex','Inside the vortex'},'location','southeast',...
                'FontName',fig_font);
        end
%         if n==3
%             plot_fit_line(bruker.(i{1}).T_1alt(ind),...
%                 bruker.(i{1}).(['slimcat_' rel_abs])(ind)*mult,...
%                 plot_colors(highlight==2020,:));
%         end
        
    end    
    
    if strcmp(rel_abs,'reldiff')  
        
        axes(fig_ax(1))         
        add_label('a) O3',9)
        xlim(x_lim_tmp)
        ylim([-30,20])
        set(gca,'XTickLabel',[])
        ylabel('\Delta_{rel} (%)')

        axes(fig_ax(2))    
        add_label('b) HCl',9)
        xlim(x_lim_tmp)
        ylim([-30,25])
        set(gca,'XTickLabel',[])

        axes(fig_ax(3))    
        add_label('c) ClONO_2',9)
        xlim(x_lim_tmp)
        ylim([-40,220])
        xlabel(['T_{' num2str(T_alt) 'km} (K)'])
        ylabel('\Delta_{rel} (%)')

        axes(fig_ax(4))    
        add_label('d) HNO_3',9)
        xlim(x_lim_tmp)
        ylim([-50,45])
        xlabel(['T_{' num2str(T_alt) 'km} (K)'])
        
        %%%
        set(findall(gcf,'-property','FontName'),'FontName',fig_font)
        save_pdf(save_figs, 'slimcat_T_rel')
        
        
    elseif strcmp(rel_abs,'absdiff')  
        
        axes(fig_ax(1))         
        add_label('a) O3',9)
        xlim(x_lim_tmp)
        ylim([-3.6,2.2]*1e18)
        ylabel('\Delta_{abs} (molec cm^{-2})')

        axes(fig_ax(2))    
        add_label('b) HCl',9)
        xlim(x_lim_tmp)
        ylim([-1.2,0.8]*1e15)   

        axes(fig_ax(3))    
        add_label('c) ClONO_2',9)
        xlim(x_lim_tmp)
        ylim([-1.1,2]*1e15)
        
        xlabel(['T_{' num2str(T_alt) 'km} (K)'])
        ylabel('\Delta_{abs} (molec cm^{-2})')

        axes(fig_ax(4))    
        add_label('d) HNO_3',9)
        xlim(x_lim_tmp)
        ylim([-17,6]*1e15)
        xlabel(['T_{' num2str(T_alt) 'km} (K)'])
        
        %%%
        set(findall(gcf,'-property','FontName'),'FontName',fig_font)
        save_pdf(save_figs, 'slimcat_T_abs')
        
        
    end
    
end


%%
if hist_o3
    
    data=saoz_o3;

    bins=190:20:570;
    ft_lim=111;

    len_bins=length(bins);

    figure

    ind=(data.fractional_time<ft_lim & data.in_edge_out==1);
    bins_tmp=redo_bins(bins,min(data.tot_col(ind)),max(data.tot_col(ind)),length(bins));    
    
    histogram(data.tot_col(ind),bins_tmp,'normalization','probability',...
        'edgecolor',plot_gray-0.2,'facecolor',plot_gray), hold on

    text(0.8,0.9,sprintf('%3.0f\\pm%2.0f',[mean(data.tot_col(ind)),std(data.tot_col(ind))]),...
         'units','normalized','fontweight','bold',...
         'fontsize',yr_fontsize,'color',plot_gray,'horizontalalignment','left',...
         'FontName',fig_font)
   
    
    ind=(data.fractional_time<ft_lim & data.in_edge_out==-1 & data.year==2011);
    bins_tmp=redo_bins(bins,min(data.tot_col(ind)),max(data.tot_col(ind)),length(bins));    
    
    plot_c=plot_colors(highlight==2011,:);
    histogram(data.tot_col(ind),bins_tmp,'normalization','probability',...
        'facecolor','none','edgecolor',plot_c,...
        'linewidth',2), hold on

    text(0.8,0.8,sprintf('%3.0f\\pm%2.0f',[mean(data.tot_col(ind)),std(data.tot_col(ind))]),...
         'units','normalized','fontweight','bold',...
         'fontsize',yr_fontsize,'color',plot_c,'horizontalalignment','left',...
         'FontName',fig_font)
    
     
    ind=(data.fractional_time<ft_lim & data.in_edge_out==-1 & data.year==2020);
    bins_tmp=redo_bins(bins,min(data.tot_col(ind)),max(data.tot_col(ind)),length(bins));
    
    plot_c=plot_colors(highlight==2020,:);
    histogram(data.tot_col(ind),bins_tmp,'normalization','probability',...
        'facecolor','none','edgecolor',plot_c,...
        'linewidth',1.5), hold on

    text(0.8,0.7,sprintf('%3.0f\\pm%2.0f',[mean(data.tot_col(ind)),std(data.tot_col(ind))]),...
         'units','normalized','fontweight','bold',...
         'fontsize',yr_fontsize,'color',plot_c,'horizontalalignment','left',...
         'FontName',fig_font)
    
    xlim([bins(1),bins(end)])

end


%%
if tg_corr
    
    % o3 vs T: highlight years form decent correlation, but 2015 is an
    % outlier (strat very cold, but minimal ozone loss)
    
    % 3 subplots:
    % fig_ax = tight_subplot(1,3,[0.05,0.034],[0.15,0.12],[0.08,0.11]);
    % txt_y=1.08; txt_x=0.07;
    % +1.7;+0.55;+0.2;+0.2;
    % colorbar('west','position',[0.9 0.183 0.02 0.661],'YAxisLocation','right');

    lim_11=71.25;
    lim_20=66.25;
    plot_sym='o';
        
    figure
    set(gcf, 'Position', [100, 100, 1000, 350]);
    fig_ax = tight_subplot(1,3,[0.05,0.034],[0.15,0.12],[0.08,0.11]);
    
    % set color scale for 2020, based on GBS data
    ind=(gbs_o3.in_edge_out==-1 & gbs_o3.year==2020 & gbs_o3.fractional_time>lim_20);
    % number of unique days (local day number)
    tmp=unique(floor(gbs_o3.fractional_time(ind)+(18.2/24))); 
    all_days=[tmp(1):tmp(end)]';
    
%     cscale=colorGradient([1 0 0],[1 1 0], length(all_days));
    cscale=hot(length(all_days)+25);
    cscale=cscale(21:length(all_days)+20,:);

    for i=1:3
        
        if i==1, data=gbs_o3; end
        if i==2, data=saoz_o3; end
%         if i==3, data=bruker.o3; end
        if i==3, data=brewer; end
        
        axes(fig_ax(i))    
        
        ind=((data.in_edge_out==-1 & data.year==2000) | ...
             (data.in_edge_out==-1 & data.year==2005) | ...
             (data.in_edge_out==-1 & data.year==2007) | ...
             (data.in_edge_out==-1 & data.year==2014) | ...
             (data.in_edge_out==-1 & data.year==2011 & data.fractional_time<=lim_11) | ...
             (data.in_edge_out==-1 & data.year==2020 & data.fractional_time<=lim_20));

        R2=plot_fit_line(data.T_1alt(ind),data.tot_col(ind),plot_gray-0.4);
        plot(data.T_1alt(ind),data.tot_col(ind), plot_sym,...
            'markerfacecolor', plot_gray-0.5,'markeredgecolor', plot_gray+0.2)
        
        text(0.7,0.1,sprintf('{\\itR^2}=%1.2f',sqrt(R2)),...
             'units','normalized','fontweight','bold',...
             'fontsize',yr_fontsize,'color',plot_gray-0.4,'horizontalalignment','left',...
             'FontName',fig_font)

         
        ind=(data.in_edge_out==-1 & data.year==2015);
        plot(data.T_1alt(ind),data.tot_col(ind), plot_sym,...
            'markerfacecolor', plot_gray-0.1,'markeredgecolor', plot_gray+0.2)
        

        ind=(data.in_edge_out==-1 & data.year==2011 & data.fractional_time>lim_11);
        plot(data.T_1alt(ind),data.tot_col(ind), plot_sym, ...
            'markerfacecolor', plot_colors(highlight==2011,:),...
            'markeredgecolor', plot_gray+0.2)

        
%         ind=(data.in_edge_out==-1 & data.year==2020 & data.fractional_time>92.25);
%         plot_fit_line(data.T_1alt(ind),data.tot_col(ind),plot_colors(highlight==2020,:));
        
        ind=(data.in_edge_out==-1 & data.year==2020 & data.fractional_time>lim_20);
        
        % get color scale based on available days
        tmp=floor(data.fractional_time(ind)+(18.2/24));
        [~,~,c_ind]=intersect_repeat(tmp,all_days);
        
        scatter(data.T_1alt(ind),data.tot_col(ind),36, ...
            cscale(c_ind,:),'filled',...
            'markeredgecolor', plot_gray+0.2)
        
        if i==1
            colormap(cscale)
            cc=colorbar('west','position',[0.9 0.183 0.02 0.661],...
               'YAxisLocation','right');

            c_label_ind=[1,9,26,40,55];
            set(cc,'YTick',(c_label_ind-1)/55)
            set(cc,'YTickLabel',cellstr(ft_to_date(all_days(c_label_ind)-0.5,2020),'dd/MM'))
            ylabel(cc, 'Date, 2020 (dd/mm, EST)')
            
        end
        
        grid on
        xlabel(['T_{' num2str(T_alt) 'km} (K)'])
        ylim([178,530])
        xlim([188,230])
        

    end
    
    axes(fig_ax(1))
    add_label('a) GBS',9)
    txt_y=1.08;
    txt_x=0.07;
    
    text(txt_x,txt_y,sprintf('Inside the vortex: 2000,  2005,  2007,  \\leq12 March 2011,'),...
         'units','normalized','fontweight','bold',...
         'fontsize',yr_fontsize,'color',plot_gray-0.4,'horizontalalignment','left',...
         'FontName',fig_font)

    txt_x=txt_x+1.7;
    text(txt_x,txt_y,sprintf('\\geq13 March 2011,'),...
         'units','normalized','fontweight','bold',...
         'fontsize',yr_fontsize,'color',plot_colors(highlight==2011,:),...
         'horizontalalignment','left','FontName',fig_font)

    txt_x=txt_x+0.55;
    text(txt_x,txt_y,sprintf('2014,'),...
         'units','normalized','fontweight','bold',...
         'fontsize',yr_fontsize,'color',plot_gray-0.4,'horizontalalignment','left',...
         'FontName',fig_font)

    txt_x=txt_x+0.2;
    text(txt_x,txt_y,sprintf('2015,'),...
         'units','normalized','fontweight','bold',...
         'fontsize',yr_fontsize,'color',plot_gray-0.1,'horizontalalignment','left',...
         'FontName',fig_font)

    txt_x=txt_x+0.2;
    text(txt_x,txt_y,sprintf('\\leq6 March 2020'),...
         'units','normalized','fontweight','bold',...
         'fontsize',yr_fontsize,'color',plot_gray-0.4,'horizontalalignment','left',...
         'FontName',fig_font)
          
    ylabel('O_3 (DU)')
    

    axes(fig_ax(2))
    add_label('b) SAOZ',9)

    axes(fig_ax(3))
    add_label('c) Bruker FTIR',9)

    %%%
    set(findall(gcf,'-property','FontName'),'FontName',fig_font)
    save_pdf(save_figs, 'o3_T_corr')
    
end


%%
if tg_corr_all
    
    % o3 vs T: highlight years form decent correlation, but 2015 is an
    % outlier (strat very cold, but minimal ozone loss)

    lim_11=71.25; % still mostly dynamics
    lim_20=66.25; % still mostly dynamics
    lim_20_2=91.25; % again mostly dyamics
    plot_sym='o';
        
    figure
    set(gcf, 'Position', [100, 100, 1000, 520]);
    fig_ax = tight_subplot(2,2,[0.055,0.045],[0.12,0.05],[0.12,0.25]);
    
    % set color scale for 2020, based on GBS data
    ind=(gbs_o3.in_edge_out==-1 & gbs_o3.year==2020 & gbs_o3.fractional_time>lim_20);
    % number of unique days (local day number)
    tmp=unique(floor(gbs_o3.fractional_time(ind)+(18.2/24))); 
    all_days=[tmp(1):tmp(end)]';
    
%     cscale=flipud(jet(length(all_days)+45));
%     cscale=cscale(5:length(all_days)+4,:);
    cscale=hot(length(all_days)+25);
    cscale=cscale(21:length(all_days)+20,:);
    
%     apr1=find(all_days==92);
%     cscale=[cscale(1:apr1-1,:);flipud(cscale(apr1:end,:))];

    for i=1:4
        
        if i==1, data=gbs_o3; end
        if i==2, data=saoz_o3; end
        if i==3, data=bruker.o3; end
        if i==4, data=brewer; end
        
        axes(fig_ax(i))    
        
        % all 'normal' years
        ind=((data.in_edge_out==-1 & data.year==2000) | ...
             (data.in_edge_out==-1 & data.year==2005) | ...
             (data.in_edge_out==-1 & data.year==2007) | ...
             (data.in_edge_out==-1 & data.year==2014) | ...
             (data.in_edge_out==-1 & data.year==2011 & data.fractional_time<=lim_11) | ...
             (data.in_edge_out==-1 & data.year==2020 & data.fractional_time<=lim_20));

        R2=plot_fit_line(data.T_1alt(ind),data.tot_col(ind),plot_gray-0.4);
        
        plot(data.T_1alt(ind),data.tot_col(ind), plot_sym,...
            'markerfacecolor', plot_gray-0.5,'markeredgecolor', plot_gray+0.2)
        
        text(0.77,0.2,sprintf('{\\itR^2}=%1.2f',sqrt(R2)),...
             'units','normalized','fontweight','bold',...
             'fontsize',yr_fontsize,'color',plot_gray-0.4,'horizontalalignment','left',...
             'FontName',fig_font)

         
        % 2015
        ind=(data.in_edge_out==-1 & data.year==2015);
        if i==1, ind=(data.in_edge_out==-1 & data.year==2015 & data.T_1alt<220); end
        
        if i~=4
            R2=plot_fit_line(data.T_1alt(ind),data.tot_col(ind),plot_gray);
            text(0.77,0.3,sprintf('{\\itR^2}=%1.2f',sqrt(R2)),...
                 'units','normalized','fontweight','bold',...
                 'fontsize',yr_fontsize,'color',plot_gray,'horizontalalignment','left',...
                 'FontName',fig_font)
        end
        
        plot(data.T_1alt(ind),data.tot_col(ind), plot_sym,...
            'markerfacecolor', plot_gray-0.1,'markeredgecolor', plot_gray+0.2)
        

        % 2011
        ind=(data.in_edge_out==-1 & data.year==2011 & data.fractional_time>lim_11);
        plot(data.T_1alt(ind),data.tot_col(ind), plot_sym, ...
            'markerfacecolor', plot_colors(highlight==2011,:),...
            'markeredgecolor', plot_gray+0.2)

        % 2020
% %         ind=(data.in_edge_out==-1 & data.year==2020 & data.fractional_time<82.25 & ...
% %             data.fractional_time>lim_20); %>1 april
% %         R2=plot_fit_line(data.T_1alt(ind),data.tot_col(ind),plot_colors(highlight==2020,:));
% %         text(0.77,0.3,sprintf('{\\itR^2}=%1.2f',sqrt(R2)),...
% %              'units','normalized','fontweight','bold',...
% %              'fontsize',yr_fontsize,'color',plot_colors(highlight==2020,:),...
% %              'horizontalalignment','left','FontName',fig_font)
        
        if i==1 || i==4
            ind=(data.in_edge_out==-1 & data.year==2020 & data.fractional_time>lim_20_2); %>1 april
            R2=plot_fit_line(data.T_1alt(ind),data.tot_col(ind),plot_colors(highlight==2020,:));
            text(0.77,0.1,sprintf('{\\itR^2}=%1.2f',sqrt(R2)),...
                 'units','normalized','fontweight','bold',...
                 'fontsize',yr_fontsize,'color',plot_colors(highlight==2020,:),...
                 'horizontalalignment','left','FontName',fig_font)
        end
        
        ind=(data.in_edge_out==-1 & data.year==2020 & data.fractional_time>lim_20 & ...
             data.fractional_time<lim_20_2);
        
        % get color scale based on available days
        tmp=floor(data.fractional_time(ind)+(18.2/24));
        [~,~,c_ind]=intersect_repeat(tmp,all_days);
        
        scatter(data.T_1alt(ind),data.tot_col(ind),40, ...
            cscale(c_ind,:),'filled','marker','s',...
            'markeredgecolor', plot_gray+0.1)
         
        ind=(data.in_edge_out==-1 & data.year==2020 & data.fractional_time>lim_20_2);
        
        % get color scale based on available days
        tmp=floor(data.fractional_time(ind)+(18.2/24));
        [~,~,c_ind]=intersect_repeat(tmp,all_days);
        
        scatter(data.T_1alt(ind),data.tot_col(ind),36, ...
            cscale(c_ind,:),'filled',...
            'markeredgecolor', plot_gray+0.1)
        
        if i==1
            colormap(cscale)
            cc=colorbar('west','position',[0.84 0.13 0.024 0.35],...
               'YAxisLocation','right');

            c_label_ind=[1,9,26,40,55];
            set(cc,'YTick',(c_label_ind-1)/55)
            set(cc,'YTickLabel',cellstr(ft_to_date(all_days(c_label_ind)-0.5,2020),'dd/MM'))
            ylabel(cc, 'Date, 2020 (dd/mm, EST)')
            
        end
        
        grid on
        if i>2, xlabel(['T_{' num2str(T_alt) 'km} (K)']); end
        ylim([178,530])
        xlim([188,230])
        

    end
    
    axes(fig_ax(1))
    add_label('a) GBS',9)
    ylabel('O_3 (DU)')

    axes(fig_ax(2))
    add_label('b) SAOZ',9)
    
    txt_y=0.95;
    txt_x=1.4;
    y_spacing=0.12;
    
    text(txt_x,txt_y,sprintf('Inside the vortex:'),...
         'units','normalized','fontweight','bold',...
         'fontsize',yr_fontsize,'color',plot_gray-0.4,'horizontalalignment','center',...
         'FontName',fig_font)
    txt_y=txt_y-y_spacing;
     
    text(txt_x,txt_y,sprintf('2000'),...
         'units','normalized','fontweight','bold',...
         'fontsize',yr_fontsize,'color',plot_gray-0.4,'horizontalalignment','center',...
         'FontName',fig_font)
    txt_y=txt_y-y_spacing;

    text(txt_x,txt_y,sprintf('2005'),...
         'units','normalized','fontweight','bold',...
         'fontsize',yr_fontsize,'color',plot_gray-0.4,'horizontalalignment','center',...
         'FontName',fig_font)
    txt_y=txt_y-y_spacing;
    
    text(txt_x,txt_y,sprintf('2007'),...
         'units','normalized','fontweight','bold',...
         'fontsize',yr_fontsize,'color',plot_gray-0.4,'horizontalalignment','center',...
         'FontName',fig_font)
    txt_y=txt_y-y_spacing;
    
    text(txt_x,txt_y,sprintf('\\leq12 March 2011'),...
         'units','normalized','fontweight','bold',...
         'fontsize',yr_fontsize,'color',plot_gray-0.4,'horizontalalignment','center',...
         'FontName',fig_font)
    txt_y=txt_y-y_spacing;
    
    text(txt_x,txt_y,sprintf('\\geq13 March 2011'),...
         'units','normalized','fontweight','bold',...
         'fontsize',yr_fontsize,'color',plot_colors(highlight==2011,:),'horizontalalignment','center',...
         'FontName',fig_font)
    txt_y=txt_y-y_spacing;
    
    text(txt_x,txt_y,sprintf('2014'),...
         'units','normalized','fontweight','bold',...
         'fontsize',yr_fontsize,'color',plot_gray-0.4,'horizontalalignment','center',...
         'FontName',fig_font)
    txt_y=txt_y-y_spacing;

    text(txt_x,txt_y,sprintf('2015'),...
         'units','normalized','fontweight','bold',...
         'fontsize',yr_fontsize,'color',plot_gray-0.1,'horizontalalignment','center',...
         'FontName',fig_font)
    txt_y=txt_y-y_spacing;
    
    text(txt_x,txt_y,sprintf('\\leq6 March 2020'),...
         'units','normalized','fontweight','bold',...
         'fontsize',yr_fontsize,'color',plot_gray-0.4,'horizontalalignment','center',...
         'FontName',fig_font)


    axes(fig_ax(3))
    add_label('c) Bruker FTIR',9)
    ylabel('O_3 (DU)')
    
    axes(fig_ax(4))
    add_label('d) Brewer #69',9)
    
    
        
    %%%
    set(findall(gcf,'-property','FontName'),'FontName',fig_font)
    save_pdf(save_figs, 'o3_T_corr')
    
end

end

%%
function plot_yearly(yr,data,colname,sym,plot_c,vortex)
    
    if nargin==5
        ind=data.year==yr;
    elseif strcmp(vortex,'in')
        ind=(data.year==yr & data.in_edge_out<0);
    elseif strcmp(vortex,'out')
        ind=(data.year==yr & data.in_edge_out>0);
    elseif strcmp(vortex,'out+edge')
        ind=(data.year==yr & data.in_edge_out>=0);
    end
    
    % date, in EST
    xx=mjd2k_to_date(data.mjd2k-(5/24));
    xx.Year=0;

    if strcmp(sym,'.')
        msize=10;
    else
        msize=6;
    end
    
    plot(xx(ind),data.(colname)(ind),sym,'color',plot_c,'linewidth',1.2,...
         'markersize',msize), hold on
    

end

%%
function plot_yearly_loss(yr,data,colname,sym,plot_c,vortex,rel_abs,data_select,linew)
    
    if strcmp(vortex,'all')
        ind=data.year==yr;
    elseif strcmp(vortex,'in')
        if (~isempty(strfind(sym,'-')) || strcmp(sym,':')) && strcmp(data_select,'all')
            data.([colname '_passive'])(data.in_edge_out>=0)=NaN;
            ind=data.year==yr;
        else
            ind=(data.year==yr & data.in_edge_out<0 & data.in_edge_out_slimcat==-1);
        end
    elseif strcmp(vortex,'out')
        ind=(data.year==yr & data.in_edge_out>0);
    elseif strcmp(vortex,'out+edge')
        ind=(data.year==yr & data.in_edge_out>=0);
    end

    if isempty(ind), return, end
    
    xx=data.mjd2k(ind);
    
    if strcmp(rel_abs,'abs')
        o3_loss=-1*(data.([colname '_passive'])(ind)-data.(colname)(ind));
    elseif strcmp(rel_abs,'rel')
        o3_loss=(-1*(data.([colname '_passive'])(ind)-data.(colname)(ind))./...
                 data.([colname '_passive'])(ind))*100;
    end
    
    if strcmp(data_select,'day')

        tmp_in=array2table([data.fractional_time(ind),o3_loss],'VariableNames',...
               {'fractional_time','col'});
        dmean=get_daily_stats(tmp_in,'col',1,1);
        
        xx=ft_to_date(dmean.doy-0.5,yr);
        plot_var=dmean.mean;

    elseif strcmp(data_select,'week')

        doy=floor(data.fractional_time(ind)+(18.2/24)); 
        tmp_in=array2table([repmat(yr,size(doy)),doy,o3_loss],'VariableNames',...
               {'year','doy','col'});
        wmean=get_weekly_stats(tmp_in,'col');
        
        xx=ft_to_date(wmean.doy-0.5,yr);
        plot_var=wmean.col;
        
    elseif strcmp(data_select,'all')
        
        xx=mjd2k_to_date(xx);
        plot_var=o3_loss;
        
    end
    
    xx.Year=0;
    plot(xx,plot_var,sym,'color',plot_c,'linewidth',linew), hold on
%     plot(xx,plot_var,sym,'color',plot_c,'linewidth',1.2,'markerfacecolor',plot_c), hold on
    
end

%%
function plot_yearly_means(yr,data,colname,sym,plot_c,vortex,data_select)
    
    if strcmp(vortex,'all')
        ind=data.year==yr;
    elseif strcmp(vortex,'in')
        ind=(data.year==yr & data.in_edge_out<0);
    elseif strcmp(vortex,'out')
        ind=(data.year==yr & data.in_edge_out>0);
    elseif strcmp(vortex,'out+edge')
        ind=(data.year==yr & data.in_edge_out>=0);
    end

    if isempty(ind), return, end
            
    if strcmp(data_select,'day')

        dmean=get_daily_stats(data(ind,{'fractional_time',colname}),colname,1,1);
        
        xx=ft_to_date(dmean.doy-0.5,yr);
        plot_var=dmean.mean;

    elseif strcmp(data_select,'week')

        doy=floor(data.fractional_time(ind)+(18.2/24)); 
        tmp_in=array2table([repmat(yr,size(doy)),doy,data.(colname)(ind)],...
               'VariableNames',{'year','doy','col'});
        wmean=get_weekly_stats(tmp_in,'col');
        
        xx=ft_to_date(wmean.doy-0.5,yr);
        plot_var=wmean.col;
        
    elseif strcmp(data_select,'all')
        
        xx=mjd2k_to_date(data.mjd2k(ind));
        plot_var=data.(colname)(ind);
        
    end
    
    xx.Year=0;
    plot(xx,plot_var,sym,'color',plot_c,'linewidth',1.2), hold on
    
end

%%
function plot_gray_area(data_in, colname, area_c, line_c, show_gaps, data_select)

    %%% Excludes 2020 by default
    if nargin==5
        vortex_pos=1;
        yr_min=1999;
        yr_max=2019;
        add_single=0;
        fill_alpha=1;
        plot_minmax=1;
    elseif strcmp(data_select,'slimcat_out')
        vortex_pos=1;
        yr_min=2000;
        yr_max=2020;
        add_single=1;
        fill_alpha=1;
        plot_minmax=0;
    elseif strcmp(data_select,'slimcat_in')
        vortex_pos=-1;
        yr_min=2000;
        yr_max=2020;
        add_single=1;
        fill_alpha=0.75;
        plot_minmax=0;
    elseif strcmp(data_select,'slimcat_all')
        vortex_pos=-99;
        yr_min=2000;
        yr_max=2019;
        add_single=1;
        fill_alpha=1;
        plot_minmax=1;
    end

    data=[];
    
    %% create new data array
    if isstruct(data_in) % structure input: merge all fields, then filter
        
        for n=fieldnames(data_in)'
            
            ind=(data_in.(n{1}).in_edge_out==vortex_pos & ...
                 data_in.(n{1}).year>=yr_min & ...
                 data_in.(n{1}).year<=yr_max);
                                                    
            data=[data; [data_in.(n{1}).fractional_time(ind), ...
                         data_in.(n{1}).(colname)(ind)]];
        end
        
        data=array2table(data,'variablenames',{'fractional_time','col'}); 

    else % table input: filter
        
        data=data_in((data_in.in_edge_out==vortex_pos & ...
                      data_in.year>=yr_min & ...
                      data_in.year<=yr_max),...
                     {'fractional_time',colname});
        data.Properties.VariableNames={'fractional_time','col'};
        
    end

    %% calculate daily stats
    
    dmean=get_daily_stats(data,'col',show_gaps,add_single);
    
    % matlab datenum is 1 on jan 1, 00:00, use doy directly
    xx=dmean.doy+0.5;


    %% plot gray area
    % need loop to skip NaN days since fill cannot handle NaNs

    inds=[]; % to store indices to plot
    prev_good=0; % indicator if previous value was good (for multiple NaNs in a row)

    for i=1:length(xx)

        if ~isnan(dmean.mean(i)) % good value, save index for later

            inds=[inds,i];
            prev_good=1;

        elseif prev_good % NaN, but previous value was valid: plot area

            % double check that at least one std is non-zero (otherwise
            % fill just colors in the minimum convex area)
            if any(dmean.std(inds)>0)
                fill([xx(inds);flipud(xx(inds))],...
                      [dmean.mean(inds)+dmean.std(inds);...
                       flipud(dmean.mean(inds)-dmean.std(inds))],...
                     area_c,'LineStyle','none','FaceAlpha',fill_alpha), hold on
            end
            
            prev_good=0; % don't plot on next NaN
            inds=[]; % reset plotting index

        end
        
        if  i==length(xx) % last datapoint, plot area
            
            if any(dmean.std(inds)>0)
                fill([xx(inds);flipud(xx(inds))],...
                      [dmean.mean(inds)+dmean.std(inds);...
                       flipud(dmean.mean(inds)-dmean.std(inds))],...
                     area_c,'LineStyle','none'), hold on
            end
        end

    end
            
    % plot mean and min/max (NaNs handled automatically)
    plot(xx,dmean.mean,'-', 'color', line_c, 'linewidth', 2), hold on
    if plot_minmax
        plot(xx,dmean.max,'--', 'color', area_c), hold on
        plot(xx,dmean.min,'--', 'color', area_c), hold on
    end

end


%%
function table_out=get_no2_diff(no2_in, do_mean)

    % setup
    diff_out=[];
    i=1;
    do_loop=true;
    
    %% diurnal difference, when both twilights are available
    while do_loop

        % year, day, ampm values of current and next row
        tmp=[no2_in.year(i:i+1), no2_in.day(i:i+1), no2_in.ampm(i:i+1)];
        
        % compare rows: only ampm is different if same day
        if isequal(diff(tmp),[0,0,1])
        
            % save year, day, and pm minus am difference
            diff_out=[diff_out; [no2_in.year(i),...
                                 no2_in.day(i),...
                                 no2_in.tot_col(i+1) - no2_in.tot_col(i)]];
            
            % advance index by 2 (skip pm of same day)
            i=i+2;
            
        else % not the same day, move to next line
            i=i+1;
        end
        
        % end loop if at the end of the table
        if i>=size(no2_in,1), do_loop=false; end
            
    end    
    
    % convert to table
    diff_out=array2table(diff_out,'variablenames',{'year','doy','diff'}); 
    
    %% do multi-day mean of differences, if required    
    if do_mean

        table_out=get_weekly_stats(diff_out,'diff');
    
    else % output diurnal differences
        
        table_out=diff_out;
        
    end

end

%%
function plot_o3sonde(yr,ft_lim,max_val,is_vmr)
    % plot ozonesonde colorplot

    load(['/home/kristof/work/ozonesonde/Eureka/o3sonde_' num2str(yr) '.mat'])

    ll=length(f_list);

    hw=11/24; % half width of single sonde plot in time (to allow use of surf)

    alt_lim=[12,23]*1000; % altitude limit in m

    % loop over all sonde data
    for i=1:ll

        % load altitude grid and ozone vmr
        o3=sonde_data.(f_list{i})(:,2);
        alt=sonde_data.(f_list{i})(:,1);

        if max(alt)<18100, continue, end
        
        % get list of launch times in fractional date, convert to EST
        [ft,~]=fracdate([launchtime{i,1} ' ' launchtime{i,2}],'yyyy-mm-dd HH:MM:SS');
        ft=ft-(5/24);
        if (ft<ft_lim(1) || ft>ft_lim(2)), continue, end

        % create arrays to allow color plot, and implement altitude limit
        % adjust to matlab datenum for plotting on datetime axis!!
        ft=[ft-hw:hw:ft+hw]+1;

        alt_inds=alt<alt_lim(2) & alt>alt_lim(1);
        o3=o3(alt_inds)*1e6; % convert to ppb
        alt=alt(alt_inds)./1000; % convert to km
            
        if isempty(o3)
            continue
        else
            if ~is_vmr % concentration plot
                
                % calculate air number density, convert to molec/cm^3
                P=sonde_data.(f_list{i})(:,3); % P in file is Pa
                T=sonde_data.(f_list{i})(:,4)+273.15; % T in file is celsius, need K!
                num_dens=((6.022e23*P)./(8.314*T))*1e-6;
                % calculate ozone concentrations
                o3=o3.*num_dens(alt_inds)*1e-6;
                % scale for plotting
                o3=o3*1e-12;
                
            else % VMR plot
            
                o3=[0;o3];
                alt=[0;alt];
            
            end
            
            % crude plotting limit
            o3(o3>max_val)=max_val;

        end
                
        o3=[o3,o3,o3];
        alt=[alt,alt,alt];

        % color plot
        surf(ft,alt,o3,'EdgeColor','None', 'facecolor', 'interp'), hold on

    end
    
    c=colorbar('location','east','position',[0.83 0.133 0.025 0.31],...
               'YAxisLocation','left');

    if is_vmr
        set(c,'YTick',[0:0.5:max_val])
        ylabel(c, 'O_3 VMR (ppmv)')
        tmp=parula((max_val/0.5)+1);
        colormap(tmp(1:end-1,:))
    else
        ylabel(c, 'O_3 conc. (\times10^{12} molec cm^{-3})')
        colormap(parula(300))
    end

    view(2)
    ylabel('Altitude (km)')
    
    ylim(alt_lim/1000)        
        

end

%%
function plot_radiosonde(yr,alt_out, plot_c)

    % reformat sonde data
    load(['/home/kristof/work/radiosonde/Eureka/radiosonde_' num2str(yr) '.mat']);
    ft_sonde=[];
    T_sonde=[];
    for jj=1:length(f_list)
        alt=ptu_data.(['ptu_' f_list{jj}])(:,1)/1000;
        [~,ind,~]=unique(alt);
        if max(alt)>alt_out
            ft_sonde=[ft_sonde, fracdate(f_list{jj},'yymmddhh')];
            T_sonde=[T_sonde, interp1(alt(ind),...
                ptu_data.(['ptu_' f_list{jj}])(ind,3)+273.15,alt_out)];
        end
    end
    
    % get DMPs
    [spv,temperature,theta,lat,lon]=match_DMP_all(ft_sonde,yr,'VERTICAL_EWS',alt_out);

    % plot in vortex only (adjust ft to matlab datenum for plotting on
    % datetime axis!!)
    ind=spv>1.6e-4;
    plot(ft_sonde(ind)+1,T_sonde(ind),'pentagram','color',plot_c)

end

%%
function add_label(label_str, pos)

    global yr_fontsize

    align='left';
    if pos==1
        pos_x=0.03;
        pos_y=0.9;
    elseif pos==1.5
        pos_x=0.03;
        pos_y=0.83;
    elseif pos==2
        pos_x=0.03;
        pos_y=0.83;
    elseif pos==3
        pos_x=0.85;
        pos_y=0.83;
    elseif pos==5
        pos_x=0.85;
        pos_y=0.3;
    elseif pos==8
        pos_x=0.03;
        pos_y=0.17;
    elseif pos==9
        pos_x=0.07;
        pos_y=0.93;
    end
    
    text(pos_x,pos_y,label_str,'units','normalized','fontweight','bold',...
         'fontsize',yr_fontsize,'color','k','horizontalalignment',align)


end

%%
function save_pdf(save_figs, fname)

    save_path='/home/kristof/work/documents/paper_PEARL_ozone/figures/';

    if save_figs
        
        h=gcf;

        set(h,'Units','Inches');

        pos = get(h,'Position');

        set(h,'PaperPositionMode','Auto','PaperUnits','Inches',...
              'PaperSize',[pos(3), pos(4)])

        if save_figs==1
            % bitmap PDF images
            f_out=[save_path fname '.pdf'];
            print(h,f_out,'-dpdf','-r300','-opengl')
            
        elseif save_figs==2
            % pdf images
            f_out=[save_path fname '.pdf'];
            print(h,f_out,'-dpdf','-r0')
        
        elseif save_figs==3
            % jpg images
            f_out=[save_path 'jpg/' fname '.jpg'];
            print(h,f_out,'-djpeg','-r300','-opengl')

        elseif save_figs==4
            % png images
            f_out=[save_path fname '.png'];
            print(h,f_out,'-dpng','-r300','-opengl')

        end
        
        pause(1)
        close(gcf)
        
    else
        return
    end

end

function bins_out=redo_bins(bins,min_tmp,max_tmp,len_bins)

    [~,tmp]=sort([bins,min_tmp,max_tmp]);
    bins_out=bins(max([find(tmp==len_bins+1)-1,1]):min([find(tmp==len_bins+2)-1,len_bins]));

end

function R2=plot_fit_line(xx,yy,c_in)

    % get line fit
    [slope, y_int, R2] = line_fit(xx,yy);
    
    % plot the results
%     plot_x=[min(xx)-max(abs(xx))*0.04:max(xx)/20:max(xx)+max(abs(xx))*0.05];
    plot_x=[150,550];
    plot(plot_x,slope(1)*plot_x+y_int(1),'--','linewidth',1,'color',c_in), hold on
    
%     disp((220*slope(1)+y_int(1)))
% disp(slope(1))

end

