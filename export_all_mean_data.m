%% Export CSV: average intra-location variability (per location) + inter-location + ratios
% Requires locdata.intra_loc_var and locdata.inter_loc_var to exist.

% --- get LOC, TASK, JOINT lists (robustly) ---
if exist('LOC','var') && ~isempty(LOC)
    locList = LOC;
elseif isfield(locdata, 'intra_loc_var')
    locList = fieldnames(locdata.intra_loc_var);
elseif isfield(locdata, 'allsubj')
    % fallback: use locations from allsubj or subj{1}
    locList = fieldnames(locdata.allsubj);
else
    locList = fieldnames(locdata.subj{1});
end

if exist('TASK','var') && ~isempty(TASK)
    taskList = TASK;
else
    % find tasks from first available location
    taskList = {};
    for li = 1:numel(locList)
        ln = locList{li};
        if isfield(locdata.intra_loc_var, ln)
            taskList = fieldnames(locdata.intra_loc_var.(ln));
            break;
        end
    end
    if isempty(taskList)
        % fallback to subj structure
        taskList = fieldnames(locdata.subj{1});
    end
end


% Use standardized JOINTS and COMPS if you prefer, otherwise use fields
JOINTS = {'trunk','pelvis','hip','knee','ankle'};
COMPS = {'x','y','z'};

% Build output rows
rows = {};     % each row is a cell array representing a table row

for ti = 1:numel(taskList)
    taskname = taskList{ti};
    for ji = 1:numel(JOINTS)
        jointname = JOINTS{ji};
        for ci = 1:numel(COMPS)
            comp = COMPS{ci};

            % Main Output 1
            % per-location average intra-location variability (scalar per location)
            intra_avgs = nan(1, numel(locList));
            for li = 1:numel(locList)
                locname = locList{li};
                try
                    if isfield(locdata.intra_loc_var, locname) && ...
                       isfield(locdata.intra_loc_var.(locname), taskname) && ...
                       isfield(locdata.intra_loc_var.(locname).(taskname), jointname) && ...
                       isfield(locdata.intra_loc_var.(locname).(taskname).(jointname), comp)

                        intraloc_time = locdata.intra_loc_var.(locname).(taskname).(jointname).(comp); % [time x 1]
                        % average across timepoints to get scalar
                        intra_avgs(li) = mean(intraloc_time(:));
                    else
                        intra_avgs(li) = NaN;
                    end
                catch
                    intra_avgs(li) = NaN;
                end
            end

            % inter-location average (scalar)
            inter_avg = NaN;
            try
                if isfield(locdata.inter_loc_var, taskname) && ...
                   isfield(locdata.inter_loc_var.(taskname), jointname) && ...
                   isfield(locdata.inter_loc_var.(taskname).(jointname), comp)
                    inter_time = locdata.inter_loc_var.(taskname).(jointname).(comp); % [time x 1]
                    inter_avg = mean(inter_time(:));
                end
            catch
                inter_avg = NaN;
            end

            % % ratios per location:

            % OLD INCORRECT CODE - replaced 25/06/26
            % if ~isnan(inter_avg) && inter_avg ~= 0
            %     ratio_loc = intra_avgs ./ inter_avg;
            % else
            %     ratio_loc = NaN(size(intra_avgs));
            % end

            ratio_loc = NaN(size(intra_avgs));  % prefill

            for li = 1:numel(locList)
                locname = locList{li};
                try
                    if isfield(locdata, 'inter_intra_ratio') && ...
                            isfield(locdata.inter_intra_ratio, locname) && ...
                            isfield(locdata.inter_intra_ratio.(locname), taskname) && ...
                            isfield(locdata.inter_intra_ratio.(locname).(taskname), jointname) && ...
                            isfield(locdata.inter_intra_ratio.(locname).(taskname).(jointname), comp)

                        ratio_time = locdata.inter_intra_ratio.(locname).(taskname).(jointname).(comp); % [time x 1]
                        % take time-average to get scalar ratio for this location
                        ratio_loc(li) = mean(ratio_time(:));  % use 'omitnan' if you want to ignore NaNs
                    else
                        ratio_loc(li) = NaN;
                    end
                catch
                    ratio_loc(li) = NaN;
                end
            end


            % build a row: Task, Joint, Component, then intra_avgs columns, InterAvg, then ratio columns
            row = [{taskname, jointname, comp}, num2cell(intra_avgs), {inter_avg}, num2cell(ratio_loc) ];
            rows = [rows; row];
        end
    end
end

% Create table variable names
locCols = strcat('Intra_', locList(:))';         % e.g. Intra_avril
ratioCols = strcat('Ratio_', locList(:))';       % e.g. Ratio_avril
varNames = [{'Task','Joint','Component'}, locCols, {'InterAvg'}, ratioCols];

% Convert rows cell to table
T = cell2table(rows, 'VariableNames', varNames);

% Save CSV
outname = 'intra_location_by_location_summary_sep26.csv';
writetable(T, outname);
fprintf('Saved %s (%d rows, %d columns)\n', outname, size(T,1), size(T,2));
