function normalized = normalizeMap(map)
   if max(map(:)) == 0
        normalized = map;
        return;
    end
    
    % Basic normalization to [0,1]
    normalized = (map - min(map(:))) / (max(map(:)) - min(map(:)));
    
    % Apply Itti's normalization operator (simplified version)
    % This promotes maps with few strong peaks over maps with many similar peaks
    M = max(normalized(:));
    m_bar = mean(normalized(:));
    
    if M > 0
        normalized = (M - m_bar)^2 * normalized;
    end
    
    % Final normalization
    if max(normalized(:)) > 0
        normalized = normalized / max(normalized(:));
    end
end