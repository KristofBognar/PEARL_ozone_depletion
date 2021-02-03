

if 0
    
    load(['/home/kristof/work/radiosonde/Eureka/radiosonde_2020.mat']);

    figure(99)

    x_lim=[180,230];

    for i=43:204

        % ridge lab altitude
        plot([188,188],[0,30],'k--'), hold on
        plot([195,195],[0,30],'k--')

        % redraw previous line in gray
        if i>1
            delete(h)
            plot(ptu_data.(['ptu_' f_list{i-1}])(:,3)+273.15,...
                ptu_data.(['ptu_' f_list{i-1}])(:,1)/1000,...
                'color',[0,0,0]+0.8,'linewidth',2), hold on
        end

        h=plot(ptu_data.(['ptu_' f_list{i}])(:,3)+273.15,...
                ptu_data.(['ptu_' f_list{i}])(:,1)/1000,...
                'b-','linewidth',2);
        ylim([8,25])

        % make x limits adaptive
        tmp=max(ptu_data.(['ptu_' f_list{i}])((ptu_data.(['ptu_' f_list{i}])(:,1)/1000>8 & ...
                ptu_data.(['ptu_' f_list{i}])(:,1)/1000 < 25),3)+273.15);
        if tmp>x_lim(2)
            x_lim(2)=tmp+1;
        end
        xlim(x_lim)


        title([f_list{i}(3:4) '/' f_list{i}(5:6) ' ' f_list{i}(7:8) ':00'])

        xlabel('Temperature (K)')
        ylabel('Altitude (km)')

        % pause loop until figure is clicked on
        try
            tmp=1;
            while tmp % loop so key presses (return 1) are not accepted
                tmp=waitforbuttonpress;
            end
        catch
            % returns error if figure is closed, exit when that happens
            return
        end
    end

end

if 1
    
    year=2020;
    ystr=num2str(year);

    ozone=1;
    temperature=0;
    wind=0;
    RH=0;

    %% plot ozonesonde colorplot
    load(['/home/kristof/work/ozonesonde/Eureka/o3sonde_' ystr '.mat'])

    ll=length(f_list);

    hw=10/24; % half width of single sonde plot in time (to allow use of surf)

    alt_lim=[12,23]*1000; % altitude limit in m

    figure()

    % loop over all sonde data
    for i=1:ll

        % load altitude grid and ozone vmr
        o3=sonde_data.(f_list{i})(:,2);
        alt=sonde_data.(f_list{i})(:,1);

        if max(alt)<18100, continue, end
        
        % get list of launch times in fractional date
        [ft,~]=fracdate([launchtime{i,1} ' ' launchtime{i,2}],'yyyy-mm-dd HH:MM:SS');
        
        % create arrays to allow color plot, and implement altitude limit
        ft=[ft-hw:hw:ft+hw];

        o3=o3(alt<alt_lim(2) & alt>alt_lim(1))*1e6; % convert to ppb
        alt=alt(alt<alt_lim(2) & alt>alt_lim(1))./1000; % convert to km

        if isempty(o3), continue, end
        
        o3=[o3,o3,o3];
        alt=[alt,alt,alt];

        % color plot
        surf(ft,alt,o3,'EdgeColor','None', 'facecolor', 'interp'), hold on
        ylabel('Altitude (km)')
%         xlabel('Days of March, 2017 (UTC)')

        c=colorbar;
        ylabel(c, 'Ozone conc. (ppbv)')

        % set view to see x-y plane from above
        view(2)
        colormap(jet(300))

        ylim(alt_lim/1000)        
        
    end

end