


%% Fieldnames

LOC = fieldnames(locdata.subj{1,1});
TASK = fieldnames(locdata.subj{1,1}.avril);
JOINT = fieldnames(locdata.subj{1,1}.avril.cmj);
COMP = {'x','y','z'}';

%% Schwartz Analysis 

% Rather than inter-session, inter-trial we want...
% 1. Intra-location - variation for each location LOC across TASK, JOINT, COMP
% 2. Inter-location - variation pooled for all locations across TASK, JOINT, COMP

% 1a. Calculate the mean of all joints, locations, components
% session means - SUBJKL 2.1 eq 1

for ii = 1:7 % subj
    for jj = 1:length(LOC)
        for kk = 1:length(TASK)
            for ll = 1:length(JOINT)
                locdata.subj{ii,1}.(LOC{jj}).(TASK{kk}).(JOINT{ll}).x_mean = ...
                    mean(locdata.subj{ii,1}.(LOC{jj}).(TASK{kk}).(JOINT{ll}).x,2);


                locdata.subj{ii,1}.(LOC{jj}).(TASK{kk}).(JOINT{ll}).y_mean = ...
                    mean(locdata.subj{ii,1}.(LOC{jj}).(TASK{kk}).(JOINT{ll}).y,2);

                locdata.subj{ii,1}.(LOC{jj}).(TASK{kk}).(JOINT{ll}).z_mean = ...
                    mean(locdata.subj{ii,1}.(LOC{jj}).(TASK{kk}).(JOINT{ll}).z,2);
            end
        end
    end
end



% 1b. Calculate residuals 
% this is what is used in eq 2.3 and 2.4

for ii = 1:7 % subj
    for jj = 1:length(LOC)
        for kk = 1:length(TASK)
            for ll = 1:length(JOINT)
                locdata.subj{ii,1}.(LOC{jj}).(TASK{kk}).(JOINT{ll}).x_resid = ...
                    locdata.subj{ii,1}.(LOC{jj}).(TASK{kk}).(JOINT{ll}).x ...
                    - locdata.subj{ii,1}.(LOC{jj}).(TASK{kk}).(JOINT{ll}).x_mean;

                locdata.subj{ii,1}.(LOC{jj}).(TASK{kk}).(JOINT{ll}).y_resid = ...
                    locdata.subj{ii,1}.(LOC{jj}).(TASK{kk}).(JOINT{ll}).y ...
                    - locdata.subj{ii,1}.(LOC{jj}).(TASK{kk}).(JOINT{ll}).y_mean;

                locdata.subj{ii,1}.(LOC{jj}).(TASK{kk}).(JOINT{ll}).z_resid = ...
                    locdata.subj{ii,1}.(LOC{jj}).(TASK{kk}).(JOINT{ll}).z ...
                    - locdata.subj{ii,1}.(LOC{jj}).(TASK{kk}).(JOINT{ll}).z_mean;
            end
        end
    end
end

%% Collate into allsubj variable

% 1c. Collate all data across subjects into locdata.allsubj.intra structure
% NOTE this combines subj data across all data (means,kinematics etc)but 
% the key data needed is the *residual data* ...x_resid which we need later


nSubj = numel(locdata.subj);

for jj = 1:numel(LOC)                         % loop LOC
    locname = LOC{jj};

    TASK = fieldnames(locdata.subj{1}.(locname));

    for kk = 1:numel(TASK)                    % loop TASK
        taskname = TASK{kk};

        JOINT = fieldnames(locdata.subj{1}.(locname).(taskname));

        for ll = 1:numel(JOINT)               % loop JOINT
            jointname = JOINT{ll};

            % Only residual fields needed
            fields = {'x_resid','y_resid','z_resid'};

            for ff = 1:numel(fields)
                fieldname = fields{ff};

                tmp = [];

                for ii = 1:nSubj              % loop subjects
                    val = locdata.subj{ii}.(locname).(taskname).(jointname).(fieldname);

                    % concatenate trials across subjects
                    tmp = cat(2, tmp, val);   % [time × total_trials]
                end

                % store into intra structure
                locdata.allsubj.intra.(locname).(taskname).(jointname).(fieldname) = tmp;
            end
        end
    end
end

clear ii jj kk ll ff tmp val fieldname nSubj locname taskname jointname


%% Intra-location variation 

% 1d. Final intra-location variation (for each task, joint, component)
% Calc std of the residuals for the or each location variation
% Stored as locdata.intra_loc_var.(locname).(taskname).(jointname).(comp).intraloc

% for ii = 1:numel(LOC)                            % loop LOC
%     locname = LOC{ii};
%     TASK = fieldnames(locdata.allsubj.(locname));
% 
%     for jj = 1:numel(TASK)                       % loop TASK
%         taskname = TASK{jj};
%         JOINT = fieldnames(locdata.allsubj.(locname).(taskname));
% 
%         for kk = 1:numel(JOINT)                  % loop JOINT
%             jointname = JOINT{kk};
% 
%             for ll = 1:numel(COMP)               % loop COMP
%                 comp = COMP{ll};
%                 residField = [comp '_resid'];
% 
%                 % residuals already pooled across subjects: [time × nTrials]
%                 R = locdata.allsubj.(locname).(taskname).(jointname).(residField);
% 
%                 % intra-location variation = std across trials at each timepoint
%                 sigma_trial = std(R, 0, 2);
% 
%                 % store
%                 locdata.intra_loc_var.(locname).(taskname).(jointname).(comp) = sigma_trial;
%             end
%         end
%     end
% end
% 
% clear ii jj ll kk R locname resid* task* sigma* joint* comp R

for ii = 1:numel(LOC)                        % loop LOC
    locname = LOC{ii};

    TASK = fieldnames(locdata.allsubj.intra.(locname));

    for jj = 1:numel(TASK)                   % loop TASK
        taskname = TASK{jj};

        JOINT = fieldnames(locdata.allsubj.intra.(locname).(taskname));

        for kk = 1:numel(JOINT)              % loop JOINT
            jointname = JOINT{kk};

            for ll = 1:numel(COMP)           % loop COMP
                comp = COMP{ll};
                residField = [comp '_resid'];

                % pooled residuals [time × trials]
                R = locdata.allsubj.intra.(locname).(taskname).(jointname).(residField);

                % std across trials
                sigma_trial = std(R, 0, 2);

                % store
                locdata.intra_loc_var.(locname).(taskname).(jointname).(comp) = sigma_trial;
            end
        end
    end
end

clear ii jj kk ll R sigma_trial locname taskname jointname comp residField

%% Inter-location variation

% Pooled across LOC, but separated per TASK/JOINT/COMP
%
% Mirrors Schwartz eq. 2.2 (inter-therapist deviation) / eq. 2.4 (sigma_ther):
% deviations are RAW TRIAL values minus the subject's grand mean across
% locations (NOT location-mean minus grand-mean). This keeps the
% inter-location estimate cumulative - it contains trial-to-trial noise
% PLUS added location variability - so it is properly comparable to, and
% structurally >=, the intra-location estimate. This is what makes the
% inter/intra ratio (computed later) meaningful, analogous to Schwartz's
% sigma_ther/sigma_trial.

nSubj = numel(locdata.subj);

% re-fetch TASK/JOINT explicitly here rather than relying on leftover
% loop variables from the intra-location section above
TASK  = fieldnames(locdata.subj{1}.(LOC{1}));
JOINT = fieldnames(locdata.subj{1}.(LOC{1}).(TASK{1}));

for jj = 1:numel(TASK)
    taskname = TASK{jj};

    for kk = 1:numel(JOINT)
        jointname = JOINT{kk};

        for ll = 1:numel(COMP)
            comp = COMP{ll};
            meanField = [comp '_mean'];

            % --- initialise pooled container (Step 4)
            D_all = [];

            for pp = 1:nSubj   % loop subjects

                % STEP 1: Location means for this subject (used only to
                % build the subject's grand mean, i.e. the reference
                % level - NOT used as the deviation minuend)
                M_loc = [];

                for ii = 1:numel(LOC)
                    locname = LOC{ii};

                    M = locdata.subj{pp}.(locname).(taskname).(jointname).(meanField);
                    M_loc = cat(2, M_loc, M); % [time x nLoc]

                    % Store individual location means (per subject)
                    locdata.allsubj.inter.(taskname).(jointname).(comp).step1_means.(locname){pp} = M;
                end

                % Also store full matrix for this subject
                locdata.allsubj.inter.(taskname).(jointname).(comp).step1_Mloc{pp} = M_loc;

                % STEP 2: Subject grand mean across locations
                M_subj = mean(M_loc, 2); % [time x 1]

                locdata.allsubj.inter.(taskname).(jointname).(comp).step2_Msubj{pp} = M_subj;

                % STEP 3: Deviations of RAW TRIALS (not location means)
                % from the subject grand mean, per location - this is
                % the Schwartz eq. 2.2 analogue (Phi_klm - Phi_bar_subj)
                for ii = 1:numel(LOC)
                    locname = LOC{ii};

                    Xraw = locdata.subj{pp}.(locname).(taskname).(jointname).(comp); % [time x nTrials]
                    D = Xraw - M_subj;   % broadcast subtraction across trials

                    locdata.allsubj.inter.(taskname).(jointname).(comp).step3_D.(locname){pp} = D;

                    % STEP 4: Pool across locations and subjects
                    D_all = cat(2, D_all, D);
                end
            end

            % Store pooled deviations
            locdata.allsubj.inter.(taskname).(jointname).(comp).step4_Dall = D_all;

            % STEP 5: Final std (Schwartz eq. 2.4, sigma_ther analogue)
            sigma_interloc = std(D_all, 0, 2);

            locdata.inter_loc_var.(taskname).(jointname).(comp) = sigma_interloc;

            % Optional: also store in structure for traceability
            locdata.allsubj.inter.(taskname).(jointname).(comp).sigma_inter = sigma_interloc;

        end
    end
end

clear ii jj kk ll pp M M_loc M_subj D D_all Xraw sigma_interloc ...
    locname taskname jointname comp meanField nSubj



%% Calculate the ratio between inter-location and intra-location??

% Schwartz defines the ratio as σ_ther / σ_trial to quantify extrinsic error 
% relative to intrinsic trial-to-trial variability. 
% We could compute ratio(t) = inter_location_sigma(t) ./ intra_location_sigma(t)

% Inter / Intra ratio (per location)

for ii = 1:numel(LOC)                        % loop LOC
    locname = LOC{ii};

    TASK = fieldnames(locdata.intra_loc_var.(locname));

    for jj = 1:numel(TASK)                   % loop TASK
        taskname = TASK{jj};

        JOINT = fieldnames(locdata.intra_loc_var.(locname).(taskname));

        for kk = 1:numel(JOINT)              % loop JOINT
            jointname = JOINT{kk};

            for ll = 1:numel(COMP)           % loop COMP
                comp = COMP{ll};

                % --- get intra-location variability (this location)
                sigma_intra = locdata.intra_loc_var.(locname).(taskname).(jointname).(comp);

                % --- get inter-location variability (shared)
                sigma_inter = locdata.inter_loc_var.(taskname).(jointname).(comp);

                % --- ratio
                ratio = sigma_inter ./ sigma_intra;

                % --- store
                locdata.inter_intra_ratio.(locname).(taskname).(jointname).(comp) = ratio;
            end
        end
    end
end

clear ii jj kk ll ratio sigma_* locname taskname jointname comp



%% PLOTTING 
% Not all of these ranges are ideal, especially for CMJ and STS plots

% Titles and labels 
plttitles={'Trunk X','Trunk Y','Trunk Z',...
    'Pelvic Tilt','Pelvic Ob.','Pelvic Rot.',...
    'Hip X','Hip Y','Hip Z',...
    'Knee X','Knee Y','Knee Z',...
    'Ankle X','Ankle Y','Ankle Z'};
pltylabels={'Angle (deg)','','','Angle (deg)','','','Angle (deg)','','', ...
    'Angle (deg)','','','Angle (deg)','','',};
pltxlabels={'','','','','','','','','','','','','Gait Cycle (%)','Gait Cycle (%)','Gait Cycle (%)'};
ylimmax = [20, 20, 20, 20, 20, 20, 40, 40, 40, 70, 70, 70, 30, 30, 30];
ylimmin = [-20, -20, -20, -20, -20, -20, -30, -30, -30, -30, -30, -30, -40, -40, -40];
txtloc = ylimmax - ((ylimmax - ylimmin)*0.15); 
pltylabels2={'St. Dev. (deg)','','','St. Dev. (deg)','','','St. Dev. (deg)','','', ...
    'St. Dev. (deg)','','','St. Dev. (deg)','','',};

colors = repmat([0.7 0.7 0.7], 7, 1);    % grey




%% Note Anna has her own plotting code.

%% --- 1. RAW TRIAL PLOTS ---

for ii = 1:numel(LOC)
    locname = LOC{ii};
    for jj = 1:numel(TASK)
        taskname = TASK{jj};

        f = figure('Position',[1000 100 600 800]);
        t = tiledlayout(5,3,'TileSpacing','tight','Padding','compact');
        sgtitle(['Raw kinematics: ' locname ' - ' taskname])

        % loop joints/components in order
        joints = {'trunk','pelvis','hip','knee','ankle'};
        compOrder = {'x','y','z'};
        idx = 1;
        for kk = 1:numel(joints)
            jointname = joints{kk};
            for ll = 1:numel(compOrder)
                comp = compOrder{ll};
                nexttile
                hold on   % call once per axes

                for ss = 1:7
                    R = locdata.subj{ss}.(locname).(taskname).(jointname).(comp);
                    if isempty(R)
                        continue
                    end

                    c = colors(ss, :);                 % safe single-row indexing
                    if iscell(R)
                        for tt = 1:numel(R)
                            plot(R{tt}, 'Color', c, 'LineWidth', 1);
                        end
                    else
                        for tt = 1:size(R, 2)
                            plot(R(:,tt), 'Color', c, 'LineWidth', 1);
                        end
                    end
                end

                title(plttitles{idx})
                xlabel(pltxlabels{idx}); ylabel(pltylabels{idx})
                %ylim([ylimmin(idx), ylimmax(idx)])
                ylim('auto');
                xlim([0 101]); xticks(0:20:100)
                yline(0,'k-')
                idx = idx + 1;
                %lgd = legend(legendLabels, 'Location', 'southoutside', 'Orientation', 'horizontal');
                %lgd.Layout.Tile = 'south';  % works nicely with tiledlayout

            end
        end

        %exportgraphics(f,[locname '_' taskname '_raw.jpg'],'Resolution',300)
        %close(f)
    end
end

%% --- 2. GRAND MEANS (SPM1D) ---
for ii = 1:numel(LOC)
    locname = LOC{ii};
    TASK = fieldnames(locdata.allsubj.intra.(locname));
    for jj = 1:numel(TASK)
        taskname = TASK{jj};

        f = figure('Position',[1000 100 600 800]);
        t = tiledlayout(5,3,'TileSpacing','tight','Padding','compact');
        sgtitle(['Grand Means: ' locname ' - ' taskname])

        joints = {'trunk','pelvis','hip','knee','ankle'};
        compOrder = {'x','y','z'};
        idx = 1;
        for kk = 1:numel(joints)
            jointname = joints{kk};
            for ll = 1:numel(compOrder)
                comp = compOrder{ll};
                nexttile

                % plot grand mean ± SD
                spm1d.plot.plot_meanSD(locdata.allsubj.intra.(locname).(taskname).(jointname).([comp '_mean'])','color','b');
                title(plttitles{idx})
                xlabel(pltxlabels{idx}); ylabel(pltylabels{idx})
                %ylim([ylimmin(idx), ylimmax(idx)])
                ylim('auto');
                xlim([0 101]); xticks(0:20:100)
                yline(0,'k-')
                idx = idx + 1;
            end
        end

        exportgraphics(f,[locname '_' taskname '_grandmeans.jpg'],'Resolution',300)
        close(f)
    end
end


%% --- 3. INTRA- vs INTER-LOCATION ERRORS (all LOCs overlaid) ---


for jj = 1:numel(TASK)
    taskname = TASK{jj};

    f = figure('Position',[1000 100 600 800]);
    t = tiledlayout(5,3,'TileSpacing','tight','Padding','compact');
    sgtitle(['Errors: Intra vs Inter-location - ' taskname])

    joints = {'trunk','pelvis','hip','knee','ankle'};
    compOrder = {'x','y','z'};
    idx = 1;

    for kk = 1:numel(joints)
        jointname = joints{kk};
        for ll = 1:numel(compOrder)
            comp = compOrder{ll};
            nexttile

            % --- plot intra-location for all LOCs ---
            for ii = 1:numel(LOC)
                locname = LOC{ii};
                if isfield(locdata.intra_loc_var,locname) && ...
                   isfield(locdata.intra_loc_var.(locname),taskname) && ...
                   isfield(locdata.intra_loc_var.(locname).(taskname),jointname) && ...
                   isfield(locdata.intra_loc_var.(locname).(taskname).(jointname),comp)
                    intraloc = locdata.intra_loc_var.(locname).(taskname).(jointname).(comp);
                    plot(intraloc,'c--','HandleVisibility','off'); hold on
                end
            end

            % --- plot inter-location (pooled) ---
            interloc = locdata.inter_loc_var.(taskname).(jointname).(comp);
            plot(interloc,'m-','LineWidth',1.5,'DisplayName','Inter-location')

            title(plttitles{idx})
            xlabel(pltxlabels{idx}); ylabel(pltylabels2{idx})
            ylim([0,8]); yticks(0:2:6)
            xlim([0 101]); xticks(0:20:100)
            idx = idx + 1;
        end
    end

    %exportgraphics(f,[taskname '_errors.jpg'],'Resolution',300)
    %close(f)
end
