--[[----------------------------------------------------------------------------

 Automatically Tag Photos using Google Vision API
 Copyright 2017 Tapani Otala

--------------------------------------------------------------------------------

Info.lua
Summary information for the plug-in.

Adds menu items to Lightroom.

------------------------------------------------------------------------------]]

return {
	
	LrSdkVersion = 5.0,
	LrSdkMinimumVersion = 5.0, -- minimum SDK version required by this plug-in

	LrToolkitIdentifier = "com.nitecoder.lightroom.robotagger",

	LrPluginName = LOC( "$$$/RoboTagger/PluginName=RoboTagger" ),
	LrPluginInfoUrl = "https://github.com/nitecoder/lr-robotagger",
	LrPluginInfoProvider = "RoboTaggerInfoProvider.lua",

	LrInitPlugin = "RoboTaggerInit.lua",
	LrShutdownPlugin = "RoboTaggerShutdown.lua",
	
	-- Add the menu item to the File menu.
	
	LrExportMenuItems = {
		{
			title = LOC( "$$$/RoboTagger/LibraryMenuItem=Tag Photos with Google Vision" ),
			file = "RoboTaggerMenuItem.lua",
			enabledWhen = "photosSelected",
		},
	},

	-- Add the menu item to the Library menu.
	
	LrLibraryMenuItems = {
		{
			title = LOC( "$$$/RoboTagger/LibraryMenuItem=Tag Photos with Google Vision" ),
			file = "RoboTaggerMenuItem.lua",
			enabledWhen = "photosSelected",
		},
		{
			title = LOC( "$$$/RoboTagger/LibraryMenuItem=Tag Photos with Microsoft Vision" ),
			file = "MSVisionMenuItem.lua",
			enabledWhen = "photosSelected",
		},
	},

	VERSION = { major = 1, minor = 0, revision = 0, build = 2, },

}
