-- it's not written from scratch
local json = require("json")
local dumpdata = require("dumpdata")

local M = { }

local consumer_key = "39vae4ed387o9dm"
local consumer_secret = "lr2sh0nlhu0nf4q"
local redirect_uri = "https://www.google.com/"

local callback = nil

M.err_none = nil
M.err_network = 1
M.err_getaccesstoken = 2
M.err_downloadfile = 3
M.err_uploadfile = 4
M.err_atexpired = 5

M.accessToken = "69U0GmyoppAAAAAAAAAmSesdmzkruMcoFwGRD_AYjuuoH28y_eZ2cNRJttlmE3-n"

local function urldecode(url)
    if nil == url then
        return
    end

    local function decode(s)
        return s:gsub('+', ' '):gsub('%%(%x%x)', function(hex) return string.char(tonumber(hex, 16)) end)
    end

    local res = { }
    url = url:match '?(.*)$'

    if nil == url then
        return
    end

    for name, value in url:gmatch '([^&=]+)=([^&=]+)' do
        value = decode(value)
        local key = name:match '%[([^&=]*)%]$'
        if key then
            name, key = decode(name:match '^[^[]+'), decode(key)
            if type(res[name]) ~= 'table' then
                res[name] = { }
            end
            if key == '' then
                key = #res[name] + 1
            else
                key = tonumber(key) or key
            end
            res[name][key] = value
        else
            name = decode(name)
            res[name] = value
        end
    end

    return res
end

function M.getAccessToken(cb)
    callback = cb

    local url = "https://www.dropbox.com/oauth2/authorize?" ..
    "client_id=" .. consumer_key ..
    "&response_type=code" ..
    "&redirect_uri=" .. redirect_uri

    native.showWebPopup(
    0,
    0,
    display.contentWidth,
    display.contentHeight,
    url,
    {
        urlRequest = function(event)
            print(dumpdata:dump(event, true))

            local ret = true

            local url = event.url

            local prms = urldecode(url)

            print(dumpdata:dump(prms, true))

            if nil ~= prms and
                nil ~= prms.code then
                local url = "https://api.dropbox.com/oauth2/token?" ..
                "code=" .. prms.code ..
                "&grant_type=authorization_code" ..
                "&client_id=" .. consumer_key ..
                "&client_secret=" .. consumer_secret ..
                "&redirect_uri=" .. redirect_uri

                network.request(
                url,
                "POST",
                function(event)
                    print(".." .. event.response)

                    if event.isError then
                        print("network error:", event.status, event.response)

                        if nil ~= callback then
                            callback(M.err_network)
                        end
                    else
                        print("dropbox response:", event.status, event.response)

                        if 200 == event.status then
                            local res = json.decode(event.response)

                            print("access_token=" .. res.access_token)
                            print("token_type=" .. res.token_type)
                            print("account_id=" .. res.account_id)
                            print("uid=" .. res.uid)

                            M.accessToken = res.access_token

                            if nil ~= callback then
                                callback(M.err_none)
                            end
                        else
                            if nil ~= callback then
                                callback(M.err_getaccesstoken)
                            end
                        end
                    end
                end
                )

                ret = false
            end

            return ret
        end,
    }
    )
end

-- TODO:Nick: unfinished - me needly AFK on 3 hours  (car driving) 
-- not tested 
function M.listingOfDirectory(filename, cb)
    if nil == M.accessToken then
        return
    end

    callback = cb

    local url = "https://content.dropboxapi.com/2/files/download"
    local params = { }
    local headers = { }
    local data = "{\"path\": \"\"}"

    headers["Authorization"] = "Bearer " .. M.accessToken
    headers["Dropbox-API-Arg"] = "{\"path\": \"/" .. filename .. "\", \"mode\": \"overwrite\"}"
    headers["Content-Type"] = "application/json"

    params.headers = headers
    params.data = data
end

function M.downloadFile(filename, cb)
	if nil == M.accessToken then
		return
	end

	callback = cb

    local	url = "https://content.dropboxapi.com/2/files/download"

	local	params = {headers={}}
				
	params.headers["Authorization"] = "Bearer "..M.accessToken
	params.headers["Dropbox-API-Arg"] = "{\"path\": \"/"..filename.."\"}"

	network.download(
		url,
		"POST",
		function(event)
			print(dumpdata:dump(event, true))
			if event.isError then
				print("network error:", event.status, event.response)

				if nil ~= callback then
					callback(M.err_network)
				end
			else
				print("dropbox response:", event.status, dumpdata:dump(event.response, true))

				if nil ~= callback then
					if 200 == event.status then
						callback(M.err_none)
					elseif 401 == event.status then
						callback(M.err_atexpired)
					else
						callback(M.err_downloadfile)
					end
				end
			end
		end,
		params,
		filename)
end

function M.uploadFile(filename, dir, cb)
    if nil == M.accessToken then
        return
    end

    callback = cb

    local url = "https://content.dropboxapi.com/2/files/upload"

    local params = { headers = { } }

    params.headers["Authorization"] = "Bearer " .. M.accessToken
    params.headers["Dropbox-API-Arg"] = "{\"path\": \"/" .. filename .. "\", \"mode\": \"overwrite\"}"
    params.headers["Content-Type"] = "application/octet-stream"
    params.bodyType = "binary"
    params.body = {
        filename = filename,
        baseDirectory = dir,
    }

    network.request(
    url,
    "POST",
    function(event)
        if event.isError then
            print("network error:", event.status, event.response)

            if nil ~= callback then
                callback(M.err_network)
            end
        else
            print("dropbox response:", event.status, event.response)

            if nil ~= callback then
                if 200 == event.status then
                    callback(M.err_none)
                elseif 401 == event.status then
                    callback(M.err_atexpired)
                else
                    callback(M.err_uploadfile)
                end
            end
        end
    end ,
    params)
end

return M

