%% --- INTER LOCATION VARIATION (inter-location only)

for jj = 1:numel(TASK)
    taskname = TASK{jj};

    f = figure('Position',[1000 100 600 800]);
    t = tiledlayout(5,3,'TileSpacing','tight','Padding','compact');
    sgtitle(['Inter-location Variation - ' taskname])

    joints = {'trunk','pelvis','hip','knee','ankle'};
    compOrder = {'x','y','z'};
    idx = 1;

    for kk = 1:numel(joints)
        jointname = joints{kk};
        for ll = 1:numel(compOrder)
            comp = compOrder{ll};
            ax = nexttile;

            % --- get pooled inter-location series (vector) ---
            if isfield(locdata.inter_loc_var,taskname) && ...
               isfield(locdata.inter_loc_var.(taskname),jointname) && ...
               isfield(locdata.inter_loc_var.(taskname).(jointname),comp)
                interloc = locdata.inter_loc_var.(taskname).(jointname).(comp);
            else
                interloc = [];
            end

            if ~isempty(interloc)
                x = 1:numel(interloc);

                % single black line
                plot(x,interloc,'k-','LineWidth',1.5); hold on

                % find max and plot open circle at max
                [maxVal, maxIdx] = max(interloc);
                plot(x(maxIdx), maxVal, 'o', ...
                    'MarkerSize',7, 'MarkerEdgeColor','k', 'MarkerFaceColor','none');

                % annotate top-left with Max and Mean for this subplot
                meanVal = mean(interloc,'omitnan');
                annStr = sprintf('Max: %.2f\\newlineMean: %.2f', maxVal, meanVal);
                text(0.01, 0.98, annStr, ...
                    'Units','normalized', 'HorizontalAlignment','left', ...
                    'VerticalAlignment','top', 'FontSize',8, 'Color','k');

                % axes formatting
                title(plttitles{idx});
                xlabel(pltxlabels{idx}); ylabel(pltylabels2{idx});
                ylim([0,12]); yticks(0:2:12);
                xlim([0 101]); xticks(0:20:100);
            else
                % empty data: show title/labels
                title(plttitles{idx});
                xlabel(pltxlabels{idx}); ylabel(pltylabels2{idx});
            end

            idx = idx + 1;
        end
    end

    %exportgraphics(f,[taskname '_inter_loc_var.jpg'],'Resolution',300)
    %close(f)
end