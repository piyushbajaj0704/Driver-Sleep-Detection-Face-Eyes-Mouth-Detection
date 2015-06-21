function c1 =match_DB(Leye,DBL)


MS1 = [];
for tt = 1:length(DBL)
    % Obtain the image
    It = DBL{1,tt};
    if ~isempty(It)
        % Calculate correlation coefficient
        MS1 = [MS1 corr2(It,Leye)];
    else
        break;
    end
end

MS2 = [];
for tt = 1:length(DBL)
    % Obtain the image
    It = DBL{2,tt};

    if ~isempty(It)
        % Calculate correlation coefficient
        MS2 = [MS2 corr2(It,Leye)];
    else
        break;
    end
end

% Take mean value
M(1) = mean(MS1);
M(2) = mean(MS2);

% Decide about the condition
c1 = find(M == max(M));