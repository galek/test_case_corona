require "CiderDebugger";

-- Hide the status bar
display.setStatusBar( display.HiddenStatusBar )

-- Set the background to white
display.setDefault( "background", 1 )	-- white

-- Require the widget & Composer libraries
local widget = require( "widget" )
local composer = require( "composer" )
local json = require( "json" )

local themeIDs = {
					"widget_theme_android_holo_dark",
					"widget_theme_android_holo_light",
					--"widget_theme_android",
					"widget_theme_ios7",
					--"widget_theme_ios", 
				}
local themeNames = {
					"Android Holo Dark",
					"Android Holo Light",
					--"Android 2.x",
					"iOS7+",
					--"iOS6"
				}

local function showWidgets( widgetThemeNum )

	local halfW = display.contentCenterX
	local halfH = display.contentCenterY
	local ox, oy = math.abs(display.screenOriginX), math.abs(display.screenOriginY)

	-- Create title bar at top of the screen
	local titleGradient = {
		type = 'gradient',
		color1 = { 189/255, 203/255, 220/255, 1 }, 
		color2 = { 89/255, 116/255, 152/255, 1 },
		direction = "down"
	}
	local titleBar = display.newRect( halfW, 0, display.contentWidth+ox+ox, 32 )
	titleBar:setFillColor( titleGradient )
	titleBar.y = titleBar.contentHeight * 0.5 - oy

	local titleText = display.newText( "Widget Demo - "..themeNames[widgetThemeNum], halfW, titleBar.y, native.systemFont, 14 )
        
	-- Start at tab1
	composer.gotoScene( "frm_1" )
end

local function themeChooser( event )
	--print( "themeChooser: "..json.encode(event) )

	local chosenTheme = event.index
	if chosenTheme < 1 then
		-- Default to the first theme choice if one wasn't made (event.index == 0).
		chosenTheme = 1
	end
	showWidgets( chosenTheme )
end

native.showAlert( "Choose Theme", "Widgets can be skinned to look like different device OS versions.", themeNames, themeChooser )
