--Script to get the tables needed to develop the indices of abundance using SM
--Will be script for each database

--CDFW_CPFV_Onboard_1999_2011
------------------------------------
--Catch
USE CDFW_CPFV_Onboard_1999_2011;
SELECT DISTINCT 
		cast(BOAT.ASSN as varchar(50)) as ASSN, 
		NODC, 
		sum(kept) as tot_kept, 
		sum(discd) as tot_discd,
		'CDFW_1999_2011' as DBASE
INTO Monk_Index_Manuscript.dbo.TripCatch
FROM CDFW_CPFV_Onboard_1999_2011.dbo.CATCHES 
	INNER JOIN CDFW_CPFV_Onboard_1999_2011.dbo.BOAT     on CATCHES.ASSN = BOAT.ASSN
	INNER JOIN CDFW_CPFV_Onboard_1999_2011.dbo.LOCATION on LOCATION.ASSN = CATCHES.ASSN and LOCATION.LOCNUM = CATCHES.LOCNUM
	INNER JOIN CDFW_CPFV_Onboard_1999_2011.dbo.luPORT   on luPORT.CNTY = BOAT.CNTY and luPORT.INTSITE = BOAT.INTSITE
	INNER JOIN luSpecies on luSpecies.RECFINSP = CATCHES.RECFINSP
WHERE 
	      Location_Error is null --no location errors
	  and BAY_START is null --exclude bays
	  and DISTRICT>2 --north of Conception only
GROUP BY BOAT.ASSN, NODC
--8573
------------------------------------
--Effort
USE CDFW_CPFV_Onboard_1999_2011;
SELECT DISTINCT 
		cast(BOAT.ASSN as varchar(50)) as ASSN, 
		BOAT.CNTY, 
		DISTRICT,  
		year(TRPDATE) YEAR, 
		month(TRPDATE) MONTH, 
		sum(ANGHRS) as tot_anghrs,
		'CDFW_1999_2011' as DBASE
INTO Monk_Index_Manuscript.dbo.TripEffort
FROM LOCATION 
		INNER JOIN BOAT on LOCATION.assn=boat.assn
		INNER JOIN luPORT on luPORT.CNTY = BOAT.CNTY and luPORT.INTSITE=BOAT.INTSITE
WHERE EXISTS (SELECT 1 --makes sure that there is at least one drift with catch
	          FROM Catches
			  WHERE Location.ASSN = Catches.ASSN and Location.LOCNUM = Catches.LOCNUM) 
     and Location_Error is null --no location errors
     and BAY_START is null --exclude bays
     and DISTRICT>2 --north of Conception only
GROUP BY BOAT.ASSN, BOAT.CNTY, DISTRICT, BOAT.TRPDATE
--963

-------------------------------------------------------------------------------------------------------------------

--CDFW_CPFV_Onboard_2012_2014
------------------------------------
--Catch
------------------------------------
USE CDFW_CPFV_Onboard_2012_2014;
INSERT INTO Monk_Index_Manuscript.dbo.TripCatch
select DISTINCT 
			SiteFishCatch.EventID AS ASSN, 
			NODC, 
			sum(kept) as tot_kept, 
			sum(discd) as tot_discd,
			'CDFW_2012_2014' as DBASE
FROM 
	 	CDFW_CPFV_Onboard_2012_2014.dbo.SiteFishCatch
		    INNER JOIN CDFW_CPFV_Onboard_2012_2014.dbo.luspecies	on SiteFishCatch.SpeciesID = luSpecies.speciesID	
			INNER JOIN SiteLocation on SiteFishCatch.SiteID=SiteLocation.SiteID and SiteFishCatch.StopNum=SiteLocation.StopNum
			INNER JOIN PCO_Site on PCO_Site.EventID=SiteLocation.EventID
WHERE CATCH_ERROR IS NULL
			   and NODC is not null
               and PCO_Site.DistrictID>2 --north of Conception only
GROUP BY SiteFishCatch.EventID, NODC
--3361

------------------------------------
--Effort
------------------------------------
USE CDFW_CPFV_Onboard_2012_2014;
INSERT INTO Monk_Index_Manuscript.dbo.TripEffort
SELECT DISTINCT
		S.EventID AS ASSN,           -- Trip ID number
		CntyNum as CNTY,						  -- Port of landing county
		PCO_Site.DistrictID AS DISTRICT, -- CDFW district
		year(TripDepartDate) as YEAR,			  -- Trip year
        month(TripDepartDate) as MONTH,			  -- Trip month
        sum(ANGHRS) as tot_anghrs,	
		'CDFW_2012_2014' as DBASE
FROM CDFW_CPFV_Onboard_2012_2014.dbo.SITE S
          INNER JOIN CDFW_CPFV_Onboard_2012_2014.dbo.PCO_Site	   on S.EventID = PCO_Site.EventID 
		  INNER JOIN CDFW_CPFV_Onboard_2012_2014.dbo.luPORT		   on PCO_Site.PortID = luPort.PortID
		  INNER JOIN CDFW_CPFV_Onboard_2012_2014.dbo.SiteLocation  on S.SiteID = SiteLocation.SiteID and S.StopNum=SiteLocation.StopNum

WHERE EXISTS (SELECT 1
					FROM SiteFishCatch
					where S.SiteID = SiteFishCatch.SiteID and S.StopNum = SiteFishCatch.StopNum)
	and START_LOC is not null
group by S.EventID, CntyNum, PCO_Site.DistrictID, TripDepartDate	
--384



-------------------------------------------------------------------------------------------------------------------
--CDFW_CPFV_Onboard_2015_on

------------------------------------
--Catch
------------------------------------
USE CDFW_CPFV_Onboard_2015_on;
INSERT INTO Monk_Index_Manuscript.dbo.TripCatch
SELECT DISTINCT 
		PCO_SiteCatch.RefNum AS ASSN, 
		NODC, 
		sum(kept) as tot_kept, 
		sum(discd) as tot_discd,
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
GROUP BY PCO_SiteCatch.RefNum, NODC
--793

------------------------------------
--Effort
------------------------------------
USE CDFW_CPFV_Onboard_2015_on;
INSERT INTO Monk_Index_Manuscript.dbo.TripEffort
SELECT
	    S.RefNum AS ASSN,           -- Trip ID number
		CNTY,						  -- Port of landing county
		DISTRICT, -- CDFW district	
		year(SurveyDate) as YEAR,			  -- Trip year
        month(SurveyDate) as MONTH,			  -- Trip month
        sum(ANGHRS) as tot_anghrs,
		'CDFW_2015_2019' as DBASE	
FROM CDFW_CPFV_Onboard_2015_on.dbo.PCO_Site S
		INNER JOIN CDFW_CPFV_Onboard_2015_on.dbo.PCO_Header on S.RefNum = PCO_Header.RefNum    	 
WHERE EXISTS (SELECT 1
	 		  FROM PCO_SiteCatch
			  WHERE S.RefNum = PCO_SiteCatch.RefNum and S.StopNum = PCO_SiteCatch.StopNum
				  and Catch_error is null)
	 and location_error is null				            
	 and DISTRICT>2
GROUP BY S.RefNum, CNTY, DISTRICT, SurveyDate
--96


-------------------------------------------------------------------------------------------------------------------
--CalPoly_CPFV_Onboard

------------------------------------
--Catch
------------------------------------
USE CalPoly_CPFV_Onboard;
INSERT INTO Monk_Index_Manuscript.dbo.TripCatch
SELECT DISTINCT 
		CONCAT('CP_', BOAT.TRIP_ID) as ASSN, 
		NODC, 
		sum(kept) as tot_kept, 
		sum(discd) as tot_discd,
		'CAL_POLY' AS DBASE
FROM CATCHES
		INNER JOIN BOAT      on catches.TRIP_ID=boat.TRIP_ID
		INNER JOIN LOCATION  on LOCATION.TRIP_ID=CATCHES.TRIP_ID and LOCATION.DROP_ID=CATCHES.DROP_ID
		INNER JOIN luSpecies on luSpecies.CDFGSP=CATCHES.CDFGSP
WHERE Location_Error is null --no location error
GROUP BY BOAT.TRIP_ID, NODC
--7886

------------------------------------
--Effort
------------------------------------
USE CalPoly_CPFV_Onboard;
INSERT INTO Monk_Index_Manuscript.dbo.TripEffort
SELECT  
		CONCAT('CP_', LOCATION.TRIP_ID) as ASSN,			--- Trip number
		CNTY,								--- County
		DISTRICT,							--- CRFS district
		year(TRPDATE) as YEAR,				--- Trip year
		month(TRPDATE) as MONTH,            --- Trip month
		sum(ANGHRS) as tot_anghrs,		    --- Calculated angler hours
		'CAL_POLY' AS DBASE
FROM 
	 LOCATION 
		INNER JOIN BOAT ON BOAT.TRIP_ID=LOCATION.TRIP_ID
WHERE EXISTS (SELECT 1
				FROM CATCHES
				WHERE LOCATION.TRIP_ID=CATCHES.TRIP_ID and LOCATION.DROP_ID=CATCHES.DROP_ID)
	  and Location_error is null		
GROUP BY LOCATION.TRIP_ID, CNTY, DISTRICT, TRPDATE
order by trpdate
--711	
-------------------------------------------------------------------------------------------------------------------
