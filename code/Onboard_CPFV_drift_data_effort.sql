--EFFORT ONLY
--Script to get the EFFORT tables needed to develop the indices of abundance for drift level data
--Will be script for each database
---- One table for catches and one for effort - merge together in R

--CDFW_CPFV_Onboard_1999_2011
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
  CAST(STIME as TIME) as StartTime,
  CAST(ETIME as TIME) as EndTime,
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
  CDFWBlockID,
  WaterArea_NMFS,
  'CDFW_1999_2011' as DBASE
INTO Monk_Index_Manuscript.dbo.DriftEffort
FROM  CDFW_CPFV_Onboard_1999_2011.dbo.LOCATION 
	INNER JOIN CDFW_CPFV_Onboard_1999_2011.dbo.BOAT    on LOCATION.ASSN = BOAT.assn
    INNER JOIN CDFW_CPFV_Onboard_1999_2011.dbo.luPort  on BOAT.cnty = luPort.cnty and BOAT.intsite = luPort.intsite
   
WHERE  (LocationTableError is null or LocationTableError = 2)
--EXISTS (SELECT 1 --makes sure that there is at least one drift with catch
--	           FROM Catches
--		       WHERE LOCATION.ASSN = Catches.ASSN and LOCATION.LOCNUM = Catches.LOCNUM) 
			   
--46,303

----------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------
--CDFW_CPFV_Onboard_2012_2014
------------------------------------
--Effort
------------------------------------
USE CDFW_CPFV_Onboard_2012_2014;
INSERT INTO Monk_Index_Manuscript.dbo.DriftEffort
SELECT	
  PCO_Site.EventID AS ASSN,				
  PCO_Site.StopNum as LOCNUM,				
  SurveyDate as TRPDATE,
  year(SurveyDate) as YEAR,			 
  month(SurveyDate) as MONTH,	
  CntyNum as CNTY,           
  PCO_Header.DistrictID as DISTRICT,             
  NumAnglers AS OBSANG,     
  CAST(ArriveSiteTime as TIME) as StartTime,
  CAST(LeaveSiteTime as TIME) as EndTime,
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
  CDFWBlockID,
  WaterArea_NMFS,
  'CDFW_2012_2014' as DBASE
FROM CDFW_CPFV_Onboard_2012_2014.dbo.PCO_Site
          INNER JOIN CDFW_CPFV_Onboard_2012_2014.dbo.PCO_Header	on PCO_Header.EventID = PCO_Site.EventID 
		  INNER JOIN CDFW_CPFV_Onboard_2012_2014.dbo.luPORT		on PCO_Header.PortID = luPort.PortID 
WHERE  LocationTableError is null or LocationTableError = 2


-------------------------------------------------------------------------------------------------------------------
--CDFW_CPFV_Onboard_2015_on
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
		CAST(StartTime as TIME),
		CAST(EndTime as TIME),
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
		CDFWBlockID,
        WaterArea_NMFS,
		'CDFW_2015_2019' as DBASE
FROM CDFW_CPFV_Onboard_2015_on.dbo.PCO_Site 
		INNER JOIN CDFW_CPFV_Onboard_2015_on.dbo.PCO_Header on PCO_Site.RefNum = PCO_Header.RefNum    	 
WHERE  LocationTableError is null or LocationTableError = 2
--21,783

-------------------------------------------------------------------------------------------------------------------
--CalPoly_CPFV_Onboard
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
		CAST(STIME as TIME) as StartTime,
		CAST(ETIME as TIME) as EndTime,
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
		CDFWBlockID,
        WaterArea_NMFS,
		'CAL_POLY' AS DBASE
FROM 
	 LOCATION 
		INNER JOIN BOAT ON BOAT.TRIP_ID=LOCATION.TRIP_ID
WHERE  LocationTableError is null or LocationTableError = 2
--7,962
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
 
 UPDATE Monk_Index_Manuscript.dbo.DriftEffort 
 SET FishTime = datediff(mi, StartTime, EndTime)

