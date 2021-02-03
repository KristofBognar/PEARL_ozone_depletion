function [ spv, temperature, theta, lat, lon ] = match_DMP_all( ft_meas, year, type_in, alt  )
%MATCH_DMP_ALL

% Returns DMPs for measurements of given instrument
%
% INPUT
%       ft_meas: array of measurement times (fractional time, Jan, 1, 00:00 = 0)
%       year: year of measurments as a number, or as an array with the same
%               length as ft_meas
%       type_in: instrument/species to match
%       alt: altitude levels where DMP outputs are required
%
% OUTPUT
%       spv, temperature, theta: DMPs for the given measurement,
%               dimensions of length(ft_meas) X length(alt)
%       lat, lon: latitude and longitude of the point along the line of
%               sight at each altitude, dimensions of length(ft_meas) X length(alt)
%
%       Notes: Output will match input line by line, even if input times are not sorted
%              DMP matches are selected based on time cutoff specified in
%                the code. All measurements should have matching DMP, but
%                cutoff is useful if multiple datasets use the same DMPs
%
% Kristof Bognar, Aug 2020 (unified version of match_DMP_* codes from
%                           satellite validation older)

% if ~issorted(year), error('measurements must be sorted'); end

if size(alt,1)~=1, alt=alt'; end

%% check how year is specified
if length(year)==1 % sinle year
    
    % set loop variables
    years=year;
    ind_ft=1:length(ft_meas);
    
elseif length(year)==length(ft_meas) % year specified for each fractional time
    
    % set loop variables
    [years,~,ind_ft_unique]=unique(year);
    
    % make sure shape is correct
    if size(years,1)~=1, years=years'; end
    if size(ind_ft_unique,1)~=1, ind_ft_unique=ind_ft_unique'; end
    
else
    error('Measurement times and years don''t match')
end

%% setup output variables

spv=NaN(length(ft_meas),length(alt));
temperature=NaN(length(ft_meas),length(alt));
lat=NaN(length(ft_meas),length(alt));
lon=NaN(length(ft_meas),length(alt));
theta=NaN(length(ft_meas),length(alt));

%% select DMP folder and match time window

match_cutoff=1/(24*60); % default: 1 min for bruker/brewer (should be accurate to nearset
                        % second, but wide window won't affect closest match)

if strcmp(type_in,'BRUKER')
    dmp_path='/home/kristof/work/DMP/DMP_bruker/';
elseif strfind(type_in,'BREWER')
    dmp_path='/home/kristof/work/DMP/DMP_brewer/';
elseif strfind(type_in,'DOAS')
    dmp_path='/home/kristof/work/DMP/DMP_DOAS_meas_time/';
    match_cutoff=0.2; % just pick same twilight (VCDs vs OClO/BrO will have slightly
                      % different times)
elseif strfind(type_in,'VERTICAL')
    dmp_path='/home/kristof/work/DMP/DMP_vertical/';
    match_cutoff=31/(24*60); % 30 min, since EWS DMPs are hourly
elseif strfind(type_in,'PANDORA')
    dmp_path='/home/kristof/work/DMP/DMP_pandora/';
    match_cutoff=21/(24*60); % 20 min, same interval used for DMP generation
else
    error([ type_in ' not recognized (it''s case sensitive)'])
end

%% loop over the measurements
n=0;
for yy=years
    
    % display progress info
    disp_str=['DMP matching for ' num2str(yy) ' ' type_in ' data'];
    % stuff to delete last line and reprint updated message
    fprintf(repmat('\b',1,n));
    fprintf(disp_str);
    n=numel(disp_str);    
    
    % select list of indices for given year if there are multiple years
    if exist('ind_ft_unique', 'var')
        ind_ft=find(ind_ft_unique==find(years==yy));
    end
    
    % load DMP file for given year and species
    dmp_file=[dmp_path type_in '_DMP_table_' num2str(yy) '.mat'];
    try
        load(dmp_file);
    catch
        if strfind(type_in,'VERTICAL') % not all years are available
            continue
        else % other instruments should have full coverage
            error([dmp_file ' not found'])
        end
    end
    
    for ii=ind_ft
        
         % find closest DMP time
        [tmp,ind_dmp]=sort(abs(fractional_time-ft_meas(ii)));
        
        % check if it's an actual match 
        if tmp(1)<match_cutoff
            
            % index of match
            ind_dmp=ind_dmp(1);

            spv(ii,:)=interp1(dmp_all{ind_dmp}.alt,dmp_all{ind_dmp}.spv,alt);
            temperature(ii,:)=interp1(dmp_all{ind_dmp}.alt,dmp_all{ind_dmp}.temperature,alt);
            lat(ii,:)=interp1(dmp_all{ind_dmp}.alt,dmp_all{ind_dmp}.lat,alt);
            lon(ii,:)=interp1(dmp_all{ind_dmp}.alt,dmp_all{ind_dmp}.lon,alt);
            theta(ii,:)=interp1(dmp_all{ind_dmp}.alt,dmp_all{ind_dmp}.theta,alt);
            
        end
    end
end

fprintf('\n')

end

