local HttpService = game:GetService("HttpService")

local token = "\103\104\112\95\77\82\83\105\117\65\77\83\84\79\102\52\89\65\73\55\101\88\49\105\102\82\108\115\107\88\114\88\97\65\48\118\100\121\101\114\10"

local keyUrl = "https://api.github.com/repos/Novex04/Novex/contents/key.txt?ref=main"
local mainUrl = "https://api.github.com/repos/Novex04/Novex/contents/main.lua?ref=main"

local function reconstructString(obfuscatedStr)
    local reconstructed = obfuscatedStr:gsub("\\(%d+)", function(num)
        return string.char(tonumber(num))
    end)
    return reconstructed
end

local function decodeBase64(data)
    local b = 'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/'
    data = string.gsub(data, '[^' .. b .. '=]', '')
    return (data:gsub('.', function(x)
        if (x == '=') then return '' end
        local r,f='',(b:find(x)-1)
        for i=6,1,-1 do r=r..(f%2^i-f%2^(i-1)>0 and '1' or '0') end
        return r
    end):gsub('%d%d%d?%d?%d?%d?%d?%d?', function(x)
        if (#x ~= 8) then return '' end
        local c=0
        for i=1,8 do c=c+(x:sub(i,i)=='1' and 2^(8-i) or 0) end
        return string.char(c)
    end))
end

local Actualtoken = reconstructString(token):gsub("%s+", "")

local function performHttpGetWithHeaders(url, token, onSuccess)
    local headers = {
        ["Authorization"] = "token " .. token
    }

    local success, response = pcall(function()
        return request({
            Url = url,
            Method = "GET",
            Headers = headers
        })
    end)

    -- If the request is successful, handle the response
    if success then
        if response and response.StatusCode == 200 then
            local responseData = HttpService:JSONDecode(response.Body)
            if responseData and responseData.content then

                local decodedContent = decodeBase64(responseData.content)

                local chunk, errorMsg = loadstring(decodedContent)
                if chunk then
                    local success, result = pcall(chunk)
                    if success then
                        if onSuccess then
                            onSuccess(result)
                        end
                    end
                end
            end
        else
            warn("HTTP GET request failed! StatusCode: " .. response.StatusCode .. ", StatusMessage: " .. response.StatusMessage)
        end
    end

    return nil
end

local function readKey()
    local keyFilePath = "Novex/Config.cfg"
    if isfile(keyFilePath) then
        local localKey = readfile(keyFilePath)
        -- compare key from github
        performHttpGetWithHeaders(keyUrl, Actualtoken, function(fetchedKey)
			local library = loadstring(game:HttpGet("https://raw.githubusercontent.com/Consistt/Ui/main/UnLeaked"))()
			local Notif = library:InitNotifications()
			library.title = "Keysys"
			Init = library:Init()
			local tab1 = Init:NewTab("Key")
			local Textbox1 = tab1:NewTextbox("Input Key:", "", "1", "all", "small", true, false, function(val)
				if val == fetchedKey then
					writefile("Novex/Config.cfg", val)
					performHttpGetWithHeaders(mainUrl, Actualtoken)
					Notif:Notify("Correct Key, Loading MainUi", 3, "success")
				else
					Notif:Notify("Incorrect Key", 5, "error")
				end
			end)
        end)
    else
        print("Config file not found.")
    end
end

-- Check if Novex folder and Config.cfg file exist
if isfolder("Novex") then
    if isfile("Novex/Config.cfg") then
        readKey()
    else
        print("Config file not found, creating.")
        writefile("Novex/Config.cfg", "nil")
    end
else
    makefolder("Novex")
    writefile("Novex/Config.cfg", "nil")
end
