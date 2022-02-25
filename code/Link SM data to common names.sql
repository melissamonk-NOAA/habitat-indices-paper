/****** Script for SelectTopNRows command from SSMS  ******/
SELECT distinct SM_TripCatch.recfinsp, common, count(*) as cnt
  FROM [Monk_index_manuscript].[dbo].[SM_TripCatch]
  inner join luspecies on SM_TripCatch.RECFINSP=luspecies.RECFINSP
  group by SM_TripCatch.recfinsp, common
  order by recfinsp



  SELECT ASSN, SM_TripCatch.RECFINSP, COMMON, tot_kept, tot_discd, DBASE
  FROM [Monk_index_manuscript].[dbo].[SM_TripCatch]
  inner join luspecies on SM_TripCatch.RECFINSP=luspecies.RECFINSP





 