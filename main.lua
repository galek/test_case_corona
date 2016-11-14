require "CiderDebugger";

-- Hide the status bar
display.setStatusBar( display.HiddenStatusBar )

-- Set the background to white
display.setDefault( "background", 1 )	-- white

-- Require the widget & Composer libraries
local widget = require( "widget" )
local composer = require( "composer" )
local json = require( "json" )

local themeID = 1

-- USED FOR LOCALISATION
local LOC_LoadedFilesTitle="Loaded Files"


local function showWidgets( widgetThemeNum )

	local halfW = display.contentCenterX
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
        
	local titleText = display.newText( LOC_LoadedFilesTitle, halfW, titleBar.y, native.systemFont, 14 )
        
	-- Start at tab1
	composer.gotoScene( "frm_2" )
end

showWidgets( themeID )