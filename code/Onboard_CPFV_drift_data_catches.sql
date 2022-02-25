--CATCHES
--Script to get the tables of CATCH needed to develop the indices of abundance for drift level data
--Will be script for each database
---- One table for catches and one for effort - merge together in R

--CDFW_CPFV_Onboard_1999_2011
------------------------------------
--Catch
USE CDFW_CPFV_Onboard_1999_2011;
SELECT
		cast(BOAT.ASSN as varchar(50)) as ASSN,
		CATCHES.LOCNUM,
		CDFW_CPFV_Onboard_1999_2011.dbo.luSPECIES.SP_CODE as NODC, 
		KEPT, 
		DISCD,
		'CDFW_1999_2011' as DBASE
INTO Monk_Index_Manuscript.dbo.DriftCatch
FROM CDFW_CPFV_Onboard_1999_2011.dbo.CATCHES 
	INNER JOIN CDFW_CPFV_Onboard_1999_2011.dbo.BOAT     on CATCHES.ASSN = BOAT.ASSN
	INNER JOIN CDFW_CPFV_Onboard_1999_2011.dbo.LOCATION on LOCATION.ASSN = CATCHES.ASSN and LOCATION.LOCNUM = CATCHES.LOCNUM
	INNER JOIN CDFW_CPFV_Onboard_1999_2011.dbo.luPORT   on luPORT.CNTY = BOAT.CNTY and luPORT.INTSITE = BOAT.INTSITE
    INNER JOIN luSpecies on luSpecies.RECFINSP = CATCHES.RECFINSP
WHERE 
 LocationTableError is null or LocationTableError = 2 --no location errors

--24,481

----------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------
--CDFW_CPFV_Onboard_2012_2014
------------------------------------
--Catch
------------------------------------
USE CDFW_CPFV_Onboard_2012_2014;
INSERT INTO Monk_Index_Manuscript.dbo.DriftCatch
SELECT SiteFishCatch.EventID AS ASSN, 
	  SiteFishCatch.StopNum as LOCNUM,
	  NODC, 
	  KEPT,
	  DISCD,
	  'CDFW_2012_2014' as DBASE
FROM 
	 	CDFW_CPFV_Onboard_2012_2014.dbo.SiteFishCatch
		    INNER JOIN luspecies	on SiteFishCatch.SpeciesID = luSpecies.speciesID	
			INNER JOIN SiteLocation on SiteFishCatch.SiteID=SiteLocation.SiteID and SiteFishCatch.StopNum=SiteLocation.StopNum
			INNER JOIN RecFinSurveyEvent on RecFinSurveyEvent.EventID=SiteLocation.EventID
WHERE  CATCH_ERROR IS NULL
	and SiteFishCatch.SpeciesID is not null and SiteFishCatch.SpeciesID != 450  --450 = no catch
	and  (LocationTableError is null or LocationTableError = 2 )
--8,775
----------------------------------------------------------------------------------------------------
--------------------------------
--CDFW_CPFV_Onboard_2015_on

------------------------------------
--Catch
------------------------------------
USE CDFW_CPFV_Onboard_2015_on;
INSERT INTO Monk_Index_Manuscript.dbo.DriftCatch
SELECT  PCO_SiteCatch.RefNum AS ASSN, 
        PCO_SiteCatch.StopNum as LOCNUM,
		NODC,
		KEPT, 
		DISCD,
		'CDFW_2015_2019' as DBASE
FROM
	 CDFW_CPFV_Onboard_2015_on.dbo.PCO_SiteCatch	
		LEFT JOIN CDFW_CPFV_Onboard_2015_on.dbo.luspecies	  on PCO_SiteCatch.Species = luSpecies.SpeciesAbbrv	
		INNER JOIN PCO_Site                           on PCO_Site.RefNum=PCO_SiteCatch.RefNum and PCO_Site.StopNum=PCO_SiteCatch.Stopnum
		INNER JOIN CDFW_CPFV_Onboard_2015_on.dbo.PCO_Header on PCO_Site.RefNum = PCO_Header.RefNum
WHERE
  (LocationTableError is null or LocationTableError = 2)
	and Catch_error is null --a number of entries with no encounters

--1,903



-------------------------------------------------------------------------------------------------------------------
--CalPoly_CPFV_Onboard

------------------------------------
--Catch
------------------------------------
USE CalPoly_CPFV_Onboard;
INSERT INTO Monk_Index_Manuscript.dbo.DriftCatch
SELECT  CONCAT('CP_', BOAT.TRIP_ID) as ASSN,
        LOCATION.DROP_ID as LOCNUM,
		NODC,
		KEPT, 
		DISCD,
		'CAL_POLY' AS DBASE
FROM CATCHES
		INNER JOIN BOAT      on catches.TRIP_ID=boat.TRIP_ID
		INNER JOIN LOCATION  on LOCATION.TRIP_ID=CATCHES.TRIP_ID and LOCATION.DROP_ID=CATCHES.DROP_ID
		INNER JOIN luSpecies on luSpecies.CDFGSP=CATCHES.CDFGSP
WHERE 
 (LocationTableError is null or LocationTableError = 2 )
	  and common is not null
--26,882



--Add in identity column so ArcGIS can read the data
ALTER TABLE Monk_Index_Manuscript.dbo.DriftEffort ADD RowID int IDENTITY(1, 1);


