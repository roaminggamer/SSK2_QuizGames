-- =============================================================
-- Copyright Roaming Gamer, LLC. 2008-2017 (All Rights Reserved)
-- =============================================================
-- quizData.lua - Fake quiz data.
--
-- Normally you would load this from a JSON encoded file, but for this example 
-- the questions are fixed and pre-stored in the table below.
--
-- =============================================================
local quizData = {}

--
--
--
local entry = {}
quizData[#quizData+1] = entry
entry.question = "What engine/SDK is this game written in?"
entry.answers = 
{
	{ answer = "Corona SDK", correct = true },
	{ answer = "LOVE", correct = false },
	{ answer = "Unity 3D", correct = false },
	{ answer = "Build Box", correct = false },
}

--
--
--
local entry = {}
quizData[#quizData+1] = entry
entry.question = "What scripting language does Corona SDK use?"
entry.answers = 
{
	{ answer = "Lua", correct = true },
	{ answer = "Torque Script", correct = false },
	{ answer = "Basic", correct = false },
	{ answer = "Perl", correct = false },
	{ answer = "Python", correct = false },
}


--
--
--
local entry = {}
quizData[#quizData+1] = entry
entry.question = "Where should you go to get help?"
entry.answers = 
{
	{ answer = "The Forums", correct = true },
	{ answer = "The API Docs", correct = true },
	{ answer = "The Guides", correct = true },
	{ answer = "All of these are correct.", correct = true },
}

--
--
--
local entry = {}
quizData[#quizData+1] = entry
entry.question = "What is the best plugin in the Marketplace?"
entry.answers = 
{
	{ answer = "SSK2", correct = true },
	{ answer = "SSK2", correct = true },
	{ answer = "SSK2", correct = true },
}


return quizData
