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



local function showWidgets( widgetThemeNum )     
	-- Start at tab1
	composer.gotoScene( "frm_1" )
end

showWidgets( themeID )