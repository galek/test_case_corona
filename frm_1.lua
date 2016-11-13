local widget = require( "widget" )
local composer = require( "composer" )
local scene = composer.newScene()

-- Create scene
function scene:create( event )
	local sceneGroup = self.view
	local ox, oy = math.abs(display.screenOriginX), math.abs(display.screenOriginY)
	local tabBarHeight = composer.getVariable( "tabBarHeight" )
	local themeID = composer.getVariable( "themeID" )

	-- Set color variables depending on theme
	local tableViewColors = {
		rowColor = { default = { 1 }, over = { 30/255, 144/255, 1 } },
		lineColor = { 220/255 },
		catColor = { default = { 150/255, 160/255, 180/255, 200/255 }, over = { 150/255, 160/255, 180/255, 200/255 } },
		defaultLabelColor = { 0, 0, 0, 0.6 },
		catLabelColor = { 0 }
	}
        
	tableViewColors.rowColor.default = { 48/255 }
	tableViewColors.rowColor.over = { 72/255 }
	tableViewColors.lineColor = { 36/255 }
	tableViewColors.catColor.default = { 80/255, 80/255, 80/255, 0.9 }
	tableViewColors.catColor.over = { 80/255, 80/255, 80/255, 0.9 }
	tableViewColors.defaultLabelColor = { 1, 1, 1, 0.6 }
	tableViewColors.catLabelColor = { 1 }
	
	-- Forward reference for the tableView
	local tableView
	
	-- Text to show which item we selected
	local itemSelected = display.newText( "User selected row ", 0, 0, native.systemFont, 16 )
	itemSelected:setFillColor( unpack(tableViewColors.catLabelColor) )
	itemSelected.x = display.contentWidth+itemSelected.contentWidth
	itemSelected.y = display.contentCenterY
	sceneGroup:insert( itemSelected )
	
	-- Function to return to the tableView
	local function goBack( event )
		transition.to( tableView, { x=display.contentWidth*0.5, time=600, transition=easing.outQuint } )
		transition.to( itemSelected, { x=display.contentWidth+itemSelected.contentWidth, time=600, transition=easing.outQuint } )
		transition.to( event.target, { x=display.contentWidth+event.target.contentWidth, time=480, transition=easing.outQuint } )
	end
	
	-- Back button
	local backButton = widget.newButton {
		width = 128,
		height = 32,
		label = "back",
		onRelease = goBack
	}
	backButton.x = display.contentWidth+backButton.contentWidth
	backButton.y = itemSelected.y+itemSelected.contentHeight+16
	sceneGroup:insert( backButton )
	
	-- Listen for tableView events
	local function tableViewListener( event )
		local phase = event.phase
		--print( "Event.phase is:", event.phase )
	end

	-- Handle row rendering
	local function onRowRender( event )
		local phase = event.phase
		local row = event.row

		local groupContentHeight = row.contentHeight
		
		local rowTitle = display.newText( row, "Row " .. row.index, 0, 0, nil, 14 )
		rowTitle.x = 10
		rowTitle.anchorX = 0
		rowTitle.y = groupContentHeight * 0.5
		if ( row.isCategory ) then
			rowTitle:setFillColor( unpack(row.params.catLabelColor) )
			rowTitle.text = rowTitle.text.." (category)"
		else
			rowTitle:setFillColor( unpack(row.params.defaultLabelColor) )
		end
	end
	
	-- Handle row updates
	local function onRowUpdate( event )
		local phase = event.phase
		local row = event.row
		--print( row.index, ": is now onscreen" )
	end
	
	-- Handle touches on the row
	local function onRowTouch( event )
		local phase = event.phase
		local row = event.target
		if ( "release" == phase ) then
			itemSelected.text = "User selected row " .. row.index
			transition.to( tableView, { x=((display.contentWidth/2)+ox+ox)*-1, time=600, transition=easing.outQuint } )
			transition.to( itemSelected, { x=display.contentCenterX, time=600, transition=easing.outQuint } )
			transition.to( backButton, { x=display.contentCenterX, time=750, transition=easing.outQuint } )
		end
	end
	
	-- Create a tableView
	tableView = widget.newTableView
	{
		top = 32-oy,
		left = -ox,
		width = display.contentWidth+ox+ox, 
		height = display.contentHeight--
---tabBarHeight      //NICK
+oy+oy-32,
		hideBackground = true,
		listener = tableViewListener,
		onRowRender = onRowRender,
		onRowUpdate = onRowUpdate,
		onRowTouch = onRowTouch,
	}
	sceneGroup:insert( tableView )

	-- Create 75 rows
	for i = 1,75 do
		local isCategory = false
		local rowHeight = 32
		local rowColor = { 
			default = tableViewColors.rowColor.default,
			over = tableViewColors.rowColor.over,
		}
		-- Make some rows categories
		if i == 20 or i == 40 or i == 60 then
			isCategory = true
			rowHeight = 32
			rowColor = {
				default = tableViewColors.catColor.default,
				over = tableViewColors.catColor.over
			}
		end
		-- Insert the row into the tableView
		tableView:insertRow
		{
			isCategory = isCategory,
			rowHeight = rowHeight,
			rowColor = rowColor,
			lineColor = tableViewColors.lineColor,
			params = { defaultLabelColor=tableViewColors.defaultLabelColor, catLabelColor=tableViewColors.catLabelColor }
		}
	end
end

scene:addEventListener( "create" )

return scene