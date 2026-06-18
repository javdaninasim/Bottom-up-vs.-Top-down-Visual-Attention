%% Helper function to draw arrows
function drawArrow(x1, y1, x2, y2, color, lineWidth, arrowSize)
    % Draw the main line
    plot([x1, x2], [y1, y2], 'Color', color, 'LineWidth', lineWidth);
    
    % Calculate arrow direction
    dx = x2 - x1;
    dy = y2 - y1;
    length = sqrt(dx^2 + dy^2);
    
    if length > 0  % Avoid division by zero
        % Unit vector in direction of saccade
        ux = dx / length;
        uy = dy / length;
        
        % Perpendicular unit vector
        px = -uy;
        py = ux;
        
        % Arrow head points
        arrowX1 = x2 - arrowSize * (ux + 0.5 * px);
        arrowY1 = y2 - arrowSize * (uy + 0.5 * py);
        arrowX2 = x2 - arrowSize * (ux - 0.5 * px);
        arrowY2 = y2 - arrowSize * (uy - 0.5 * py);
        
        % Draw arrow head
        plot([arrowX1, x2, arrowX2], [arrowY1, y2, arrowY2], 'Color', color, 'LineWidth', lineWidth);
    end
end