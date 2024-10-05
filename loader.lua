local HttpService = game:GetService("HttpService")

-- Obfuscated GitHub Personal Access Token
local token = "\103\104\112\95\77\82\83\105\117\65\77\83\84\79\102\52\89\65\73\55\101\88\49\105\102\82\108\115\107\88\114\88\97\65\48\118\100\121\101\114\10"

-- GitHub API URL for the file in your repo
local url = "https://api.github.com/repos/Novex04/Novex/contents/key.txt?ref=main"

-- Function to reconstruct the obfuscated string (token)
local function reconstructString(obfuscatedStr)
	local reconstructed = obfuscatedStr:gsub("\\(%d+)", function(num)
		return string.char(tonumber(num))
	end)
	return reconstructed
end

-- Base64 decoding function
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

-- Reconstruct the token and remove any extra spaces
local Actualtoken = reconstructString(token):gsub("%s+", "")

-- Function to perform the HTTP GET request with detailed error logging
local function performHttpGetWithHeaders(url, token)
	local headers = {
		["Authorization"] = "token " .. token  -- Authorization header with the token
	}

	-- Perform the HTTP request using RequestAsync with headers
	local success, response = pcall(function()
		return request({
			Url = url,
			Method = "GET",
			Headers = headers
		})
	end)
	warn(response, success)
	-- If the request is successful, handle the response
	if success then
		if response.StatusCode == 200 then
			print("statuscode 200, works, returning content")
			print(response)
			return response.content
		else
			-- Log detailed response for debugging
			warn("HTTP GET request failed! StatusCode: " .. response.StatusCode .. ", StatusMessage: " .. response.StatusMessage .. ", ResponseBody: " .. response.Body)
		end
	else
		warn("RequestAsync call itself failed: " .. tostring(response))  -- Logs the actual error returned by pcall
	end

	return nil
end

-- Perform the request to fetch the file contents
local response = performHttpGetWithHeaders(url, Actualtoken)

-- Check if a valid response was received
if response then
	-- Parse the JSON response (file contents are returned in base64)
	local responseData = HttpService:JSONDecode(response)
	if responseData and responseData.content then
		-- Decode the base64 content using the custom decodeBase64 function
		local decodedContent = decodeBase64(responseData.content)
		print("Decoded file content:\n" .. decodedContent)
		return decodedContent
	else
		warn("Failed to extract content from the response.")
	end
else
	warn("No response received.")
end
