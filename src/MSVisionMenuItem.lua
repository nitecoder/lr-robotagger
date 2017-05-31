--[[----------------------------------------------------------------------------

 RoboTagger
 Copyright 2017 Tapani Otala

--------------------------------------------------------------------------------

MSVisionMenuItem.lua

------------------------------------------------------------------------------]]

local LrApplication = import "LrApplication"
local LrFunctionContext = import "LrFunctionContext"
local LrProgressScope = import "LrProgressScope"
local LrDialogs = import "LrDialogs"
local LrPrefs = import "LrPrefs"
local LrTasks = import "LrTasks"

require "MSVisionAPI"


local prefs = LrPrefs.prefsForPlugin()

-- local LrLogger = import 'LrLogger'
-- local myLogger = LrLogger('MSVisionRoboTagger')
-- myLogger:enable( "logfile" ) -- "print" or "logfile" 


local function task_should_end(progressScope)
	return progressScope:isCanceled() or progressScope:isDone()
end
	

local function MSTagger()
	LrFunctionContext.postAsyncTaskWithContext( "analyzing photos",
		function( context )
			logger:tracef( "MSVisionMenuItem: enter" )
			LrDialogs.attachErrorDialogToFunctionContext( context )
			
			-- Get access to catalog and photos
			local catalog = LrApplication.activeCatalog()
			local photos = catalog:getTargetPhotos()
			
			-- Progress support
			local progressScope = LrProgressScope {
				title = LOC( "$$$/RoboTagger/ProgressScopeTitle=Analyzing Photos" ),
				functionContext = context
			}
			progressScope:setCancelable( true )
			logger:tracef( "t2" )

			-- Enumerate through all selected photos in the catalog
			local runningTasks = 0
			local thumbnailRequests = { }
			
			logger:tracef( "begin analyzing %d photos", #photos )
			for i, photo in ipairs( photos ) do
				-- Limit concurrent processing
				while ( runningTasks >= prefs.maxTasks ) and not task_should_end(progressScope) do
					-- logger:tracef( "%d analysis tasks running, waiting for one to finish", runningTasks )
					LrTasks.sleep( 0.2 )
				end
				
				-- Cancel if requested
				if task_should_end(progressScope) then
					break
				end	

				runningTasks = runningTasks + 1
				local fileName = photo:getFormattedMetadata( "fileName" )
				
				progressScope:setCaption( LOC( "$$$/RoboTagger/ProgressCaption=^1 (^2 of ^3)", fileName, i, #photos ) )
				progressScope:setPortionComplete( i, #photos )				
				
				logger:tracef("Processing %s", fileName)
				
				thumbnailRequests[i] = photo:requestJpegThumbnail(prefs.thumbnailWidth, prefs.thumbnailHeight, 
					function (jpegData, errorMsg)
						if not jpegData then
							logger:error("cannot get thumbnail %i for %s: %s", i, fileName, errorMsg)
						else
							logger:tracef("Thumbnail %d for %s is size %d", i, fileName, #jpegData)
							local result = MSVisionAPI.analyze(fileName, jpegData)
						end
						
						runningTasks = runningTasks - 1
						thumbnailRequests[i] = nil
					end
				)
					
				-- Cooperate
				LrTasks.yield()
			end

			-- Cleanup
			thumbnailRequests = nil
			
			logger:tracef( "MSVisionMenuItem: exit" )
		end
	)
end

--------------------------------------------------------------------------------
-- Begin the search
MSTagger()