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
mSecretCode= "69U0GmyoppAAAAAAAAAluC2-A8y5KG5rd-HK6O7sUlo"

_W = display.contentWidth
_H = display.contentHeight

local myText = display.newText(accountInfo, 0, 5*_H/8 - 100, 400, 600, native.systemFont, 16)
myText:setTextColor(255, 255, 255)


--NICK_TEST
local callback = {}

function callback.getResponse( response )
	-- Following line caused problem on Mac Corona Simulator
	print("Callback worked: ".. response)
end

--NICK_TEST


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
    
    local post_data="code="..mSecretCode.."&grant_type=authorization_code&client_id="..consumer_key.."&client_secret="..consumer_secret
    return rawPostRequest(request_token_url, post_data, callback)    
end



local function AuthNEW()
   native.showWebPopup(0, 0, display.contentWidth, display.contentHeight, "https://www.dropbox.com/oauth2/authorize?response_type=code&client_id="..consumer_key) 
end

--NICK_TEST
local delegate

local function getFileListener( event )
        if ( event.isError ) then
                print( "Network error!")
        else
                delegate.getResponse( event.response )
        end
end

local function LoadFile(path,fileName)
        print("authString: "..authString)
    local url = "https://api-content.dropbox.com/1/files/dropbox/".. path .. fileName.. "?" .. authString
    print("url: "..url)
    -- experiment, let's try replacing network request with network.download!
    -- network.request( url, "GET", getFileListener )
    network.download( url, "GET", getFileListener, fileName )
end

--NICK_TEST

local function connect( event )
    
AuthNEW()
         local urlNew = "https://api.dropboxapi.com/oauth2/token"   
	local dropbox_request = (getRequestToken(consumer_key, webURL,
		urlNew, consumer_secret, nil))          
        LoadFile("","1.txt")
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