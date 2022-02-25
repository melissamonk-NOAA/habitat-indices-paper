--Script to get the tables needed to develop the indices of abundance for drift level data
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
	      Location_Error is null --no location errors
	  and DISTRICT>2 --north of Conception only
--24,481
------------------------------------
--Effort
USE CDFW_CPFV_Onboard_1999_2011;
SELECT					--Select statement calls the columns to output 
  cast(LOCATION.ASSN as varchar(50)) ASSN,				--Trip number
  LOCATION.LOCNUM,				--Drift within a trip
  TRPDATE,
  year(TRPDATE)          as YEAR,  -- year of the drift
  month(TRPDATE)         as MONTH, -- month of the drift
  BOAT.CNTY,            --County
  DISTRICT,             --District
  OBSANG,               --Number of observed anglers on the drift
  FISHTIME,				--Minutes fished
  MINDEPTH as DEPTH1,
  MAXDEPTH as DEPTH2,
  LOCATION.REEFID_orig,   -- The reef ID at the finest scale.  You can add other columns here, but this has to be used if including southern CA  
  ReefDist,               -- Drift starting location distance from a reef in meters
  START2mDEPTH,
  START90mDEPTH,
  SLAT as StartLatitudeDD,
  SLON as StartLongitudeDD,
  START_LOC,
  'CDFW_1999_2011' as DBASE
INTO Monk_Index_Manuscript.dbo.DriftEffort
FROM  CDFW_CPFV_Onboard_1999_2011.dbo.LOCATION 
	INNER JOIN CDFW_CPFV_Onboard_1999_2011.dbo.BOAT    on LOCATION.ASSN = BOAT.assn
    INNER JOIN CDFW_CPFV_Onboard_1999_2011.dbo.luPort  on BOAT.cnty = luPort.cnty and BOAT.intsite = luPort.intsite
   
WHERE  EXISTS (SELECT 1 --makes sure that there is at least one drift with catch
	           FROM Catches
		       WHERE LOCATION.ASSN = Catches.ASSN and LOCATION.LOCNUM = Catches.LOCNUM) 
      and DISTRICT>2 --north of Conception only
--6,741

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
	and DistrictID>2
	order by NODC
--8,775


----------------------------------------------------------------------------------------------------


------------------------------------
--Effort
------------------------------------
USE CDFW_CPFV_Onboard_2012_2014;
INSERT INTO Monk_Index_Manuscript.dbo.DriftEffort
SELECT	
  SITE.EventID AS ASSN,				
  SiteLocation.StopNum as LOCNUM,				
  TripDepartDate as TRPDATE,
  year(TripDepartDate) as YEAR,			 
  month(TripDepartDate) as MONTH,	
  CntyNum as CNTY,           
  RecFinSurveyEvent.DistrictID as DISTRICT,             
  NumAnglers AS OBSANG,             
  FISHTIME,				
  ArriveDepthMean as DEPTH1,
  LeaveDepthMean as DEPTH2,
  REEFID_orig,     
  ReefDist,             
  START2mDEPTH,
  START90mDEPTH,
  ArriveLatitude as StartLatitudeDD,
  ArriveLongitude as StartLongitudeDD,
  START_LOC,
  'CDFW_2012_2014' as DBASE
FROM CDFW_CPFV_Onboard_2012_2014.dbo.PCO_Site
          INNER JOIN CDFW_CPFV_Onboard_2012_2014.dbo.PCO_Header	on Site.EventID = PCO_Site.EventID 
		  INNER JOIN CDFW_CPFV_Onboard_2012_2014.dbo.luPORT				on PCO_Site.PortID = luPort.PortID

WHERE START_LOC is not null
    and BAY_START is null --exclude bays
    and RECFINSURVEYEVENT.DistrictID>2 --north of Conception only	
--3,054

-------------------------------------------------------------------------------------------------------------------
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
	    location_error is null				            
	and DISTRICT>2
	and Bay_start is NULL
	and Catch_error is null --a number of entries with no encounters

--1,903

------------------------------------
--Effort
------------------------------------
USE CDFW_CPFV_Onboard_2015_on;
INSERT INTO Monk_Index_Manuscript.dbo.DriftEffort
SELECT
		cast(PCO_Site.RefNum as varchar(50)) AS ASSN,       
		cast(PCO_Site.StopNum as bigint) AS LOCNUM,		
		SurveyDate as TRPDATE,
		year(SurveyDate) as YEAR,			
        month(SurveyDate) as MONTH,			
		CNTY,						 
		DISTRICT, 
        NumAnglers AS OBSANG,					 
        FISHTIME,								
        StartDepthMean as DEPTH1,
        EndDepthMean as DEPTH2,    
        REEFID_orig,    
        ReefDist,
		START2mDEPTH,
        START90mDEPTH,
     	StartLatitudeasDecimal as StartLatitudeDD,
		StartLongitudeasDecimal as StartLongitudeDD,
		START_LOC,
		'CDFW_2015_2019' as DBASE
FROM CDFW_CPFV_Onboard_2015_on.dbo.PCO_Site 
		INNER JOIN CDFW_CPFV_Onboard_2015_on.dbo.PCO_Header on PCO_Site.RefNum = PCO_Header.RefNum    	 
WHERE location_error is null				            
	 and DISTRICT>2
	 and Bay_start is NULL
--735

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
WHERE Location_Error is null --no location errors
	  and BAY_START is null --exclude bays
	  and common is not null
--26,882


------------------------------------
--Effort
------------------------------------
USE CalPoly_CPFV_Onboard;
INSERT INTO Monk_Index_Manuscript.dbo.DriftEffort
SELECT  
		CONCAT('CP_', BOAT.TRIP_ID) as ASSN,	
		LOCATION.DROP_ID as LOCNUM,
		TRPDATE,							
		year(TRPDATE) as YEAR,				
		month(TRPDATE) as MONTH,
		CNTY,								
		DISTRICT,
		OBSANG,
		FISHTIME,
		SDEPTH_FT as DEPTH1,
		NULL as DEPTH2,
	    REEFID_orig,    
        ReefDist,
		START2mDEPTH,
        START90mDEPTH,
     	SLAT as StartLatitudeDD,
		SLON as StartLongitudeDD,
		START_LOC,							
		'CAL_POLY' AS DBASE
FROM 
	 LOCATION 
		INNER JOIN BOAT ON BOAT.TRIP_ID=LOCATION.TRIP_ID
WHERE Location_error is null				            
	  and Bay_start is NULL
--7,067	
-------------------------------------------------------------------------------------------------------------------


----------------------------------------------------------------------------------------------------


-- Add in the geography data type for the start location
--ALTER TABLE Monk_Index_Manuscript.dbo.DriftEffort ADD START_LOC geography
--	UPDATE temp_table 
--		SET START_LOC = 
--  geography:: STGeomFromText('POINT(' + CAST(CAST(SLON AS decimal(13, 8)) AS varchar) +
-- ' '  + CAST(CAST(SLAT AS decimal(13, 8)) AS varchar) + ')', 4269)


--Add in identity column so ArcGIS can read the data
ALTER TABLE Monk_Index_Manuscript.dbo.DriftEffort ADD RowID int IDENTITY(1, 1);


