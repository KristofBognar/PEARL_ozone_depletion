function reformat_slimcat(qy,save_data)
%READ_SLIMCAT Summary of this function goes here
%   Detailed explanation goes here

if nargin==1
    save_data=0;
end

int_type='midpoint';

% data location
data_dir=['/home/kristof/work/models/SLIMCAT/QY_' qy '/'];
data_dir_alt='/home/kristof/work/models/SLIMCAT/QY_1/';

% pressure in QY=0.8 files is at layer centres!!
% pressure in QY=1 files is at lower layer boundary!! (lowest P is surface,
% top layer (P=0 Pa) missing for simplicity)
replace_P=1;

%% save data as yearly structures?
% takes a while
if save_data
    
    % data format warning
    disp('Saving SLIMCAT data')
    disp(' ')
    disp('WARNING: data format is hard-coded:')
    disp('yearly files, output every 6 h, 32 levels, 14 columns')

    % get list of data files
    for yy=2000:2020
        save_as_struct({[data_dir 'tomcat_' qy 'QY_era5_eureka_' num2str(yy) '.dat']},...
            [data_dir 'slimcat_' num2str(yy) '_vmr.mat']);
    end
end

%% get column values

slimcat=[];

for yy=2000:2020
    
    if replace_P
        load([data_dir_alt 'slimcat_' num2str(yy) '_vmr.mat']);
        p_only=slimcat_vmr;
    end
    
    load([data_dir 'slimcat_' num2str(yy) '_vmr.mat']);
    field_list=fieldnames(slimcat_vmr);
    
    % get variable names 
    varnames=slimcat_vmr.(field_list{1}).Properties.VariableNames;
    varnames=varnames(5:end-1); % need tracegases only, assume format is unchanged
    
    % set up output tables
    cols_tmp=zeros(length(field_list),length(varnames));
    datetime_tmp=NaT(size(field_list));
    
    for i=1:length(field_list)
        
        % get current field (flip so altitude increases with row index)
        data=flipud(slimcat_vmr.(field_list{i}));
        
        % calculate air number density (molec/m^3)
        if strcmp(qy,'1') || replace_P
            % QY=1 files, P is at lower layer boundary: interpolate to
            % layer centres first!
            try
                data_alt=flipud(p_only.(field_list{i}));
                
                lim_arr_alt=get_alt_limits(data_alt.alt);
                if any(diff(data_alt.P_Pa)>0), error('flip P array!'), end
                p_centre=interp1(lim_arr_alt,[data_alt.P_Pa;0],data_alt.alt);
                
                num_dens=((6.022e23*p_centre)./(8.314*data_alt.T_K));
            catch
                num_dens=ones(size(data.P_Pa))*-1;
            end
        elseif strcmp(qy,'08')
            num_dens=((6.022e23*data.P_Pa)./(8.314*data.T_K));
        end
        
        % get approx. altitude grid (not ideal since grid spacing is
        % variable and not monotonic)
        lim_arr=get_alt_limits(data.alt);
        
        % get columns
        for j=1:length(varnames)
            
            % integrate each tracegas concentration (result is molec/m^2)
            cols_tmp(i,j)=integrate_nonuniform(data.alt,data.(varnames{j}).*num_dens,...
                min(lim_arr),max(lim_arr),int_type,diff(lim_arr));
            
        end
        
        datetime_tmp(i)=data.DateTime(1);
        
    end
    
    % convert to molec/cm2
    cols_tmp=cols_tmp.*1e-4;

    % convert to table and add datetime
    cols_tmp=array2table(cols_tmp,'VariableNames',varnames);
    cols_tmp.DateTime=datetime_tmp;

    slimcat=[slimcat; cols_tmp];
    
end

%% finalise table

% add extra time columns
slimcat.year=slimcat.DateTime.Year;
slimcat.mjd2k=mjd2k(slimcat.DateTime);
slimcat.fractional_time=mjd2k_to_ft(slimcat.mjd2k);

du=2.687e16;
slimcat.o3=slimcat.o3/du;
slimcat.o3_passive=slimcat.o3_passive/du;

% save
save([data_dir 'slimcat_columns_' int_type '.mat'],'slimcat')


end

%%
function save_as_struct(f_list,save_name)
 
% file format
n_header=3; % header lines (incl. time info)
n_levels=32; % (number of model levels)

% column names
prof_header={'level','P_Pa','T_K','alt','o3','o3_passive',...
             'no2','oclo','bro','hno3','hcl','clono2','n2o','hf'};

% loop over each file (assuming yearly files!)
slimcat_vmr=struct();

for ff=f_list
    
    % loop over max possible data blocks (some files have extra entries...)
    for i=1:380*4
        
        % row to read (first row is 0)
        daterow=1+(i-1)*(n_header+n_levels);
        % get time info
        try
            date_line=dlmread(ff{1},'',[daterow 0 daterow 5]);
        catch % if at the end of the file, exit the loop
            break
        end
        
        % get date info
        date_tmp=datetime([date_line(1:4),0,0]);
        
        % start of profles block
        profs_row=n_header+(i-1)*(n_header+n_levels);
        % get profiles
        profs=dlmread(ff{1},'',[profs_row 0 profs_row+31 13]);
    
        % convert to table
        profs=array2table(profs,'VariableNames',prof_header);
        % add datetime info
        profs.DateTime=repmat(date_tmp,n_levels,1);
        
        % save in structure with date as fieldname
        slimcat_vmr.(['profs_' sprintf('%i%02i%02i%02i', date_line(1:4))])=profs;
        
    end
    
end

% save result
save(save_name,'slimcat_vmr')

end

%%
function lim_arr=get_alt_limits(alt)

    lim_arr=zeros(length(alt)+1,1);
    
    for i=1:length(alt)
        lim_arr(i+1) = lim_arr(i) + (alt(i)-lim_arr(i))*2;
    end

end
