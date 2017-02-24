-- =============================================================
-- Copyright Roaming Gamer, LLC. 2008-2017 (All Rights Reserved)
-- =============================================================
-- game.lua - Game Module
-- =============================================================
local common 		= require "scripts.common"
local factoryMgr 	= ssk.factoryMgr
local soundMgr		= ssk.soundMgr

-- =============================================================
-- Localizations
-- =============================================================
-- Commonly used Lua Functions
local getTimer          = system.getTimer
local mRand					= math.random
local mAbs					= math.abs
--
-- Common SSK Display Object Builders
local newCircle = ssk.display.newCircle;local newRect = ssk.display.newRect
local newImageRect = ssk.display.newImageRect;local newSprite = ssk.display.newSprite
local quickLayers = ssk.display.quickLayers
--
-- Common SSK Helper Modules
local easyIFC = ssk.easyIFC;local persist = ssk.persist
--
-- Common SSK Helper Functions
local isValid = display.isValid;local isInBounds = ssk.easyIFC.isInBounds
local normRot = ssk.misc.normRot;local easyAlert = ssk.misc.easyAlert
--
-- SSK 2D Math Library
local addVec = ssk.math2d.add;local subVec = ssk.math2d.sub;local diffVec = ssk.math2d.diff
local lenVec = ssk.math2d.length;local len2Vec = ssk.math2d.length2;
local normVec = ssk.math2d.normalize;local vector2Angle = ssk.math2d.vector2Angle
local angle2Vector = ssk.math2d.angle2Vector;local scaleVec = ssk.math2d.scale


local RGTiled = ssk.tiled

-- =============================================================
-- Locals
-- =============================================================
local layers

-- =============================================================
-- Module Begins
-- =============================================================
local game = {}


-- ==
--    init() - One-time initialization only.
-- ==
function game.init()

	--
	-- Mark game as not running
	--
	common.gameIsRunning = false

	--
	-- Initialize all factories
	--
	factoryMgr.init()

	-- Clear Score, Couins, Distance Counters
	common.score 		= 0
end


-- ==
--    stop() - Stop game if it is running.
-- ==
function game.stop()
 
	--
	-- Mark game as not running
	--
	common.gameIsRunning = false

end

-- ==
--    destroy() - Remove all game content.
-- ==
function game.destroy() 
	--
	-- Reset all of the factories
	--
	factoryMgr.reset( )

	-- Destroy Existing Layers
	if( layers ) then
		ignoreList( { "onGameOver" }, layers )
		display.remove( layers )
		layers = nil
	end

	-- Clear Score, Couins, Distance Counters
	common.score 		= 0
	common.coins 		= 0
	common.distance 	= 0
end


-- ==
--    start() - Start game actually running.
-- ==
function game.start( group, params )
	params = params or { debugEn = false }

	game.destroy() 

	--
	-- Mark game as running
	--
	common.gameIsRunning = true

	--
	-- Create Layers
	--
	layers = ssk.display.quickLayers( group, 
		"underlay", 
		"world", 
			{ "background", "content", "answerButtons", "foreground" },
		"interfaces" )

	--
	-- Create a background color	
	--
	newRect( layers.underlay, centerX, centerY, 
		      { w = fullw, h = fullh, fill = common.backFill1 })

	--
	-- Create HUDs
	--
	factoryMgr.new( "scoreHUD", layers.interfaces, centerX, top + 80 )
 
	--
	--
	-- Add player died listener to layers to allow it to do work if we need it
	function layers.onGameOver( self, event  )

		-- SSK2 PRO users have sound manager
		if( soundMgr ) then
			post( "onSound", { sound = "gameOver" } )
		end


		ignore( "onGameOver", self )
		game.stop()	
		--
		-- Blur the whole screen
		--
		local function startOver()
			game.start( group, params )  
		end
		ssk.misc.easyBlur( layers.interfaces, 250, common.red, 
			                { touchEn = true, onComplete = startOver } )


		-- 
		-- Show 'You Died' Message
		--
		local msg1 = easyIFC:quickLabel( layers.interfaces, "Game Over!", centerX, centerY - 50, ssk.gameFont(), 50 )
		local msg2 = easyIFC:quickLabel( layers.interfaces, "Final Score: " .. common.score, centerX, centerY + 50, ssk.gameFont(), 50 )
		easyIFC.easyFlyIn( msg1, { sox = -fullw, delay = 500, time = 750, myEasing = easing.outElastic } )
		easyIFC.easyFlyIn( msg2, { sox = fullw, delay = 500, time = 750, myEasing = easing.outElastic } )

	end; listen( "onGameOver", layers )
	--post("onGameOver")


	-- 
	-- Draw Top Bar
	--
	local tb = newRect( layers.content, centerX, top,
								{ w = fullw, h = 40, anchorY = 0, 
								  fill = common.backFill2 } )

	--
	-- Game label
	--
	local gameLabel = easyIFC:quickLabel( layers.interfaces, "001 Quiz", tb.x , tb.y + 20, ssk.gameFont(), 20 )

	--
	-- Question Count
	--
	local countLabel = easyIFC:quickLabel( layers.interfaces, "", right - 25, tb.y + 20, ssk.gameFont(), 20, common.green, 1 )

	--
	-- Question Label (not super but OK for basic quiz)
	-- 
	local currentQuestion = easyIFC:quickLabel( layers.content, "", centerX, top + 200, ssk.gameFont(), 20 )


	--
	-- Load quiz data, duplicate it, then shuffle it
	--
	local curQuestion = 1

	local quizData = require "scripts.quizData"
	
	local quiz = table.deepCopy( quizData )
	
	table.shuffle(quiz)
	
	local function showNextQuestion()

		--
		-- Update question count label
		--
		countLabel.text = "Question "  .. curQuestion .. " of " .. #quiz

		--table.print_r( quiz )

		--
		-- Show the question
		--
		currentQuestion.text = quiz[curQuestion].question

		--
		-- Destroy last answer buttons
		--
		layers:purge("answerButtons")

		--
		-- Listener for answer buttons
		--
		local function onAnswer( event )

			-- SSK2 PRO users have sound manager
			if( soundMgr ) then
				post( "onSound", { sound = "touch" } )
			end


			if( event.target.isCorrect ) then
				common.score = common.score + 1
			end

			curQuestion = curQuestion + 1
			if( curQuestion <= #quiz ) then
				showNextQuestion()
			else
				post("onGameOver")
			end
		end

		--
		-- Draw answer buttons
		--
		local curY = top + 250
		local answers = quiz[curQuestion].answers
		table.shuffle(answers)
		for i = 1, #answers do
			local tmp = easyIFC:presetPush( layers.answerButtons, "default", 
				                             centerX, curY, fullw - 60, 40,
				                             answers[i].answer,
				                             onAnswer,
				                             { labelSize = 24 } )
			tmp.isCorrect = answers[i].correct
			curY = curY + 50
		end

	end

	showNextQuestion()


end


return game



