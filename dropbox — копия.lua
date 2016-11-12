-- Copyright Michael Weingarden 2013.  All rights reserved.

--main works well is last known good build

--most of this was constructed based on the advice found here:
	--https://www.dropbox.com/developers/blog/20   and here:
	--https://www.dropbox.com/developers/core/api#request-token

local widget = require( "widget" )
local lfs = require "lfs"
local sockets = require("socket.url")

consumer_key = "39vae4ed387o9dm"			-- key string goes here
consumer_secret = "lr2sh0nlhu0nf4q"		-- secret string goes here
webURL = "http://www.google.com"
myFile = "1.txt"

mySigMethod = "PLAINTEXT"
access_token = ""
access_token_secret = ""
request_token = ""
request_token_secret = ""
accountInfo = ""
_W = display.contentWidth
_H = display.contentHeight

local myText = display.newText(accountInfo, 0, 5*_H/8 - 100, 400, 600, native.systemFont, 16)
myText:setTextColor(255, 255, 255)

local function loadToken( type )
	local saveData = ""
	local path = system.pathForFile( type..".txt", system.DocumentsDirectory )
	local file = io.open( path, "r" )
	if file then
		--print("Found textField file")
		saveData = file:read( "*a" )
		io.close( file )
	end
	file = nil
	return saveData
end

local function storeToken( type, data )
	local path = system.pathForFile( type..".txt", system.DocumentsDirectory )
	local file = io.open( path, "w" )
	file:write( data )
	io.close( file )
	file = nil
end

local function rawGetRequest(url, rawdata) 
	
	local function rawGetListener( event )		
		if event.isError then
			print( "Network error!", event.status, event.response)
		else
			print ( "rawGetListener RESPONSE: ", event.status,  event.response )	-- **debug
		    myText.text = "Data received.  Press Display Info to view."
		end

		-- the event.response is the requested data from Dropbox
		-- you can either process the response here or use a global variable or pass it to
		-- another function
		-- using accountInfo to either store account info or incoming text file
		accountInfo = event.response

	end

	url = url.."?"..rawdata
	local result = network.request( url, "GET", rawGetListener)
	return result
end

local function rawPostRequest(url, rawdata, callback)
      
	local function rawPostListener( event )		
		if event.isError then
			print( "Network error!", event.status, event.response)
		else
			print ( "Dropbox RESPONSE: ", event.status,  event.response )	-- **debug
		end
		if callback then
			print("calling back from rawPostRequest")	
			callback( event.isError, event.response)		-- return with response
		end
	end

	local params = {}
	local headers = {}
	print("rawdata "..rawdata)
	headers["Content-Type"] = "application/x-www-form-urlencoded" 
        params.headers = headers
        params.body = rawdata
               
	local result = network.request( url, "POST", rawPostListener, params)
    
        return result
end


local function getRequestToken( consumer_key, token_ready_url, request_token_url,
	consumer_secret, callback )
    
    local post_data="code=69U0GmyoppAAAAAAAAAlttGWbPLDAbiq3IJFYUMQgTs".."&grant_type=authorization_code&client_id="..consumer_key.."&client_secret="..consumer_secret
    return rawPostRequest(request_token_url, post_data, callback)    
end


local function getAccessToken(token, token_secret, consumer_key, consumer_secret,
	access_token_url, callback)
    --Authorization: OAuth oauth_version="1.0", oauth_signature_method="PLAINTEXT", oauth_consumer_key="<app-key>", oauth_token="<request-token>", oauth_signature="<app-secret>&<request-token-secret>"
    local post_data =  "oauth_version=\"1.0\", oauth_signature_method=\""..mySigMethod.."\", oauth_consumer_key=\""..consumer_key.."\", oauth_token=\""..token.."\", oauth_signature=\""..consumer_secret.."&"..token_secret.."\"" 
  
    return rawPostRequest(access_token_url, post_data, callback)
end




local function responseToTable(str, delimiters)

	local obj = {}

	while str:find(delimiters[1]) ~= nil do
		if #delimiters > 1 then
			local key_index = 1
			local val_index = str:find(delimiters[1])
			local key = str:sub(key_index, val_index - 1)
	
			str = str:sub((val_index + delimiters[1]:len()))
	
			local end_index
			local value
	
			if str:find(delimiters[2]) == nil then
				end_index = str:len()
				value = str
			else
				end_index = str:find(delimiters[2])
				value = str:sub(1, (end_index - 1))
				str = str:sub((end_index + delimiters[2]:len()), str:len())
			end
			obj[key] = value
			--print(key .. ":" .. value)		-- **debug
		else
	
			local val_index = str:find(delimiters[1])
			str = str:sub((val_index + delimiters[1]:len()))
	
			local end_index
			local value
	
			if str:find(delimiters[1]) == nil then
				end_index = str:len()
				value = str
			else
				end_index = str:find(delimiters[1])
				value = str:sub(1, (end_index - 1))
				str = str:sub(end_index, str:len())
			end
			
			obj[#obj + 1] = value

		end
	end
	
	return obj
end



local function authorizeDropbox(event)

	local remain_open = true

	print("event.url: "..event.url)
	print("webURL: "..webURL)
	print("authorizeDropbox: ", event.url)
	local callbackURL = true
	local url = event.url

	if url:find("callback") then
		callbackURL = true
	else
		callbackURL = false
	end

	if url:find("oauth_token") and not callbackURL then
		remain_open = false

		function getAccess_ret( status, access_response )
			print("getAccess_ret")
			print("access_response: "..access_response)
					
			access_response = responseToTable( access_response, {"=", "&"} )
			access_token = access_response.oauth_token
			access_token_secret = access_response.oauth_token_secret
			user_id = access_response.user_id
			screen_name = access_response.screen_name
			storeToken( "access_token", access_token )
			storeToken( "access_token_secret", access_token_secret )
		end

		print("getAccess")
		getAccessToken(request_token, request_token_secret, consumer_key, 
			 consumer_secret, "https://api.dropbox.com/1/oauth/access_token", getAccess_ret )

	end

	return remain_open
end


local function requestToken_ret( status, result )

	print("requestToken_ret")
	print("result: "..result)
        
	request_token = result:match('oauth_token=([^&]+)')
	request_token_secret = result:match('oauth_token_secret=([^&]+)')

	print("request_token_secret: "..request_token_secret)

	-- Displays a webpopup to access the Twitter site so user can sign in
	-- urlRequest dictates whether the WebPopup will remain open or not
	native.showWebPopup(0, 0, 320, 480, "https://www.dropbox.com/1/oauth/authorize?oauth_token="
		.. request_token.."&oauth_callback="..webURL, {urlRequest = authorizeDropbox})
end


local function connect( event )
    
    --getRequestToken( consumer_key, token_ready_url, request_token_url,
--	consumer_secret, callback )
    
         local urlNew = "https://api.dropboxapi.com/oauth2/token"   
	local dropbox_request = (getRequestToken(consumer_key, webURL,
		urlNew, consumer_secret, requestToken_ret))          
                
end


local function AuthNEW()
    native.showWebPopup(0, 0, display.contentWidth, display.contentHeight, "https://www.dropbox.com/oauth2/authorize?response_type=code&client_id="..consumer_key) 
end


local function getSomething( event )

	print("pre get info request")
	--Your HTTP request should have the following form:
	--Authorization: OAuth oauth_version="1.0", oauth_signature_method="PLAINTEXT", oauth_consumer_key="<app-key>", 
	--oauth_token="<access-token>, oauth_signature="<app-secret>&<access-token-secret>"
	--formatted for GET
	local post_data =  "oauth_version=1.0&oauth_signature_method="..mySigMethod.."&oauth_consumer_key="..consumer_key.."&oauth_token="..access_token.."&oauth_signature="..consumer_secret.."%26"..access_token_secret
	--formatted for POST which doesn't seem to work for file requests
	--local post_data =  "oauth_version=\"1.0\", oauth_signature_method=\""..mySigMethod.."\", oauth_consumer_key=\""..consumer_key.."\", oauth_token=\""..access_token.."\", oauth_signature=\""..consumer_secret.."&"..access_token_secret.."\""

	--use this url if you just want account info
    --local url = "https://api.dropbox.com/1/account/info"
    --use this url if you want to download a plain text file
    local url = "https://api-content.dropbox.com/1/files/dropbox/Public/"..myFile
   
	print("post get info request")
        
       
    local result1 = rawGetRequest(url, post_data)
    print("rawGetRequest result: "..tostring(result1))
end

local function displayInfo()
	print("accountInfo: "..accountInfo)
	myText.text = accountInfo
	local path = system.pathForFile( myFile, system.DocumentsDirectory )
	local file = io.open( path, "w" )
	file:write( accountInfo )
	io.close( file )
	file = nil
end

local function putFileListener( event )
	print("putFileListener")
	if event.isError then
		print( "Network error!", event.status, event.response)
	else
		print ( "Dropbox RESPONSE: ", event.status,  event.response )	-- **debug
	end
end

local function putFile()

	--formatted for POST which doesn't seem to work for file requests
	local post_headers =  "oauth_version=\"1.0\", oauth_signature_method=\""..mySigMethod.."\", oauth_consumer_key=\""..consumer_key.."\", oauth_token=\""..access_token.."\", oauth_signature=\""..consumer_secret.."&"..access_token_secret.."\""

	--Note: Providing a Content-Length header set to the size of the uploaded file is required so that the server can verify that it has received the entire file contents.
	local path = system.pathForFile( myFile, system.DocumentsDirectory )
	local filesize = lfs.attributes (path, "size")

    --use this url if you want to upload a file file
    local url = "https://api-content.dropbox.com/1/files_put/dropbox/Public/testFromapp.txt"

	local params = {}
	local headers = {}
	headers["Content-Type"] = "text/plain"
	headers["Content-Length"] = fileSize
	headers["Authorization"] = "OAuth "..post_headers
	params.headers = headers
	-- This tells network.request() to get the request body from a file...
	params.body = {
	        filename = myFile,
	        baseDirectory = system.DocumentsDirectory        
	        }
	
	print("rawPostRequest posting")

	local result = network.request( url, "POST", putFileListener, params)

end

access_token = loadToken( "access_token" )
access_token_secret = loadToken( "access_token_secret")

-- there is no need to show the Connect button if the user has already
--		authorized Dropbox access previously
if access_token == "" then
	connectButton = widget.newButton
	{
		left = 380,
		top = _H/8 - 100,
		width = 200,
		height = 50,
		id = "button1",
		defaultFile = "smallButton.png",
		overFile = "smallButtonOver.png",
		label = "Connect",
		fontSize = 34,
		onRelease = connect
	}
	connectButton.x = _W / 2
end

getInfoButton = widget.newButton
{
	left = 380,
	top = 2*_H/8 - 100,
	width = 200,
	height = 50,
	id = "button3",
	defaultFile = "smallButton.png",
	overFile = "smallButtonOver.png",
	label = "Get Info",
	fontSize = 34,
	onRelease = getSomething
}
getInfoButton.x = display.contentWidth / 2

displayInfoButton = widget.newButton
{
	left = 380,
	top = 3*_H/8 - 100,
	width = 200,
	height = 50,
	id = "button3",
	defaultFile = "smallButton.png",
	overFile = "smallButtonOver.png",
	label = "Display Info",
	fontSize = 34,
	onRelease = displayInfo
}
displayInfoButton.x = display.contentWidth / 2

putBtn = widget.newButton
{
	left = 380,
	top = 4*_H/8 - 100,
	width = 200,
	height = 50,
	id = "button4",
	defaultFile = "smallButton.png",
	overFile = "smallButtonOver.png",
	label = "Put File",
	fontSize = 34,
	onRelease = putFile
}
putBtn.x = display.contentWidth / 2