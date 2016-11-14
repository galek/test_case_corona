function InitHeader(text, sceneGroup, ox, oy)
    local halfW = display.contentCenterX

    -- Create title bar at top of the screen
    local titleGradient = {
        type = 'gradient',
        color1 = { 189 / 255, 203 / 255, 220 / 255, 1 },
        color2 = { 89 / 255, 116 / 255, 152 / 255, 1 },
        direction = "down"
    }

    local titleBar = display.newRect(halfW, 0, display.contentWidth + ox + ox, 32)
    titleBar:setFillColor(titleGradient)
    titleBar.y = titleBar.contentHeight * 0.5 - oy

    sceneGroup:insert(titleBar)
    local titleText = display.newText(text, halfW, titleBar.y, native.systemFont, 14)
    sceneGroup:insert(titleText)

end