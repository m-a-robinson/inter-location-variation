%% --- INTRA-LOCATION VARIATION ONLY (4 LOCs, custom colours + solid lines) ---

% Custom colours: bright pink, bright purple, cyan, dark blue
locColors = [
    1.0, 0, 1;       % Bright pink
    0, 0.7, 0;      % orange/green
    0, 1, 1;       % Cyan
    0, 0, 1; % Dark blue
];

for jj = 1:numel(TASK)
    taskname = TASK{jj};

    % Create figure
    f = figure('Position',[1000 100 600 800]);
    t = tiledlayout(5,3,'TileSpacing','tight','Padding','compact');
    sgtitle(['Intra-location Variability  - ' taskname])

    joints = {'trunk','pelvis','hip','knee','ankle'};
    compOrder = {'x','y','z'};
    idx = 1;

    for kk = 1:numel(joints)
        jointname = joints{kk};

        for ll = 1:numel(compOrder)
            comp = compOrder{ll};
            nexttile; hold on

            maxVals = NaN(numel(LOC),1);

            % --- PLOT ALL 4 LOCATIONS ---
            for ii = 1:numel(LOC)
                locname = LOC{ii};

                if isfield(locdata.intra_loc_var, locname) && ...
                   isfield(locdata.intra_loc_var.(locname), taskname) && ...
                   isfield(locdata.intra_loc_var.(locname).(taskname), jointname) && ...
                   isfield(locdata.intra_loc_var.(locname).(taskname).(jointname), comp)

                    intraloc = locdata.intra_loc_var.(locname).(taskname).(jointname).(comp);
                    maxVals(ii) = max(intraloc, [], 'omitnan');

                    plot(intraloc, '-', 'LineWidth', 1.0, ...
                        'Color', locColors(ii,:), ...
                        'DisplayName', locname);
                end
            end

            % --- Annotate top-left with max for each location ---
            [~, maxIdxOverall] = max(maxVals); % index of highest max

            for ii = 1:numel(LOC)
                if ~isnan(maxVals(ii))
                    % Determine if this is the highest max
if ii == maxIdxOverall
    valStr = sprintf('Max: %.2f*', maxVals(ii));  % append asterisk
else
    valStr = sprintf('Max: %.2f', maxVals(ii));
end

text(0.01, 0.98 - (ii-1)*0.06, valStr, ...
    'Color', locColors(ii,:), ...
    'FontSize', 5, ...
    'HorizontalAlignment','left', ...
    'VerticalAlignment','top', ...
    'Units','normalized'); % use normalized axes units

                end
            end
% --- Manual titles for each joint & component ---
plotTitleMap = struct();

plotTitleMap.trunk.x  = 'Trunk Sagittal';
plotTitleMap.trunk.y  = 'Trunk Frontal';
plotTitleMap.trunk.z  = 'Trunk Transverse';

plotTitleMap.pelvis.x = 'Pelvic Tilt';
plotTitleMap.pelvis.y = 'Pelvic Obliquity';
plotTitleMap.pelvis.z = 'Pelvic Rotation';

plotTitleMap.hip.x    = 'Hip Sagittal';
plotTitleMap.hip.y    = 'Hip Frontal';
plotTitleMap.hip.z    = 'Hip Transverse';

plotTitleMap.knee.x   = 'Knee Sagittal';
plotTitleMap.knee.y   = 'Knee Frontal';
plotTitleMap.knee.z   = 'Knee Transverse';

plotTitleMap.ankle.x  = 'Ankle Sagittal';
plotTitleMap.ankle.y  = 'Ankle Frontal';
plotTitleMap.ankle.z  = 'Ankle Transverse';

            % Axis formatting
            title(plotTitleMap.(jointname).(comp))
            if ~isempty(pltxlabels{idx})
    xlabel('Gait Cycle (%)')
else
    xlabel('')
end

            ylabel(pltylabels2{idx})
            ylim([0,14]); yticks(0:2:14)
            xlim([0 101]); xticks(0:20:100)
            set(gca,'Box','on','TickDir','in');

%             % Legend at top of figure only
%         if kk==1 && ll==1
%     lgd = legend(t, ...
%         {'Avril','Grass','Sporthall','Trees'}, ... % <- your capitalised names
%         'Location','northoutside', ...
%         'Orientation','horizontal');
% end





            idx = idx + 1;
        end
    end

    % Export figure
    %exportgraphics(f, [taskname 'intra_gaitcycle_2.jpg'], 'Resolution', 300)
    %close(f)
end

%% % --- Create standalone legend figure ---

figure('Color','w','Position',[100 100 600 120]);

% Dummy lines just for legend
h(1) = plot(NaN,NaN,'-','LineWidth',2,'Color',[1.0 0 1]);   % Avril
hold on
h(2) = plot(NaN,NaN,'-','LineWidth',2,'Color',[0 0.7 0]);   % Grass
h(3) = plot(NaN,NaN,'-','LineWidth',2,'Color',[0 1 1]);     % Sporthall
h(4) = plot(NaN,NaN,'-','LineWidth',2,'Color',[0 0 1]);     % Trees

axis off

lgd = legend(h, {'Library (A)','Grass (B)','Sporthall (C)','Trees (D)'}, ...
    'Orientation','horizontal', ...
    'Location','north');

lgd.Box = 'off';
lgd.FontSize = 10;

% Export legend only
exportgraphics(gcf,'Legend_only_lettered_NEW.png','Resolution',300);

