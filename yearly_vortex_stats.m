% update vortex position tags
tag_data_by_sPV([16,18,20]);

% load tagged file
load('/home/kristof/work/PEARL_ozone_depletion/PEARL_dataset_tagged.mat')

if 0
    for yr=1999:2020

        disp(num2str(yr))

        ind=gbs_o3.year==yr;
        if any(ind)
            disp([sum(gbs_o3.in_edge_out(ind)==-1), sum(gbs_o3.in_edge_out(ind)==0), ...
                sum(gbs_o3.in_edge_out(ind)==1)])
        end

        ind=saoz_o3.year==yr;
        if any(ind)
            disp([sum(saoz_o3.in_edge_out(ind)==-1), sum(saoz_o3.in_edge_out(ind)==0), ...
                sum(saoz_o3.in_edge_out(ind)==1)])
        end

        ind=bruker.o3.year==yr;
        if any(ind)
            disp([sum(bruker.o3.in_edge_out(ind)==-1), sum(bruker.o3.in_edge_out(ind)==0), ...
                sum(bruker.o3.in_edge_out(ind)==1)])
        end


        disp('')

    end
end

legend_str={};
figure
for yr=1999:2020
    ind=(gbs_o3.year==yr & gbs_o3.spv(:,3)>1.6e-4);
    if any(ind)
        plot(gbs_o3.fractional_time(ind),gbs_o3.spv(ind,3),'ko'), hold on
        legend_str(end+1)={num2str(yr)};
    end
end

legend(legend_str)
% plot([40,160],[1.2,1.2]*1e-4,'k--')
% plot([40,160],[1.6,1.6]*1e-4,'k--')





