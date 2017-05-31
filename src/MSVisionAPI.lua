--[[----------------------------------------------------------------------------

 RoboTagger
 Copyright 2017 Tapani Otala

--------------------------------------------------------------------------------

MSVisionAPI.lua
Based on https://docs.microsoft.com/en-us/azure/cognitive-services/computer-vision/quickstarts/csharp
and GoogleVisionAPI class.

------------------------------------------------------------------------------]]

local LrPrefs = import "LrPrefs"
local LrPasswords = import "LrPasswords"
local LrFileUtils = import "LrFileUtils"
local LrPathUtils = import "LrPathUtils"
local LrStringUtils = import "LrStringUtils"
local LrDate = import "LrDate"
local LrShell = import "LrShell"
local LrHttp = import "LrHttp"

--------------------------------------------------------------------------------

local JSON = require "JSON"
local inspect = require "inspect"
require "Logger"

function JSON.assert(exp, message)
	-- just log the decode error, let the decoder return nil
	logger:errorf( "JSON parse error: %s", message )
end

--------------------------------------------------------------------------------
-- MS Vision API

MSVisionAPI = { }

local httpContentType = "Content-Type"
local httpSubsciptionKey = "Ocp-Apim-Subscription-Key"
local mimeTypeOctet = "application/octet-stream"
local mimeTypeJson = "application/json"
local httpAccept = "Accept"

local urlSuffix = [[analyze?
						visualFeatures=Categories,Tags,Description,Faces,ImageType,Color&
						details=Landmarks&
						language=en
				  ]]

-- TODO: replace with params
local regionEndpoint = "https://westcentralus.api.cognitive.microsoft.com/vision/v1.0"
local subscriptionKey = "ae93c318c39440dc9d61803af9e2d3ab"

local serviceMaxRetries = 2




--------------------------------------------------------------------------------

function MSVisionAPI.analyze( fileName, jpegData, maxLabels, maxLandmarks )
	local url = regionEndpoint .. "/" .. urlSuffix

	local attempts = 0
	while attempts <= serviceMaxRetries do
		local reqHeaders = {
			{ field = httpSubsciptionKey, value = subscriptionKey },
			{ field = httpContentType, value = mimeTypeOctet },
			{ field = httpAccept, value = mimeTypeJson },
		}
		
		local resBody, resHeaders = LrHttp.post( url, jpegData, reqHeaders )
		logger:tracef( "response status: %s", resHeaders.status )
		logger:tracef( "response headers: %s", resHeaders )
		logger:tracef( "response body: %s", resBody )
		
		if resBody then
			local resJson = JSON:decode( resBody )
			if resHeaders.status == 200 then
				local results = { status = true }
				logger:tracef("MSVisionAPI: Success")
				return results
			else
				logger:errorf( "GoogleVisionAPI: analyze API failed: %s", inspect( resJson ) )
				return { status = false, message = resJson.error.message }
			end
		else
			logger:errorf( "GoogleVisionAPI: network error: %s(%d): %s", resHeaders.error.errorCode, resHeaders.error.nativeCode, resHeaders.error.name )
			return { status = false, message = resHeaders.error.name }
		end
	end
	logger:errorf( "MSVisionAPI: exceeded number of retries" )
	return { status = false, message = "Exceeded number of retries" }
end