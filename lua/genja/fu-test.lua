
local strip_test = {

	['65'] = '65.2023.1080p.Cam.X264.Will1869/',
	['lantana-atlas47'] = 'Lantana[2001]DVDrip[Eng]H.264[AC3 6ch]-Atlas47/',

	["riddick"] = "Riddick.Unrated.DC.2013.1080p.WEB-DL.H264-PHD/",
	["critical"] = "Critical.S01.720p.HDTV.x264-FaiLED/",
	["jwf"] = "jwf",
	["daddy's home"] = "Daddy's Home (2015) 720p BRRip HQ AC3 DD5.1 (Externe Subs)/",
	['dallas buyers club'] = "Dallas.Buyers.Club.2013.720p.BluRay.x264-x0r/",
	["dune drifter"] = "Dune.Drifter.2020.1080p.WEBRip.DD5.1.X.264-EVO/",
	["eastern promises"] = "Eastern.Promises.2007.1080p.HDDVD.DTS.x264-DEFiNiTE [NORAR]/",
	["ed wood"] = "Ed.Wood.1994.1080p.BluRay.X264-AMIABLE [NORAR]/",
	["encanto"] = "Encanto.2021.1080p.WEB-DL.H264.DDP5.1-EVO/",
	["mr brooks"] = "Mr.Brooks.2007.720p.BluRay.x264-x0r/",
	["mute"] = "Mute.2018.720p.HDRip.X264.AC3-EVO/",
	["nausicaa of the valley of the wind"] = "Nausicaa.Of.The.Valley.Of.The.Wind.1984.720p.BRRip.x264-x0r/",
	["network"] = "Network.1976.720p.BRRip.x264-x0r/",
	["once were warriors"] = "Once.Were.Warriors.1994.1080pBRRip.x264.AC3-m2g/",
	["paul blart mall cop"] = "Paul.Blart.Mall.Cop.2009.720p.BluRay.DD5.1.x264-ChaoS/",
	["perfume the story of a murderer"] = "Perfume.The.Story.of.a.Murderer.2006.720p.BluRay.x264-x0r/",
	["leaving las vegas"] = "Leaving.Las.Vegas.1995.iNTERNAL.DVDRip.x264-REGRET/",
	["finding neverland"] = "Finding.Neverland.2004.720.BRRip.x264-x0r/",
	["strings"] = "Strings.2021.1080p.WEB-DL.DD5.1.H.264-CMRG/",
	["super 8"] = "Super.8.2011.720.BluRay.x264-x0r/",
	["the social network"] = "The Social Network 2010 1080p BluRay DTS-HD MA 5.1 x264-BluEvo/",
	["dancer in the dark"] = "Dancer.in.the.Dark.2000.720p.BluRay.X264-AMIABLE/",
	["dave chappelle the closer"] = "Dave.Chappelle.The.Closer.2021.1080p.WEB.H264-NAISU/",
	["detachment"] = "Detachment.2011.480p.BRRip.XviD.AC3-Voltage/",
	["er ist wieder da"] = "Er.Ist.Wieder.Da.2015.PROPER.720p.BluRay.x264-USURY/",
	["eurovision song contest the story of fire saga"] =
	"Eurovision.Song.Contest.The.Story.of.Fire.Saga.2020.HDRip.XviD.AC3-EVO/",
	["everything everywhere all at once"] = "Everything.Everywhere.All.At.Once.2022.1080p.BRRip.DD5.1.X.264-EVO/",
	["fight club"] = "Fight.Club.1999.REMASTERED.1080p.BluRay.x264-WLM/",
	["flesh and blood"] = "Flesh and Blood 2017.HDRip.XviD.AC3-EVO/",
	["four lions"] = "Four.Lions.2010.R1.NTSC.DVDR-CME/",
	["heneral luna"] = "Heneral.Luna.2015.HC.720p.WEB-DL.AVC-PN/",
	["i dont feel at home in this world anymore"] =
	"I.Dont.Feel.at.Home.in.This.World.Anymore.2017.HDRip.x264.AC3-Manning/",
	["antz"] = "Antz.1998.DVDrip.x264.Dolby.Digital.5.1-MCH.mkv",
	["a man for all seasons"] = "A.Man.for.All.Seasons.1966.480p.BluRay.x264-mSD/",
	["the handmaiden"] = 'The.Handmaiden.2016.LIMITED.EXTENDED.720p.BluRay.x264-USURY/',
}

for i, e in pairs(strip_test) do
	if not (i == StripSceneTags(e)) then
		print('want «' .. i .. '»' .. ' got «' .. StripSceneTags(e) .. '»' .. '   -- ' .. e)
	end
end
