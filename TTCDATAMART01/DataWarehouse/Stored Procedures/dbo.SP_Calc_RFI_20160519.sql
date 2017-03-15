SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO


CREATE proc [dbo].[SP_Calc_RFI_20160519] 
as
Begin

return 0

/* this is the RFI template*/

select distinct CatalogCode, CatalogName 
from datawarehouse.Marketing.Email_SalesAndOrders_Summary
where CampaignID in (164, 404, 398) 
and CustomerSegment='Active' 
and YEAR(Ehiststartdate)=2010
order by Catalogname

/*
select * from datawarehouse.mapping.EmailTypeConversionTable 
where CatalogCode in (34583,34584,34585,34586,34587,34588,34590,34591,34593,34607,34608,34609,34610,34611,34612,34614,34615,34617,34620,34621,34622,34623,34624,34625,34627,34628,34630,34656,34657,34658,34659,34660,34661,34663,34664,34666,34680,34681,34682,34683,34684,34685,34687,34688,34690,34693,34694,34695,34696,34697,34698,34700,34701,34703,34790,34787,34792)

delete from datawarehouse.mapping.EmailTypeConversionTable 
where CatalogCode in (34583,34584,34585,34586,34587,34588,34590,34591,34593,34607,34608,34609,34610,34611,34612,34614,34615,34617,34620,34621,34622,34623,34624,34625,34627,34628,34630,34656,34657,34658,34659,34660,34661,34663,34664,34666,34680,34681,34682,34683,34684,34685,34687,34688,34690,34693,34694,34695,34696,34697,34698,34700,34701,34703,34790,34787,34792)


update datawarehouse.mapping.EmailTypeConversionTable 
set EmailId = 12
where CatalogCode in (25572,25571,25576,25574)
*/

-- 5/9/2014
-- Need to add Email offer information in the RFI report
-- datawarehouse.mapping.EmailTypeConversionTable

alter table datawarehouse.mapping.EmailTypeConversionTable
add EmailOfferID int

create table Datawarehouse.Mapping.Email_Offers
(EmailOfferID int,
EmailOffer varchar(50))
/*
insert into Datawarehouse.Mapping.Email_Offers values(501,'Starting at $19.95 ')
insert into Datawarehouse.Mapping.Email_Offers values(502,'NO OFFER')
insert into Datawarehouse.Mapping.Email_Offers values(503,'Buy One, Get One 50% Off')
insert into Datawarehouse.Mapping.Email_Offers values(504,'$20 Off $100')
insert into Datawarehouse.Mapping.Email_Offers values(505,'10% Off Plus Free Shipping')
insert into Datawarehouse.Mapping.Email_Offers values(506,'10% Off ')
insert into Datawarehouse.Mapping.Email_Offers values(507,'$15 Off 2 or More Plus Free Shipping')
insert into Datawarehouse.Mapping.Email_Offers values(508,'$15 Off 2 or More')
insert into Datawarehouse.Mapping.Email_Offers values(509,'20% Off 3 or More Plus Free Shipping')
insert into Datawarehouse.Mapping.Email_Offers values(510,'20% Off 3 or More')
insert into Datawarehouse.Mapping.Email_Offers values(511,'Buy 2, Get 1 FREE')
insert into Datawarehouse.Mapping.Email_Offers values(512,'ALL COURSES ON SALE, PLUS Free Shipping ')
insert into Datawarehouse.Mapping.Email_Offers values(513,'ALL COURSES ON SALE')
insert into Datawarehouse.Mapping.Email_Offers values(514,'50 UNDER $50')
insert into Datawarehouse.Mapping.Email_Offers values(515,'20% Off $150')
insert into Datawarehouse.Mapping.Email_Offers values(516,'15% Off $100')
insert into Datawarehouse.Mapping.Email_Offers values(517,'50% Off Sale Price')
insert into Datawarehouse.Mapping.Email_Offers values(518,'ALL COURSES ON SALE, PLUS $10 Off')
insert into Datawarehouse.Mapping.Email_Offers values(519,'UP TO 90% OFF')
insert into Datawarehouse.Mapping.Email_Offers values(520,'15% Off 2 or More')
insert into Datawarehouse.Mapping.Email_Offers values(521,'$10 OFF ')
insert into Datawarehouse.Mapping.Email_Offers values(522,'25% Off $200')
insert into Datawarehouse.Mapping.Email_Offers values(523,'Up to 80% Off')
insert into Datawarehouse.Mapping.Email_Offers values(524,'Free Shipping')
insert into Datawarehouse.Mapping.Email_Offers values(525,'Starting at $19.95')
insert into Datawarehouse.Mapping.Email_Offers values(526,'$10 Off')
insert into Datawarehouse.Mapping.Email_Offers values(527,'$15 Off $125 PLUS Free Shipping')
insert into Datawarehouse.Mapping.Email_Offers values(528,'$15 Off $125')
insert into Datawarehouse.Mapping.Email_Offers values(529,'20% Off $200 PLUS Free Shipping')
insert into Datawarehouse.Mapping.Email_Offers values(530,'20% Off $200')
insert into Datawarehouse.Mapping.Email_Offers values(531,'$.99 Shipping')
insert into Datawarehouse.Mapping.Email_Offers values(532,'Free 2-Day Shipping')
insert into Datawarehouse.Mapping.Email_Offers values(533,'ALL COURSES ON SALE PLUS $10 Off')
insert into Datawarehouse.Mapping.Email_Offers values(534,'ALL COURSES ON SALE PLUS Free Shipping')
insert into Datawarehouse.Mapping.Email_Offers values(535,'$25 Off 2 or More')
insert into Datawarehouse.Mapping.Email_Offers values(536,'$4.95 Shipping')
insert into Datawarehouse.Mapping.Email_Offers values(537,'Buy 2 Get 1 Free ')
insert into Datawarehouse.Mapping.Email_Offers values(538,'$15 Off $100 or 20% Off $200')
insert into Datawarehouse.Mapping.Email_Offers values(539,'15% Off $75')
insert into Datawarehouse.Mapping.Email_Offers values(540,'20% OFF')
insert into Datawarehouse.Mapping.Email_Offers values(541,'$20 Off $125')
insert into Datawarehouse.Mapping.Email_Offers values(542,'Free Tote Bag')
insert into Datawarehouse.Mapping.Email_Offers values(543,'20% Off $100')
insert into Datawarehouse.Mapping.Email_Offers values(544,'Free Shipping Plus 15% Off 2 or More Sets')
insert into Datawarehouse.Mapping.Email_Offers values(545,'Up to 90% Off PLUS 20% Off $150')
insert into Datawarehouse.Mapping.Email_Offers values(546,'$15 Off $100 Plus 99 Cent Shipping')
insert into Datawarehouse.Mapping.Email_Offers values(547,'$15 off $100')
insert into Datawarehouse.Mapping.Email_Offers values(548,'10% OFF $50, 15% OFF $100, 20% OFF $150')
insert into Datawarehouse.Mapping.Email_Offers values(549,'$20 Off 2 or More')
insert into Datawarehouse.Mapping.Email_Offers values(550,'Buy One, Get One 40% Off')
insert into Datawarehouse.Mapping.Email_Offers values(551,'$25 Off $125')
insert into Datawarehouse.Mapping.Email_Offers values(552,'20% Off 2 or More')
insert into Datawarehouse.Mapping.Email_Offers values(553,'Free Tote')
insert into Datawarehouse.Mapping.Email_Offers values(554,'PM8 Pricing')
insert into Datawarehouse.Mapping.Email_Offers values(555,'10% Off $50')
insert into Datawarehouse.Mapping.Email_Offers values(556,'Up To 90% Off PLUS 20% Off $150 ')
insert into Datawarehouse.Mapping.Email_Offers values(557,'Buy 3, Get 1 Free')
insert into Datawarehouse.Mapping.Email_Offers values(558,'$10 OFF Any Order OR $20 Off $100')
insert into Datawarehouse.Mapping.Email_Offers values(559,'Free Shipping and Free Tote')
insert into Datawarehouse.Mapping.Email_Offers values(560,'$20 Off $100 PLUS Free Shipping')
insert into Datawarehouse.Mapping.Email_Offers values(561,'15% Off 2 or More Sets Plus Free Shipping')
insert into Datawarehouse.Mapping.Email_Offers values(562,'15% Off $75 PLUS Free Shipping')
insert into Datawarehouse.Mapping.Email_Offers values(563,'15% Off $75 ')
insert into Datawarehouse.Mapping.Email_Offers values(564,'ALL COURSES ON SALE PLUS 2-Day Shipping ')
insert into Datawarehouse.Mapping.Email_Offers values(565,'$10 Off Any Order OR $25 Off $150')
insert into Datawarehouse.Mapping.Email_Offers values(566,'Buy One Get One 40% Off')
*/
select * from Datawarehouse.Mapping.Email_Offers
select * from Datawarehouse.Mapping.Email_Offers2015

-- Take this time to move the conversion mapping table to Datawarehouse
--select * 
--into Datawarehouse.Mapping.EmailTypeConversionTable
--from datawarehouse.mapping.EmailTypeConversionTable


select * from [staging].[EmailTypeConversion2015]

--Drop table Datawarehouse.Mapping.EmailTypeConversionTable2015

 select E.CatalogCode,E.CatalogName,replace(E.MD_CampaignName,'Email: ','') as EmailType
  ,V.MD_CampaignID as EmailID
 , case when E.CatalogName like '%DP' then 1
	else 0 end as Flag_DoublePunch
 , case when E.CatalogName like '%TP' then 1
	else 0 end as Flag_TriplePunch
 , S.EmailOfferId
 ,v.MD_PromotionTypeID as MD_PromotionTypeID 
 ,v.MD_PromotionType as MD_PromotionType 
 ,v.MD_CampaignId
 ,V.MD_CampaignName
 ,V.MD_Country
 into Datawarehouse.Mapping.EmailTypeConversionTable2015
 from DataWarehouse.Marketing.EmailTrackerNew E
 left join [staging].[EmailTypeConversion2015] S
 on E.catalogCode = S.catalogCode
 left join mapping.vwAdcodesAll V
 on E.catalogCode = V.catalogCode
 where YearOfEmailSent =2015
 group by E.CatalogCode,E.CatalogName,replace(E.MD_CampaignName,'Email: ',''),S.EmailOfferId,V.MD_CampaignID,v.MD_PromotionTypeID,v.MD_PromotionType,v.MD_CampaignId,V.MD_CampaignName,V.MD_Country



select * from [staging].[EmailTypeConversion2015]

select * from Datawarehouse.Mapping.EmailTypeConversionTable
select * from Datawarehouse.Mapping.EmailTypeConversionTable2015

/*
update Datawarehouse.Mapping.EmailTypeConversionTable set Emailofferid = 501 where catalogcode = 30740
update Datawarehouse.Mapping.EmailTypeConversionTable set Emailofferid = 501 where catalogcode = 30750
update Datawarehouse.Mapping.EmailTypeConversionTable set Emailofferid = 501 where catalogcode = 30744
update Datawarehouse.Mapping.EmailTypeConversionTable set Emailofferid = 501 where catalogcode = 30741
update Datawarehouse.Mapping.EmailTypeConversionTable set Emailofferid = 501 where catalogcode = 30748
update Datawarehouse.Mapping.EmailTypeConversionTable set Emailofferid = 501 where catalogcode = 30746
update Datawarehouse.Mapping.EmailTypeConversionTable set Emailofferid = 501 where catalogcode = 30742
update Datawarehouse.Mapping.EmailTypeConversionTable set Emailofferid = 501 where catalogcode = 30743
update Datawarehouse.Mapping.EmailTypeConversionTable set Emailofferid = 501 where catalogcode = 30745
update Datawarehouse.Mapping.EmailTypeConversionTable set Emailofferid = 501 where catalogcode = 30747
update Datawarehouse.Mapping.EmailTypeConversionTable set Emailofferid = 501 where catalogcode = 30718
update Datawarehouse.Mapping.EmailTypeConversionTable set Emailofferid = 501 where catalogcode = 30728
update Datawarehouse.Mapping.EmailTypeConversionTable set Emailofferid = 501 where catalogcode = 30722
update Datawarehouse.Mapping.EmailTypeConversionTable set Emailofferid = 501 where catalogcode = 30719
update Datawarehouse.Mapping.EmailTypeConversionTable set Emailofferid = 501 where catalogcode = 30726
update Datawarehouse.Mapping.EmailTypeConversionTable set Emailofferid = 501 where catalogcode = 30724
update Datawarehouse.Mapping.EmailTypeConversionTable set Emailofferid = 501 where catalogcode = 30720
update Datawarehouse.Mapping.EmailTypeConversionTable set Emailofferid = 501 where catalogcode = 30721
update Datawarehouse.Mapping.EmailTypeConversionTable set Emailofferid = 501 where catalogcode = 30723
update Datawarehouse.Mapping.EmailTypeConversionTable set Emailofferid = 501 where catalogcode = 30725
update Datawarehouse.Mapping.EmailTypeConversionTable set Emailofferid = 501 where catalogcode = 30752
update Datawarehouse.Mapping.EmailTypeConversionTable set Emailofferid = 501 where catalogcode = 30762
update Datawarehouse.Mapping.EmailTypeConversionTable set Emailofferid = 501 where catalogcode = 30756
update Datawarehouse.Mapping.EmailTypeConversionTable set Emailofferid = 501 where catalogcode = 30753
update Datawarehouse.Mapping.EmailTypeConversionTable set Emailofferid = 501 where catalogcode = 30760
update Datawarehouse.Mapping.EmailTypeConversionTable set Emailofferid = 501 where catalogcode = 30758
update Datawarehouse.Mapping.EmailTypeConversionTable set Emailofferid = 501 where catalogcode = 30754
update Datawarehouse.Mapping.EmailTypeConversionTable set Emailofferid = 501 where catalogcode = 30755
update Datawarehouse.Mapping.EmailTypeConversionTable set Emailofferid = 501 where catalogcode = 30757
update Datawarehouse.Mapping.EmailTypeConversionTable set Emailofferid = 501 where catalogcode = 30759
update Datawarehouse.Mapping.EmailTypeConversionTable set Emailofferid = 501 where catalogcode = 30785
update Datawarehouse.Mapping.EmailTypeConversionTable set Emailofferid = 501 where catalogcode = 30795
update Datawarehouse.Mapping.EmailTypeConversionTable set Emailofferid = 501 where catalogcode = 30789
update Datawarehouse.Mapping.EmailTypeConversionTable set Emailofferid = 501 where catalogcode = 30786
update Datawarehouse.Mapping.EmailTypeConversionTable set Emailofferid = 501 where catalogcode = 30793
update Datawarehouse.Mapping.EmailTypeConversionTable set Emailofferid = 501 where catalogcode = 30791
update Datawarehouse.Mapping.EmailTypeConversionTable set Emailofferid = 501 where catalogcode = 30787
update Datawarehouse.Mapping.EmailTypeConversionTable set Emailofferid = 501 where catalogcode = 30788
update Datawarehouse.Mapping.EmailTypeConversionTable set Emailofferid = 501 where catalogcode = 30790
update Datawarehouse.Mapping.EmailTypeConversionTable set Emailofferid = 501 where catalogcode = 30792
update Datawarehouse.Mapping.EmailTypeConversionTable set Emailofferid = 501 where catalogcode = 30763
update Datawarehouse.Mapping.EmailTypeConversionTable set Emailofferid = 501 where catalogcode = 30773
update Datawarehouse.Mapping.EmailTypeConversionTable set Emailofferid = 501 where catalogcode = 30767
update Datawarehouse.Mapping.EmailTypeConversionTable set Emailofferid = 501 where catalogcode = 30764
update Datawarehouse.Mapping.EmailTypeConversionTable set Emailofferid = 501 where catalogcode = 30771
update Datawarehouse.Mapping.EmailTypeConversionTable set Emailofferid = 501 where catalogcode = 30769
update Datawarehouse.Mapping.EmailTypeConversionTable set Emailofferid = 501 where catalogcode = 30765
update Datawarehouse.Mapping.EmailTypeConversionTable set Emailofferid = 501 where catalogcode = 30766
update Datawarehouse.Mapping.EmailTypeConversionTable set Emailofferid = 501 where catalogcode = 30768
update Datawarehouse.Mapping.EmailTypeConversionTable set Emailofferid = 501 where catalogcode = 30770
update Datawarehouse.Mapping.EmailTypeConversionTable set Emailofferid = 501 where catalogcode = 30797
update Datawarehouse.Mapping.EmailTypeConversionTable set Emailofferid = 501 where catalogcode = 30807
update Datawarehouse.Mapping.EmailTypeConversionTable set Emailofferid = 501 where catalogcode = 30801
update Datawarehouse.Mapping.EmailTypeConversionTable set Emailofferid = 501 where catalogcode = 30798
update Datawarehouse.Mapping.EmailTypeConversionTable set Emailofferid = 501 where catalogcode = 30805
update Datawarehouse.Mapping.EmailTypeConversionTable set Emailofferid = 501 where catalogcode = 30803
update Datawarehouse.Mapping.EmailTypeConversionTable set Emailofferid = 501 where catalogcode = 30799
update Datawarehouse.Mapping.EmailTypeConversionTable set Emailofferid = 501 where catalogcode = 30800
update Datawarehouse.Mapping.EmailTypeConversionTable set Emailofferid = 501 where catalogcode = 30802
update Datawarehouse.Mapping.EmailTypeConversionTable set Emailofferid = 501 where catalogcode = 30804
update Datawarehouse.Mapping.EmailTypeConversionTable set Emailofferid = 502 where catalogcode = 30808
update Datawarehouse.Mapping.EmailTypeConversionTable set Emailofferid = 502 where catalogcode = 30812
update Datawarehouse.Mapping.EmailTypeConversionTable set Emailofferid = 502 where catalogcode = 30810
update Datawarehouse.Mapping.EmailTypeConversionTable set Emailofferid = 503 where catalogcode = 30979
update Datawarehouse.Mapping.EmailTypeConversionTable set Emailofferid = 503 where catalogcode = 30983
update Datawarehouse.Mapping.EmailTypeConversionTable set Emailofferid = 503 where catalogcode = 30981
update Datawarehouse.Mapping.EmailTypeConversionTable set Emailofferid = 502 where catalogcode = 31013
update Datawarehouse.Mapping.EmailTypeConversionTable set Emailofferid = 502 where catalogcode = 31014
update Datawarehouse.Mapping.EmailTypeConversionTable set Emailofferid = 502 where catalogcode = 31018
update Datawarehouse.Mapping.EmailTypeConversionTable set Emailofferid = 502 where catalogcode = 31016
update Datawarehouse.Mapping.EmailTypeConversionTable set Emailofferid = 504 where catalogcode = 31481
update Datawarehouse.Mapping.EmailTypeConversionTable set Emailofferid = 504 where catalogcode = 31482
update Datawarehouse.Mapping.EmailTypeConversionTable set Emailofferid = 504 where catalogcode = 31486
update Datawarehouse.Mapping.EmailTypeConversionTable set Emailofferid = 504 where catalogcode = 31484
update Datawarehouse.Mapping.EmailTypeConversionTable set Emailofferid = 502 where catalogcode = 31495
update Datawarehouse.Mapping.EmailTypeConversionTable set Emailofferid = 502 where catalogcode = 31500
update Datawarehouse.Mapping.EmailTypeConversionTable set Emailofferid = 502 where catalogcode = 31498
update Datawarehouse.Mapping.EmailTypeConversionTable set Emailofferid = 502 where catalogcode = 31507
update Datawarehouse.Mapping.EmailTypeConversionTable set Emailofferid = 502 where catalogcode = 31512
update Datawarehouse.Mapping.EmailTypeConversionTable set Emailofferid = 502 where catalogcode = 31510
update Datawarehouse.Mapping.EmailTypeConversionTable set Emailofferid = 502 where catalogcode = 31496
update Datawarehouse.Mapping.EmailTypeConversionTable set Emailofferid = 502 where catalogcode = 31508
update Datawarehouse.Mapping.EmailTypeConversionTable set Emailofferid = 502 where catalogcode = 31563
update Datawarehouse.Mapping.EmailTypeConversionTable set Emailofferid = 502 where catalogcode = 31561
update Datawarehouse.Mapping.EmailTypeConversionTable set Emailofferid = 502 where catalogcode = 31567
update Datawarehouse.Mapping.EmailTypeConversionTable set Emailofferid = 502 where catalogcode = 31565
update Datawarehouse.Mapping.EmailTypeConversionTable set Emailofferid = 505 where catalogcode = 31627
update Datawarehouse.Mapping.EmailTypeConversionTable set Emailofferid = 506 where catalogcode = 31631
update Datawarehouse.Mapping.EmailTypeConversionTable set Emailofferid = 506 where catalogcode = 31629
update Datawarehouse.Mapping.EmailTypeConversionTable set Emailofferid = 507 where catalogcode = 31632
update Datawarehouse.Mapping.EmailTypeConversionTable set Emailofferid = 508 where catalogcode = 31636
update Datawarehouse.Mapping.EmailTypeConversionTable set Emailofferid = 508 where catalogcode = 31634
update Datawarehouse.Mapping.EmailTypeConversionTable set Emailofferid = 509 where catalogcode = 31645
update Datawarehouse.Mapping.EmailTypeConversionTable set Emailofferid = 510 where catalogcode = 31649
update Datawarehouse.Mapping.EmailTypeConversionTable set Emailofferid = 510 where catalogcode = 31647
update Datawarehouse.Mapping.EmailTypeConversionTable set Emailofferid = 511 where catalogcode = 32046
update Datawarehouse.Mapping.EmailTypeConversionTable set Emailofferid = 511 where catalogcode = 32048
update Datawarehouse.Mapping.EmailTypeConversionTable set Emailofferid = 511 where catalogcode = 32057
update Datawarehouse.Mapping.EmailTypeConversionTable set Emailofferid = 511 where catalogcode = 32058
update Datawarehouse.Mapping.EmailTypeConversionTable set Emailofferid = 511 where catalogcode = 32049
update Datawarehouse.Mapping.EmailTypeConversionTable set Emailofferid = 511 where catalogcode = 32051
update Datawarehouse.Mapping.EmailTypeConversionTable set Emailofferid = 511 where catalogcode = 32040
update Datawarehouse.Mapping.EmailTypeConversionTable set Emailofferid = 511 where catalogcode = 32041
update Datawarehouse.Mapping.EmailTypeConversionTable set Emailofferid = 511 where catalogcode = 32045
update Datawarehouse.Mapping.EmailTypeConversionTable set Emailofferid = 511 where catalogcode = 32043
update Datawarehouse.Mapping.EmailTypeConversionTable set Emailofferid = 511 where catalogcode = 32065
update Datawarehouse.Mapping.EmailTypeConversionTable set Emailofferid = 511 where catalogcode = 32068
update Datawarehouse.Mapping.EmailTypeConversionTable set Emailofferid = 511 where catalogcode = 32067
update Datawarehouse.Mapping.EmailTypeConversionTable set Emailofferid = 511 where catalogcode = 32071
update Datawarehouse.Mapping.EmailTypeConversionTable set Emailofferid = 511 where catalogcode = 32069
update Datawarehouse.Mapping.EmailTypeConversionTable set Emailofferid = 511 where catalogcode = 32072
update Datawarehouse.Mapping.EmailTypeConversionTable set Emailofferid = 511 where catalogcode = 32059
update Datawarehouse.Mapping.EmailTypeConversionTable set Emailofferid = 511 where catalogcode = 32060
update Datawarehouse.Mapping.EmailTypeConversionTable set Emailofferid = 511 where catalogcode = 32064
update Datawarehouse.Mapping.EmailTypeConversionTable set Emailofferid = 511 where catalogcode = 32062
update Datawarehouse.Mapping.EmailTypeConversionTable set Emailofferid = 501 where catalogcode = 32078
update Datawarehouse.Mapping.EmailTypeConversionTable set Emailofferid = 501 where catalogcode = 32079
update Datawarehouse.Mapping.EmailTypeConversionTable set Emailofferid = 501 where catalogcode = 32083
update Datawarehouse.Mapping.EmailTypeConversionTable set Emailofferid = 501 where catalogcode = 32081
update Datawarehouse.Mapping.EmailTypeConversionTable set Emailofferid = 512 where catalogcode = 32150
update Datawarehouse.Mapping.EmailTypeConversionTable set Emailofferid = 513 where catalogcode = 32154
update Datawarehouse.Mapping.EmailTypeConversionTable set Emailofferid = 513 where catalogcode = 32152
update Datawarehouse.Mapping.EmailTypeConversionTable set Emailofferid = 512 where catalogcode = 32155
update Datawarehouse.Mapping.EmailTypeConversionTable set Emailofferid = 513 where catalogcode = 32159
update Datawarehouse.Mapping.EmailTypeConversionTable set Emailofferid = 513 where catalogcode = 32157
update Datawarehouse.Mapping.EmailTypeConversionTable set Emailofferid = 502 where catalogcode = 32238
update Datawarehouse.Mapping.EmailTypeConversionTable set Emailofferid = 502 where catalogcode = 32234
update Datawarehouse.Mapping.EmailTypeConversionTable set Emailofferid = 502 where catalogcode = 32241
update Datawarehouse.Mapping.EmailTypeConversionTable set Emailofferid = 514 where catalogcode = 32268
update Datawarehouse.Mapping.EmailTypeConversionTable set Emailofferid = 514 where catalogcode = 32270
update Datawarehouse.Mapping.EmailTypeConversionTable set Emailofferid = 514 where catalogcode = 32267
update Datawarehouse.Mapping.EmailTypeConversionTable set Emailofferid = 514 where catalogcode = 32272
update Datawarehouse.Mapping.EmailTypeConversionTable set Emailofferid = 515 where catalogcode = 32341
update Datawarehouse.Mapping.EmailTypeConversionTable set Emailofferid = 515 where catalogcode = 32338
update Datawarehouse.Mapping.EmailTypeConversionTable set Emailofferid = 515 where catalogcode = 32339
update Datawarehouse.Mapping.EmailTypeConversionTable set Emailofferid = 515 where catalogcode = 32343
update Datawarehouse.Mapping.EmailTypeConversionTable set Emailofferid = 516 where catalogcode = 32607
update Datawarehouse.Mapping.EmailTypeConversionTable set Emailofferid = 516 where catalogcode = 32605
update Datawarehouse.Mapping.EmailTypeConversionTable set Emailofferid = 516 where catalogcode = 32609
update Datawarehouse.Mapping.EmailTypeConversionTable set Emailofferid = 516 where catalogcode = 32625
update Datawarehouse.Mapping.EmailTypeConversionTable set Emailofferid = 516 where catalogcode = 32627
update Datawarehouse.Mapping.EmailTypeConversionTable set Emailofferid = 516 where catalogcode = 32629
update Datawarehouse.Mapping.EmailTypeConversionTable set Emailofferid = 517 where catalogcode = 32720
update Datawarehouse.Mapping.EmailTypeConversionTable set Emailofferid = 517 where catalogcode = 32722
update Datawarehouse.Mapping.EmailTypeConversionTable set Emailofferid = 517 where catalogcode = 32724
update Datawarehouse.Mapping.EmailTypeConversionTable set Emailofferid = 517 where catalogcode = 32726
update Datawarehouse.Mapping.EmailTypeConversionTable set Emailofferid = 517 where catalogcode = 32730
update Datawarehouse.Mapping.EmailTypeConversionTable set Emailofferid = 517 where catalogcode = 32728
update Datawarehouse.Mapping.EmailTypeConversionTable set Emailofferid = 518 where catalogcode = 32834
update Datawarehouse.Mapping.EmailTypeConversionTable set Emailofferid = 512 where catalogcode = 32832
update Datawarehouse.Mapping.EmailTypeConversionTable set Emailofferid = 518 where catalogcode = 32836
update Datawarehouse.Mapping.EmailTypeConversionTable set Emailofferid = 512 where catalogcode = 32838
update Datawarehouse.Mapping.EmailTypeConversionTable set Emailofferid = 518 where catalogcode = 32840
update Datawarehouse.Mapping.EmailTypeConversionTable set Emailofferid = 518 where catalogcode = 32842
update Datawarehouse.Mapping.EmailTypeConversionTable set Emailofferid = 519 where catalogcode = 32909
update Datawarehouse.Mapping.EmailTypeConversionTable set Emailofferid = 519 where catalogcode = 32911
update Datawarehouse.Mapping.EmailTypeConversionTable set Emailofferid = 519 where catalogcode = 32913
update Datawarehouse.Mapping.EmailTypeConversionTable set Emailofferid = 503 where catalogcode = 32954
update Datawarehouse.Mapping.EmailTypeConversionTable set Emailofferid = 503 where catalogcode = 32952
update Datawarehouse.Mapping.EmailTypeConversionTable set Emailofferid = 503 where catalogcode = 32956
update Datawarehouse.Mapping.EmailTypeConversionTable set Emailofferid = 503 where catalogcode = 32951
update Datawarehouse.Mapping.EmailTypeConversionTable set Emailofferid = 503 where catalogcode = 32961
update Datawarehouse.Mapping.EmailTypeConversionTable set Emailofferid = 503 where catalogcode = 32963
update Datawarehouse.Mapping.EmailTypeConversionTable set Emailofferid = 503 where catalogcode = 32960
update Datawarehouse.Mapping.EmailTypeConversionTable set Emailofferid = 503 where catalogcode = 32965
update Datawarehouse.Mapping.EmailTypeConversionTable set Emailofferid = 502 where catalogcode = 32971
update Datawarehouse.Mapping.EmailTypeConversionTable set Emailofferid = 502 where catalogcode = 32968
update Datawarehouse.Mapping.EmailTypeConversionTable set Emailofferid = 502 where catalogcode = 32969
update Datawarehouse.Mapping.EmailTypeConversionTable set Emailofferid = 502 where catalogcode = 33007
update Datawarehouse.Mapping.EmailTypeConversionTable set Emailofferid = 502 where catalogcode = 33005
update Datawarehouse.Mapping.EmailTypeConversionTable set Emailofferid = 502 where catalogcode = 33015
update Datawarehouse.Mapping.EmailTypeConversionTable set Emailofferid = 502 where catalogcode = 33012
update Datawarehouse.Mapping.EmailTypeConversionTable set Emailofferid = 502 where catalogcode = 33010
update Datawarehouse.Mapping.EmailTypeConversionTable set Emailofferid = 502 where catalogcode = 33016
update Datawarehouse.Mapping.EmailTypeConversionTable set Emailofferid = 520 where catalogcode = 33020
update Datawarehouse.Mapping.EmailTypeConversionTable set Emailofferid = 520 where catalogcode = 33017
update Datawarehouse.Mapping.EmailTypeConversionTable set Emailofferid = 520 where catalogcode = 33018
update Datawarehouse.Mapping.EmailTypeConversionTable set Emailofferid = 521 where catalogcode = 33057
update Datawarehouse.Mapping.EmailTypeConversionTable set Emailofferid = 521 where catalogcode = 33062
update Datawarehouse.Mapping.EmailTypeConversionTable set Emailofferid = 521 where catalogcode = 33060
update Datawarehouse.Mapping.EmailTypeConversionTable set Emailofferid = 521 where catalogcode = 33059
update Datawarehouse.Mapping.EmailTypeConversionTable set Emailofferid = 521 where catalogcode = 33064
update Datawarehouse.Mapping.EmailTypeConversionTable set Emailofferid = 521 where catalogcode = 33063
update Datawarehouse.Mapping.EmailTypeConversionTable set Emailofferid = 521 where catalogcode = 33068
update Datawarehouse.Mapping.EmailTypeConversionTable set Emailofferid = 521 where catalogcode = 33033
update Datawarehouse.Mapping.EmailTypeConversionTable set Emailofferid = 521 where catalogcode = 33034
update Datawarehouse.Mapping.EmailTypeConversionTable set Emailofferid = 521 where catalogcode = 33035
update Datawarehouse.Mapping.EmailTypeConversionTable set Emailofferid = 521 where catalogcode = 33058
update Datawarehouse.Mapping.EmailTypeConversionTable set Emailofferid = 521 where catalogcode = 33067
update Datawarehouse.Mapping.EmailTypeConversionTable set Emailofferid = 521 where catalogcode = 33065
update Datawarehouse.Mapping.EmailTypeConversionTable set Emailofferid = 521 where catalogcode = 33036
update Datawarehouse.Mapping.EmailTypeConversionTable set Emailofferid = 521 where catalogcode = 33039
update Datawarehouse.Mapping.EmailTypeConversionTable set Emailofferid = 521 where catalogcode = 33041
update Datawarehouse.Mapping.EmailTypeConversionTable set Emailofferid = 521 where catalogcode = 33038
update Datawarehouse.Mapping.EmailTypeConversionTable set Emailofferid = 521 where catalogcode = 33040
update Datawarehouse.Mapping.EmailTypeConversionTable set Emailofferid = 521 where catalogcode = 33044
update Datawarehouse.Mapping.EmailTypeConversionTable set Emailofferid = 521 where catalogcode = 33043
update Datawarehouse.Mapping.EmailTypeConversionTable set Emailofferid = 521 where catalogcode = 33106
update Datawarehouse.Mapping.EmailTypeConversionTable set Emailofferid = 521 where catalogcode = 33107
update Datawarehouse.Mapping.EmailTypeConversionTable set Emailofferid = 521 where catalogcode = 33108
update Datawarehouse.Mapping.EmailTypeConversionTable set Emailofferid = 521 where catalogcode = 33114
update Datawarehouse.Mapping.EmailTypeConversionTable set Emailofferid = 521 where catalogcode = 33111
update Datawarehouse.Mapping.EmailTypeConversionTable set Emailofferid = 521 where catalogcode = 33112
update Datawarehouse.Mapping.EmailTypeConversionTable set Emailofferid = 521 where catalogcode = 33117
update Datawarehouse.Mapping.EmailTypeConversionTable set Emailofferid = 521 where catalogcode = 33109
update Datawarehouse.Mapping.EmailTypeConversionTable set Emailofferid = 521 where catalogcode = 33083
update Datawarehouse.Mapping.EmailTypeConversionTable set Emailofferid = 521 where catalogcode = 33082
update Datawarehouse.Mapping.EmailTypeConversionTable set Emailofferid = 521 where catalogcode = 33085
update Datawarehouse.Mapping.EmailTypeConversionTable set Emailofferid = 521 where catalogcode = 33090
update Datawarehouse.Mapping.EmailTypeConversionTable set Emailofferid = 521 where catalogcode = 33084
update Datawarehouse.Mapping.EmailTypeConversionTable set Emailofferid = 521 where catalogcode = 33087
update Datawarehouse.Mapping.EmailTypeConversionTable set Emailofferid = 521 where catalogcode = 33089
update Datawarehouse.Mapping.EmailTypeConversionTable set Emailofferid = 521 where catalogcode = 33088
update Datawarehouse.Mapping.EmailTypeConversionTable set Emailofferid = 521 where catalogcode = 33093
update Datawarehouse.Mapping.EmailTypeConversionTable set Emailofferid = 521 where catalogcode = 33092
update Datawarehouse.Mapping.EmailTypeConversionTable set Emailofferid = 521 where catalogcode = 33116
update Datawarehouse.Mapping.EmailTypeConversionTable set Emailofferid = 521 where catalogcode = 33113
update Datawarehouse.Mapping.EmailTypeConversionTable set Emailofferid = 502 where catalogcode = 33194
update Datawarehouse.Mapping.EmailTypeConversionTable set Emailofferid = 502 where catalogcode = 33192
update Datawarehouse.Mapping.EmailTypeConversionTable set Emailofferid = 502 where catalogcode = 33191
update Datawarehouse.Mapping.EmailTypeConversionTable set Emailofferid = 521 where catalogcode = 33257
update Datawarehouse.Mapping.EmailTypeConversionTable set Emailofferid = 521 where catalogcode = 33256
update Datawarehouse.Mapping.EmailTypeConversionTable set Emailofferid = 521 where catalogcode = 33259
update Datawarehouse.Mapping.EmailTypeConversionTable set Emailofferid = 521 where catalogcode = 33261
update Datawarehouse.Mapping.EmailTypeConversionTable set Emailofferid = 522 where catalogcode = 33314
update Datawarehouse.Mapping.EmailTypeConversionTable set Emailofferid = 522 where catalogcode = 33326
update Datawarehouse.Mapping.EmailTypeConversionTable set Emailofferid = 522 where catalogcode = 33312
update Datawarehouse.Mapping.EmailTypeConversionTable set Emailofferid = 522 where catalogcode = 33316
update Datawarehouse.Mapping.EmailTypeConversionTable set Emailofferid = 502 where catalogcode = 33146
update Datawarehouse.Mapping.EmailTypeConversionTable set Emailofferid = 502 where catalogcode = 33143
update Datawarehouse.Mapping.EmailTypeConversionTable set Emailofferid = 502 where catalogcode = 33147
update Datawarehouse.Mapping.EmailTypeConversionTable set Emailofferid = 523 where catalogcode = 33342
update Datawarehouse.Mapping.EmailTypeConversionTable set Emailofferid = 523 where catalogcode = 33345
update Datawarehouse.Mapping.EmailTypeConversionTable set Emailofferid = 523 where catalogcode = 33347
update Datawarehouse.Mapping.EmailTypeConversionTable set Emailofferid = 523 where catalogcode = 33343
update Datawarehouse.Mapping.EmailTypeConversionTable set Emailofferid = 523 where catalogcode = 33351
update Datawarehouse.Mapping.EmailTypeConversionTable set Emailofferid = 523 where catalogcode = 33348
update Datawarehouse.Mapping.EmailTypeConversionTable set Emailofferid = 523 where catalogcode = 33349
update Datawarehouse.Mapping.EmailTypeConversionTable set Emailofferid = 523 where catalogcode = 33353
update Datawarehouse.Mapping.EmailTypeConversionTable set Emailofferid = 502 where catalogcode = 33402
update Datawarehouse.Mapping.EmailTypeConversionTable set Emailofferid = 524 where catalogcode = 33400
update Datawarehouse.Mapping.EmailTypeConversionTable set Emailofferid = 502 where catalogcode = 33404
update Datawarehouse.Mapping.EmailTypeConversionTable set Emailofferid = 525 where catalogcode = 33420
update Datawarehouse.Mapping.EmailTypeConversionTable set Emailofferid = 525 where catalogcode = 33418
update Datawarehouse.Mapping.EmailTypeConversionTable set Emailofferid = 525 where catalogcode = 33472
update Datawarehouse.Mapping.EmailTypeConversionTable set Emailofferid = 525 where catalogcode = 33422
update Datawarehouse.Mapping.EmailTypeConversionTable set Emailofferid = 524 where catalogcode = 33452
update Datawarehouse.Mapping.EmailTypeConversionTable set Emailofferid = 524 where catalogcode = 33451
update Datawarehouse.Mapping.EmailTypeConversionTable set Emailofferid = 526 where catalogcode = 33454
update Datawarehouse.Mapping.EmailTypeConversionTable set Emailofferid = 526 where catalogcode = 33456
update Datawarehouse.Mapping.EmailTypeConversionTable set Emailofferid = 527 where catalogcode = 33459
update Datawarehouse.Mapping.EmailTypeConversionTable set Emailofferid = 527 where catalogcode = 33458
update Datawarehouse.Mapping.EmailTypeConversionTable set Emailofferid = 528 where catalogcode = 33461
update Datawarehouse.Mapping.EmailTypeConversionTable set Emailofferid = 528 where catalogcode = 33463
update Datawarehouse.Mapping.EmailTypeConversionTable set Emailofferid = 529 where catalogcode = 33465
update Datawarehouse.Mapping.EmailTypeConversionTable set Emailofferid = 529 where catalogcode = 33464
update Datawarehouse.Mapping.EmailTypeConversionTable set Emailofferid = 530 where catalogcode = 33467
update Datawarehouse.Mapping.EmailTypeConversionTable set Emailofferid = 530 where catalogcode = 33469
update Datawarehouse.Mapping.EmailTypeConversionTable set Emailofferid = 502 where catalogcode = 33512
update Datawarehouse.Mapping.EmailTypeConversionTable set Emailofferid = 502 where catalogcode = 33509
update Datawarehouse.Mapping.EmailTypeConversionTable set Emailofferid = 502 where catalogcode = 33514
update Datawarehouse.Mapping.EmailTypeConversionTable set Emailofferid = 526 where catalogcode = 33519
update Datawarehouse.Mapping.EmailTypeConversionTable set Emailofferid = 531 where catalogcode = 33517
update Datawarehouse.Mapping.EmailTypeConversionTable set Emailofferid = 526 where catalogcode = 33521
update Datawarehouse.Mapping.EmailTypeConversionTable set Emailofferid = 531 where catalogcode = 33853
update Datawarehouse.Mapping.EmailTypeConversionTable set Emailofferid = 521 where catalogcode = 33859
update Datawarehouse.Mapping.EmailTypeConversionTable set Emailofferid = 521 where catalogcode = 33857
update Datawarehouse.Mapping.EmailTypeConversionTable set Emailofferid = 532 where catalogcode = 33861
update Datawarehouse.Mapping.EmailTypeConversionTable set Emailofferid = 526 where catalogcode = 33865
update Datawarehouse.Mapping.EmailTypeConversionTable set Emailofferid = 526 where catalogcode = 33867
update Datawarehouse.Mapping.EmailTypeConversionTable set Emailofferid = 533 where catalogcode = 34052
update Datawarehouse.Mapping.EmailTypeConversionTable set Emailofferid = 534 where catalogcode = 34050
update Datawarehouse.Mapping.EmailTypeConversionTable set Emailofferid = 533 where catalogcode = 34054
update Datawarehouse.Mapping.EmailTypeConversionTable set Emailofferid = 533 where catalogcode = 34059
update Datawarehouse.Mapping.EmailTypeConversionTable set Emailofferid = 534 where catalogcode = 34057
update Datawarehouse.Mapping.EmailTypeConversionTable set Emailofferid = 533 where catalogcode = 34061
update Datawarehouse.Mapping.EmailTypeConversionTable set Emailofferid = 534 where catalogcode = 34119
update Datawarehouse.Mapping.EmailTypeConversionTable set Emailofferid = 533 where catalogcode = 34121
update Datawarehouse.Mapping.EmailTypeConversionTable set Emailofferid = 533 where catalogcode = 34123
update Datawarehouse.Mapping.EmailTypeConversionTable set Emailofferid = 517 where catalogcode = 34186
update Datawarehouse.Mapping.EmailTypeConversionTable set Emailofferid = 517 where catalogcode = 34103
update Datawarehouse.Mapping.EmailTypeConversionTable set Emailofferid = 517 where catalogcode = 34101
update Datawarehouse.Mapping.EmailTypeConversionTable set Emailofferid = 517 where catalogcode = 34105
update Datawarehouse.Mapping.EmailTypeConversionTable set Emailofferid = 517 where catalogcode = 34187
update Datawarehouse.Mapping.EmailTypeConversionTable set Emailofferid = 517 where catalogcode = 34131
update Datawarehouse.Mapping.EmailTypeConversionTable set Emailofferid = 517 where catalogcode = 34135
update Datawarehouse.Mapping.EmailTypeConversionTable set Emailofferid = 517 where catalogcode = 34137
update Datawarehouse.Mapping.EmailTypeConversionTable set Emailofferid = 502 where catalogcode = 34109
update Datawarehouse.Mapping.EmailTypeConversionTable set Emailofferid = 502 where catalogcode = 34110
update Datawarehouse.Mapping.EmailTypeConversionTable set Emailofferid = 502 where catalogcode = 34165
update Datawarehouse.Mapping.EmailTypeConversionTable set Emailofferid = 502 where catalogcode = 34166
update Datawarehouse.Mapping.EmailTypeConversionTable set Emailofferid = 502 where catalogcode = 34167
update Datawarehouse.Mapping.EmailTypeConversionTable set Emailofferid = 502 where catalogcode = 34112
update Datawarehouse.Mapping.EmailTypeConversionTable set Emailofferid = 502 where catalogcode = 34116
update Datawarehouse.Mapping.EmailTypeConversionTable set Emailofferid = 515 where catalogcode = 34171
update Datawarehouse.Mapping.EmailTypeConversionTable set Emailofferid = 515 where catalogcode = 34168
update Datawarehouse.Mapping.EmailTypeConversionTable set Emailofferid = 515 where catalogcode = 34169
update Datawarehouse.Mapping.EmailTypeConversionTable set Emailofferid = 515 where catalogcode = 34173
update Datawarehouse.Mapping.EmailTypeConversionTable set Emailofferid = 515 where catalogcode = 34177
update Datawarehouse.Mapping.EmailTypeConversionTable set Emailofferid = 515 where catalogcode = 34180
update Datawarehouse.Mapping.EmailTypeConversionTable set Emailofferid = 515 where catalogcode = 34178
update Datawarehouse.Mapping.EmailTypeConversionTable set Emailofferid = 515 where catalogcode = 34182
update Datawarehouse.Mapping.EmailTypeConversionTable set Emailofferid = 502 where catalogcode = 34190
update Datawarehouse.Mapping.EmailTypeConversionTable set Emailofferid = 502 where catalogcode = 34188
update Datawarehouse.Mapping.EmailTypeConversionTable set Emailofferid = 502 where catalogcode = 34192
update Datawarehouse.Mapping.EmailTypeConversionTable set Emailofferid = 502 where catalogcode = 34213
update Datawarehouse.Mapping.EmailTypeConversionTable set Emailofferid = 502 where catalogcode = 34211
update Datawarehouse.Mapping.EmailTypeConversionTable set Emailofferid = 502 where catalogcode = 34215
update Datawarehouse.Mapping.EmailTypeConversionTable set Emailofferid = 502 where catalogcode = 34081
update Datawarehouse.Mapping.EmailTypeConversionTable set Emailofferid = 502 where catalogcode = 34078
update Datawarehouse.Mapping.EmailTypeConversionTable set Emailofferid = 502 where catalogcode = 34083
update Datawarehouse.Mapping.EmailTypeConversionTable set Emailofferid = 503 where catalogcode = 34569
update Datawarehouse.Mapping.EmailTypeConversionTable set Emailofferid = 503 where catalogcode = 34571
update Datawarehouse.Mapping.EmailTypeConversionTable set Emailofferid = 503 where catalogcode = 34573
update Datawarehouse.Mapping.EmailTypeConversionTable set Emailofferid = 525 where catalogcode = 34583
update Datawarehouse.Mapping.EmailTypeConversionTable set Emailofferid = 525 where catalogcode = 34584
update Datawarehouse.Mapping.EmailTypeConversionTable set Emailofferid = 525 where catalogcode = 34585
update Datawarehouse.Mapping.EmailTypeConversionTable set Emailofferid = 525 where catalogcode = 34586
update Datawarehouse.Mapping.EmailTypeConversionTable set Emailofferid = 525 where catalogcode = 34587
update Datawarehouse.Mapping.EmailTypeConversionTable set Emailofferid = 525 where catalogcode = 34588
update Datawarehouse.Mapping.EmailTypeConversionTable set Emailofferid = 525 where catalogcode = 34590
update Datawarehouse.Mapping.EmailTypeConversionTable set Emailofferid = 525 where catalogcode = 34591
update Datawarehouse.Mapping.EmailTypeConversionTable set Emailofferid = 525 where catalogcode = 34593
update Datawarehouse.Mapping.EmailTypeConversionTable set Emailofferid = 525 where catalogcode = 34607
update Datawarehouse.Mapping.EmailTypeConversionTable set Emailofferid = 525 where catalogcode = 34608
update Datawarehouse.Mapping.EmailTypeConversionTable set Emailofferid = 525 where catalogcode = 34609
update Datawarehouse.Mapping.EmailTypeConversionTable set Emailofferid = 525 where catalogcode = 34610
update Datawarehouse.Mapping.EmailTypeConversionTable set Emailofferid = 525 where catalogcode = 34611
update Datawarehouse.Mapping.EmailTypeConversionTable set Emailofferid = 525 where catalogcode = 34612
update Datawarehouse.Mapping.EmailTypeConversionTable set Emailofferid = 525 where catalogcode = 34614
update Datawarehouse.Mapping.EmailTypeConversionTable set Emailofferid = 525 where catalogcode = 34615
update Datawarehouse.Mapping.EmailTypeConversionTable set Emailofferid = 525 where catalogcode = 34617
update Datawarehouse.Mapping.EmailTypeConversionTable set Emailofferid = 525 where catalogcode = 34620
update Datawarehouse.Mapping.EmailTypeConversionTable set Emailofferid = 525 where catalogcode = 34621
update Datawarehouse.Mapping.EmailTypeConversionTable set Emailofferid = 525 where catalogcode = 34622
update Datawarehouse.Mapping.EmailTypeConversionTable set Emailofferid = 525 where catalogcode = 34623
update Datawarehouse.Mapping.EmailTypeConversionTable set Emailofferid = 525 where catalogcode = 34624
update Datawarehouse.Mapping.EmailTypeConversionTable set Emailofferid = 525 where catalogcode = 34625
update Datawarehouse.Mapping.EmailTypeConversionTable set Emailofferid = 525 where catalogcode = 34627
update Datawarehouse.Mapping.EmailTypeConversionTable set Emailofferid = 525 where catalogcode = 34628
update Datawarehouse.Mapping.EmailTypeConversionTable set Emailofferid = 525 where catalogcode = 34630
update Datawarehouse.Mapping.EmailTypeConversionTable set Emailofferid = 525 where catalogcode = 34656
update Datawarehouse.Mapping.EmailTypeConversionTable set Emailofferid = 525 where catalogcode = 34657
update Datawarehouse.Mapping.EmailTypeConversionTable set Emailofferid = 525 where catalogcode = 34658
update Datawarehouse.Mapping.EmailTypeConversionTable set Emailofferid = 525 where catalogcode = 34659
update Datawarehouse.Mapping.EmailTypeConversionTable set Emailofferid = 525 where catalogcode = 34660
update Datawarehouse.Mapping.EmailTypeConversionTable set Emailofferid = 525 where catalogcode = 34661
update Datawarehouse.Mapping.EmailTypeConversionTable set Emailofferid = 525 where catalogcode = 34663
update Datawarehouse.Mapping.EmailTypeConversionTable set Emailofferid = 525 where catalogcode = 34664
update Datawarehouse.Mapping.EmailTypeConversionTable set Emailofferid = 525 where catalogcode = 34666
update Datawarehouse.Mapping.EmailTypeConversionTable set Emailofferid = 525 where catalogcode = 34680
update Datawarehouse.Mapping.EmailTypeConversionTable set Emailofferid = 525 where catalogcode = 34681
update Datawarehouse.Mapping.EmailTypeConversionTable set Emailofferid = 525 where catalogcode = 34682
update Datawarehouse.Mapping.EmailTypeConversionTable set Emailofferid = 525 where catalogcode = 34683
update Datawarehouse.Mapping.EmailTypeConversionTable set Emailofferid = 525 where catalogcode = 34684
update Datawarehouse.Mapping.EmailTypeConversionTable set Emailofferid = 525 where catalogcode = 34685
update Datawarehouse.Mapping.EmailTypeConversionTable set Emailofferid = 525 where catalogcode = 34687
update Datawarehouse.Mapping.EmailTypeConversionTable set Emailofferid = 525 where catalogcode = 34688
update Datawarehouse.Mapping.EmailTypeConversionTable set Emailofferid = 525 where catalogcode = 34690
update Datawarehouse.Mapping.EmailTypeConversionTable set Emailofferid = 525 where catalogcode = 34693
update Datawarehouse.Mapping.EmailTypeConversionTable set Emailofferid = 525 where catalogcode = 34694
update Datawarehouse.Mapping.EmailTypeConversionTable set Emailofferid = 525 where catalogcode = 34695
update Datawarehouse.Mapping.EmailTypeConversionTable set Emailofferid = 525 where catalogcode = 34696
update Datawarehouse.Mapping.EmailTypeConversionTable set Emailofferid = 525 where catalogcode = 34697
update Datawarehouse.Mapping.EmailTypeConversionTable set Emailofferid = 525 where catalogcode = 34698
update Datawarehouse.Mapping.EmailTypeConversionTable set Emailofferid = 525 where catalogcode = 34700
update Datawarehouse.Mapping.EmailTypeConversionTable set Emailofferid = 525 where catalogcode = 34701
update Datawarehouse.Mapping.EmailTypeConversionTable set Emailofferid = 525 where catalogcode = 34703
update Datawarehouse.Mapping.EmailTypeConversionTable set Emailofferid = 502 where catalogcode = 34790
update Datawarehouse.Mapping.EmailTypeConversionTable set Emailofferid = 502 where catalogcode = 34787
update Datawarehouse.Mapping.EmailTypeConversionTable set Emailofferid = 502 where catalogcode = 34792
update Datawarehouse.Mapping.EmailTypeConversionTable set Emailofferid = 502 where catalogcode = 34805
update Datawarehouse.Mapping.EmailTypeConversionTable set Emailofferid = 502 where catalogcode = 34809
update Datawarehouse.Mapping.EmailTypeConversionTable set Emailofferid = 502 where catalogcode = 34807
update Datawarehouse.Mapping.EmailTypeConversionTable set Emailofferid = 516 where catalogcode = 34888
update Datawarehouse.Mapping.EmailTypeConversionTable set Emailofferid = 516 where catalogcode = 34892
update Datawarehouse.Mapping.EmailTypeConversionTable set Emailofferid = 516 where catalogcode = 34890
update Datawarehouse.Mapping.EmailTypeConversionTable set Emailofferid = 516 where catalogcode = 34908
update Datawarehouse.Mapping.EmailTypeConversionTable set Emailofferid = 516 where catalogcode = 34912
update Datawarehouse.Mapping.EmailTypeConversionTable set Emailofferid = 516 where catalogcode = 34910
update Datawarehouse.Mapping.EmailTypeConversionTable set Emailofferid = 519 where catalogcode = 34926
update Datawarehouse.Mapping.EmailTypeConversionTable set Emailofferid = 519 where catalogcode = 34927
update Datawarehouse.Mapping.EmailTypeConversionTable set Emailofferid = 519 where catalogcode = 34931
update Datawarehouse.Mapping.EmailTypeConversionTable set Emailofferid = 519 where catalogcode = 34929
update Datawarehouse.Mapping.EmailTypeConversionTable set Emailofferid = 519 where catalogcode = 34934
update Datawarehouse.Mapping.EmailTypeConversionTable set Emailofferid = 519 where catalogcode = 34935
update Datawarehouse.Mapping.EmailTypeConversionTable set Emailofferid = 519 where catalogcode = 34937
update Datawarehouse.Mapping.EmailTypeConversionTable set Emailofferid = 519 where catalogcode = 34939
update Datawarehouse.Mapping.EmailTypeConversionTable set Emailofferid = 519 where catalogcode = 34984
update Datawarehouse.Mapping.EmailTypeConversionTable set Emailofferid = 519 where catalogcode = 34986
update Datawarehouse.Mapping.EmailTypeConversionTable set Emailofferid = 535 where catalogcode = 35001
update Datawarehouse.Mapping.EmailTypeConversionTable set Emailofferid = 535 where catalogcode = 35005
update Datawarehouse.Mapping.EmailTypeConversionTable set Emailofferid = 535 where catalogcode = 35008
update Datawarehouse.Mapping.EmailTypeConversionTable set Emailofferid = 535 where catalogcode = 35003
update Datawarehouse.Mapping.EmailTypeConversionTable set Emailofferid = 536 where catalogcode = 35011
update Datawarehouse.Mapping.EmailTypeConversionTable set Emailofferid = 536 where catalogcode = 35009
update Datawarehouse.Mapping.EmailTypeConversionTable set Emailofferid = 536 where catalogcode = 35013
update Datawarehouse.Mapping.EmailTypeConversionTable set Emailofferid = 502 where catalogcode = 35028
update Datawarehouse.Mapping.EmailTypeConversionTable set Emailofferid = 502 where catalogcode = 35023
update Datawarehouse.Mapping.EmailTypeConversionTable set Emailofferid = 502 where catalogcode = 35024
update Datawarehouse.Mapping.EmailTypeConversionTable set Emailofferid = 502 where catalogcode = 35026
update Datawarehouse.Mapping.EmailTypeConversionTable set Emailofferid = 502 where catalogcode = 35016
update Datawarehouse.Mapping.EmailTypeConversionTable set Emailofferid = 502 where catalogcode = 35018
update Datawarehouse.Mapping.EmailTypeConversionTable set Emailofferid = 502 where catalogcode = 35020
update Datawarehouse.Mapping.EmailTypeConversionTable set Emailofferid = 537 where catalogcode = 35043
update Datawarehouse.Mapping.EmailTypeConversionTable set Emailofferid = 537 where catalogcode = 35041
update Datawarehouse.Mapping.EmailTypeConversionTable set Emailofferid = 537 where catalogcode = 35045
update Datawarehouse.Mapping.EmailTypeConversionTable set Emailofferid = 537 where catalogcode = 35048
update Datawarehouse.Mapping.EmailTypeConversionTable set Emailofferid = 537 where catalogcode = 35050
update Datawarehouse.Mapping.EmailTypeConversionTable set Emailofferid = 537 where catalogcode = 35052
update Datawarehouse.Mapping.EmailTypeConversionTable set Emailofferid = 538 where catalogcode = 35033
update Datawarehouse.Mapping.EmailTypeConversionTable set Emailofferid = 538 where catalogcode = 35036
update Datawarehouse.Mapping.EmailTypeConversionTable set Emailofferid = 538 where catalogcode = 35038
update Datawarehouse.Mapping.EmailTypeConversionTable set Emailofferid = 503 where catalogcode = 35136
update Datawarehouse.Mapping.EmailTypeConversionTable set Emailofferid = 503 where catalogcode = 35144
update Datawarehouse.Mapping.EmailTypeConversionTable set Emailofferid = 503 where catalogcode = 35138
update Datawarehouse.Mapping.EmailTypeConversionTable set Emailofferid = 503 where catalogcode = 35140
update Datawarehouse.Mapping.EmailTypeConversionTable set Emailofferid = 502 where catalogcode = 35149
update Datawarehouse.Mapping.EmailTypeConversionTable set Emailofferid = 502 where catalogcode = 35151
update Datawarehouse.Mapping.EmailTypeConversionTable set Emailofferid = 502 where catalogcode = 35153
update Datawarehouse.Mapping.EmailTypeConversionTable set Emailofferid = 502 where catalogcode = 35156
update Datawarehouse.Mapping.EmailTypeConversionTable set Emailofferid = 502 where catalogcode = 35158
update Datawarehouse.Mapping.EmailTypeConversionTable set Emailofferid = 502 where catalogcode = 35160
update Datawarehouse.Mapping.EmailTypeConversionTable set Emailofferid = 539 where catalogcode = 35163
update Datawarehouse.Mapping.EmailTypeConversionTable set Emailofferid = 539 where catalogcode = 35169
update Datawarehouse.Mapping.EmailTypeConversionTable set Emailofferid = 539 where catalogcode = 35166
update Datawarehouse.Mapping.EmailTypeConversionTable set Emailofferid = 502 where catalogcode = 35214
update Datawarehouse.Mapping.EmailTypeConversionTable set Emailofferid = 502 where catalogcode = 35218
update Datawarehouse.Mapping.EmailTypeConversionTable set Emailofferid = 502 where catalogcode = 35216
update Datawarehouse.Mapping.EmailTypeConversionTable set Emailofferid = 526 where catalogcode = 35231
update Datawarehouse.Mapping.EmailTypeConversionTable set Emailofferid = 524 where catalogcode = 35535
update Datawarehouse.Mapping.EmailTypeConversionTable set Emailofferid = 524 where catalogcode = 35229
update Datawarehouse.Mapping.EmailTypeConversionTable set Emailofferid = 526 where catalogcode = 35233
update Datawarehouse.Mapping.EmailTypeConversionTable set Emailofferid = 527 where catalogcode = 35536
update Datawarehouse.Mapping.EmailTypeConversionTable set Emailofferid = 527 where catalogcode = 35236
update Datawarehouse.Mapping.EmailTypeConversionTable set Emailofferid = 528 where catalogcode = 35238
update Datawarehouse.Mapping.EmailTypeConversionTable set Emailofferid = 528 where catalogcode = 35240
update Datawarehouse.Mapping.EmailTypeConversionTable set Emailofferid = 529 where catalogcode = 35243
update Datawarehouse.Mapping.EmailTypeConversionTable set Emailofferid = 529 where catalogcode = 35244
update Datawarehouse.Mapping.EmailTypeConversionTable set Emailofferid = 530 where catalogcode = 35248
update Datawarehouse.Mapping.EmailTypeConversionTable set Emailofferid = 530 where catalogcode = 35246
update Datawarehouse.Mapping.EmailTypeConversionTable set Emailofferid = 540 where catalogcode = 35510
update Datawarehouse.Mapping.EmailTypeConversionTable set Emailofferid = 540 where catalogcode = 35512
update Datawarehouse.Mapping.EmailTypeConversionTable set Emailofferid = 540 where catalogcode = 35527
update Datawarehouse.Mapping.EmailTypeConversionTable set Emailofferid = 503 where catalogcode = 35552
update Datawarehouse.Mapping.EmailTypeConversionTable set Emailofferid = 503 where catalogcode = 35554
update Datawarehouse.Mapping.EmailTypeConversionTable set Emailofferid = 503 where catalogcode = 35556
update Datawarehouse.Mapping.EmailTypeConversionTable set Emailofferid = 503 where catalogcode = 35559
update Datawarehouse.Mapping.EmailTypeConversionTable set Emailofferid = 503 where catalogcode = 35563
update Datawarehouse.Mapping.EmailTypeConversionTable set Emailofferid = 503 where catalogcode = 35561
update Datawarehouse.Mapping.EmailTypeConversionTable set Emailofferid = 541 where catalogcode = 35576
update Datawarehouse.Mapping.EmailTypeConversionTable set Emailofferid = 541 where catalogcode = 35578
update Datawarehouse.Mapping.EmailTypeConversionTable set Emailofferid = 541 where catalogcode = 35574
update Datawarehouse.Mapping.EmailTypeConversionTable set Emailofferid = 541 where catalogcode = 35581
update Datawarehouse.Mapping.EmailTypeConversionTable set Emailofferid = 541 where catalogcode = 35585
update Datawarehouse.Mapping.EmailTypeConversionTable set Emailofferid = 541 where catalogcode = 35583
update Datawarehouse.Mapping.EmailTypeConversionTable set Emailofferid = 542 where catalogcode = 35598
update Datawarehouse.Mapping.EmailTypeConversionTable set Emailofferid = 542 where catalogcode = 35590
update Datawarehouse.Mapping.EmailTypeConversionTable set Emailofferid = 542 where catalogcode = 35588
update Datawarehouse.Mapping.EmailTypeConversionTable set Emailofferid = 542 where catalogcode = 35592
update Datawarehouse.Mapping.EmailTypeConversionTable set Emailofferid = 502 where catalogcode = 35599
update Datawarehouse.Mapping.EmailTypeConversionTable set Emailofferid = 502 where catalogcode = 35601
update Datawarehouse.Mapping.EmailTypeConversionTable set Emailofferid = 502 where catalogcode = 35603
update Datawarehouse.Mapping.EmailTypeConversionTable set Emailofferid = 508 where catalogcode = 35634
update Datawarehouse.Mapping.EmailTypeConversionTable set Emailofferid = 508 where catalogcode = 35636
update Datawarehouse.Mapping.EmailTypeConversionTable set Emailofferid = 508 where catalogcode = 35638
update Datawarehouse.Mapping.EmailTypeConversionTable set Emailofferid = 508 where catalogcode = 35654
update Datawarehouse.Mapping.EmailTypeConversionTable set Emailofferid = 508 where catalogcode = 35656
update Datawarehouse.Mapping.EmailTypeConversionTable set Emailofferid = 508 where catalogcode = 35658
update Datawarehouse.Mapping.EmailTypeConversionTable set Emailofferid = 543 where catalogcode = 35663
update Datawarehouse.Mapping.EmailTypeConversionTable set Emailofferid = 543 where catalogcode = 35661
update Datawarehouse.Mapping.EmailTypeConversionTable set Emailofferid = 543 where catalogcode = 35665
update Datawarehouse.Mapping.EmailTypeConversionTable set Emailofferid = 502 where catalogcode = 35671
update Datawarehouse.Mapping.EmailTypeConversionTable set Emailofferid = 502 where catalogcode = 35669
update Datawarehouse.Mapping.EmailTypeConversionTable set Emailofferid = 502 where catalogcode = 35668
update Datawarehouse.Mapping.EmailTypeConversionTable set Emailofferid = 502 where catalogcode = 35673
update Datawarehouse.Mapping.EmailTypeConversionTable set Emailofferid = 502 where catalogcode = 35676
update Datawarehouse.Mapping.EmailTypeConversionTable set Emailofferid = 502 where catalogcode = 35677
update Datawarehouse.Mapping.EmailTypeConversionTable set Emailofferid = 502 where catalogcode = 35681
update Datawarehouse.Mapping.EmailTypeConversionTable set Emailofferid = 544 where catalogcode = 35689
update Datawarehouse.Mapping.EmailTypeConversionTable set Emailofferid = 544 where catalogcode = 35688
update Datawarehouse.Mapping.EmailTypeConversionTable set Emailofferid = 544 where catalogcode = 35691
update Datawarehouse.Mapping.EmailTypeConversionTable set Emailofferid = 517 where catalogcode = 35693
update Datawarehouse.Mapping.EmailTypeConversionTable set Emailofferid = 517 where catalogcode = 35701
update Datawarehouse.Mapping.EmailTypeConversionTable set Emailofferid = 517 where catalogcode = 35706
update Datawarehouse.Mapping.EmailTypeConversionTable set Emailofferid = 517 where catalogcode = 35704
update Datawarehouse.Mapping.EmailTypeConversionTable set Emailofferid = 517 where catalogcode = 35709
update Datawarehouse.Mapping.EmailTypeConversionTable set Emailofferid = 517 where catalogcode = 35713
update Datawarehouse.Mapping.EmailTypeConversionTable set Emailofferid = 517 where catalogcode = 35711
update Datawarehouse.Mapping.EmailTypeConversionTable set Emailofferid = 524 where catalogcode = 35718
update Datawarehouse.Mapping.EmailTypeConversionTable set Emailofferid = 524 where catalogcode = 35716
update Datawarehouse.Mapping.EmailTypeConversionTable set Emailofferid = 524 where catalogcode = 35720
update Datawarehouse.Mapping.EmailTypeConversionTable set Emailofferid = 524 where catalogcode = 35725
update Datawarehouse.Mapping.EmailTypeConversionTable set Emailofferid = 524 where catalogcode = 35723
update Datawarehouse.Mapping.EmailTypeConversionTable set Emailofferid = 524 where catalogcode = 35727
update Datawarehouse.Mapping.EmailTypeConversionTable set Emailofferid = 524 where catalogcode = 35745
update Datawarehouse.Mapping.EmailTypeConversionTable set Emailofferid = 524 where catalogcode = 35742
update Datawarehouse.Mapping.EmailTypeConversionTable set Emailofferid = 524 where catalogcode = 35747
update Datawarehouse.Mapping.EmailTypeConversionTable set Emailofferid = 524 where catalogcode = 35750
update Datawarehouse.Mapping.EmailTypeConversionTable set Emailofferid = 524 where catalogcode = 35754
update Datawarehouse.Mapping.EmailTypeConversionTable set Emailofferid = 524 where catalogcode = 35752
update Datawarehouse.Mapping.EmailTypeConversionTable set Emailofferid = 502 where catalogcode = 36285
update Datawarehouse.Mapping.EmailTypeConversionTable set Emailofferid = 502 where catalogcode = 36283
update Datawarehouse.Mapping.EmailTypeConversionTable set Emailofferid = 502 where catalogcode = 36287
update Datawarehouse.Mapping.EmailTypeConversionTable set Emailofferid = 502 where catalogcode = 36292
update Datawarehouse.Mapping.EmailTypeConversionTable set Emailofferid = 502 where catalogcode = 36290
update Datawarehouse.Mapping.EmailTypeConversionTable set Emailofferid = 502 where catalogcode = 36294
update Datawarehouse.Mapping.EmailTypeConversionTable set Emailofferid = 545 where catalogcode = 36338
update Datawarehouse.Mapping.EmailTypeConversionTable set Emailofferid = 545 where catalogcode = 36337
update Datawarehouse.Mapping.EmailTypeConversionTable set Emailofferid = 545 where catalogcode = 36336
update Datawarehouse.Mapping.EmailTypeConversionTable set Emailofferid = 545 where catalogcode = 36311
update Datawarehouse.Mapping.EmailTypeConversionTable set Emailofferid = 545 where catalogcode = 36312
update Datawarehouse.Mapping.EmailTypeConversionTable set Emailofferid = 545 where catalogcode = 36335
update Datawarehouse.Mapping.EmailTypeConversionTable set Emailofferid = 545 where catalogcode = 36343
update Datawarehouse.Mapping.EmailTypeConversionTable set Emailofferid = 545 where catalogcode = 36349
update Datawarehouse.Mapping.EmailTypeConversionTable set Emailofferid = 545 where catalogcode = 36313
update Datawarehouse.Mapping.EmailTypeConversionTable set Emailofferid = 545 where catalogcode = 36319
update Datawarehouse.Mapping.EmailTypeConversionTable set Emailofferid = 545 where catalogcode = 36348
update Datawarehouse.Mapping.EmailTypeConversionTable set Emailofferid = 545 where catalogcode = 36315
update Datawarehouse.Mapping.EmailTypeConversionTable set Emailofferid = 545 where catalogcode = 36314
update Datawarehouse.Mapping.EmailTypeConversionTable set Emailofferid = 545 where catalogcode = 36339
update Datawarehouse.Mapping.EmailTypeConversionTable set Emailofferid = 545 where catalogcode = 36318
update Datawarehouse.Mapping.EmailTypeConversionTable set Emailofferid = 545 where catalogcode = 36345
update Datawarehouse.Mapping.EmailTypeConversionTable set Emailofferid = 545 where catalogcode = 36321
update Datawarehouse.Mapping.EmailTypeConversionTable set Emailofferid = 545 where catalogcode = 36350
update Datawarehouse.Mapping.EmailTypeConversionTable set Emailofferid = 545 where catalogcode = 36351
update Datawarehouse.Mapping.EmailTypeConversionTable set Emailofferid = 545 where catalogcode = 36352
update Datawarehouse.Mapping.EmailTypeConversionTable set Emailofferid = 545 where catalogcode = 36356
update Datawarehouse.Mapping.EmailTypeConversionTable set Emailofferid = 545 where catalogcode = 36358
update Datawarehouse.Mapping.EmailTypeConversionTable set Emailofferid = 545 where catalogcode = 36355
update Datawarehouse.Mapping.EmailTypeConversionTable set Emailofferid = 545 where catalogcode = 36342
update Datawarehouse.Mapping.EmailTypeConversionTable set Emailofferid = 545 where catalogcode = 36409
update Datawarehouse.Mapping.EmailTypeConversionTable set Emailofferid = 545 where catalogcode = 36385
update Datawarehouse.Mapping.EmailTypeConversionTable set Emailofferid = 545 where catalogcode = 36421
update Datawarehouse.Mapping.EmailTypeConversionTable set Emailofferid = 545 where catalogcode = 36416
update Datawarehouse.Mapping.EmailTypeConversionTable set Emailofferid = 545 where catalogcode = 36429
update Datawarehouse.Mapping.EmailTypeConversionTable set Emailofferid = 545 where catalogcode = 36422
update Datawarehouse.Mapping.EmailTypeConversionTable set Emailofferid = 545 where catalogcode = 36384
update Datawarehouse.Mapping.EmailTypeConversionTable set Emailofferid = 545 where catalogcode = 36387
update Datawarehouse.Mapping.EmailTypeConversionTable set Emailofferid = 545 where catalogcode = 36386
update Datawarehouse.Mapping.EmailTypeConversionTable set Emailofferid = 545 where catalogcode = 36411
update Datawarehouse.Mapping.EmailTypeConversionTable set Emailofferid = 545 where catalogcode = 36391
update Datawarehouse.Mapping.EmailTypeConversionTable set Emailofferid = 545 where catalogcode = 36410
update Datawarehouse.Mapping.EmailTypeConversionTable set Emailofferid = 545 where catalogcode = 36388
update Datawarehouse.Mapping.EmailTypeConversionTable set Emailofferid = 545 where catalogcode = 36392
update Datawarehouse.Mapping.EmailTypeConversionTable set Emailofferid = 545 where catalogcode = 36428
update Datawarehouse.Mapping.EmailTypeConversionTable set Emailofferid = 545 where catalogcode = 36424
update Datawarehouse.Mapping.EmailTypeConversionTable set Emailofferid = 545 where catalogcode = 36418
update Datawarehouse.Mapping.EmailTypeConversionTable set Emailofferid = 545 where catalogcode = 36394
update Datawarehouse.Mapping.EmailTypeConversionTable set Emailofferid = 545 where catalogcode = 36425
update Datawarehouse.Mapping.EmailTypeConversionTable set Emailofferid = 545 where catalogcode = 36412
update Datawarehouse.Mapping.EmailTypeConversionTable set Emailofferid = 545 where catalogcode = 36423
update Datawarehouse.Mapping.EmailTypeConversionTable set Emailofferid = 545 where catalogcode = 36408
update Datawarehouse.Mapping.EmailTypeConversionTable set Emailofferid = 545 where catalogcode = 36431
update Datawarehouse.Mapping.EmailTypeConversionTable set Emailofferid = 545 where catalogcode = 36415
update Datawarehouse.Mapping.EmailTypeConversionTable set Emailofferid = 546 where catalogcode = 36490
update Datawarehouse.Mapping.EmailTypeConversionTable set Emailofferid = 546 where catalogcode = 36297
update Datawarehouse.Mapping.EmailTypeConversionTable set Emailofferid = 547 where catalogcode = 36299
update Datawarehouse.Mapping.EmailTypeConversionTable set Emailofferid = 547 where catalogcode = 36301
update Datawarehouse.Mapping.EmailTypeConversionTable set Emailofferid = 525 where catalogcode = 36502
update Datawarehouse.Mapping.EmailTypeConversionTable set Emailofferid = 525 where catalogcode = 36504
update Datawarehouse.Mapping.EmailTypeConversionTable set Emailofferid = 525 where catalogcode = 36506
update Datawarehouse.Mapping.EmailTypeConversionTable set Emailofferid = 525 where catalogcode = 36509
update Datawarehouse.Mapping.EmailTypeConversionTable set Emailofferid = 525 where catalogcode = 36511
update Datawarehouse.Mapping.EmailTypeConversionTable set Emailofferid = 525 where catalogcode = 36513
update Datawarehouse.Mapping.EmailTypeConversionTable set Emailofferid = 526 where catalogcode = 36521
update Datawarehouse.Mapping.EmailTypeConversionTable set Emailofferid = 536 where catalogcode = 36519
update Datawarehouse.Mapping.EmailTypeConversionTable set Emailofferid = 526 where catalogcode = 36523
update Datawarehouse.Mapping.EmailTypeConversionTable set Emailofferid = 502 where catalogcode = 36546
update Datawarehouse.Mapping.EmailTypeConversionTable set Emailofferid = 502 where catalogcode = 36544
update Datawarehouse.Mapping.EmailTypeConversionTable set Emailofferid = 502 where catalogcode = 36548
update Datawarehouse.Mapping.EmailTypeConversionTable set Emailofferid = 502 where catalogcode = 36589
update Datawarehouse.Mapping.EmailTypeConversionTable set Emailofferid = 502 where catalogcode = 36587
update Datawarehouse.Mapping.EmailTypeConversionTable set Emailofferid = 502 where catalogcode = 36591
update Datawarehouse.Mapping.EmailTypeConversionTable set Emailofferid = 541 where catalogcode = 36554
update Datawarehouse.Mapping.EmailTypeConversionTable set Emailofferid = 541 where catalogcode = 36551
update Datawarehouse.Mapping.EmailTypeConversionTable set Emailofferid = 541 where catalogcode = 36552
update Datawarehouse.Mapping.EmailTypeConversionTable set Emailofferid = 541 where catalogcode = 36556
update Datawarehouse.Mapping.EmailTypeConversionTable set Emailofferid = 541 where catalogcode = 36560
update Datawarehouse.Mapping.EmailTypeConversionTable set Emailofferid = 541 where catalogcode = 36559
update Datawarehouse.Mapping.EmailTypeConversionTable set Emailofferid = 541 where catalogcode = 36562
update Datawarehouse.Mapping.EmailTypeConversionTable set Emailofferid = 541 where catalogcode = 36564
update Datawarehouse.Mapping.EmailTypeConversionTable set Emailofferid = 502 where catalogcode = 36579
update Datawarehouse.Mapping.EmailTypeConversionTable set Emailofferid = 502 where catalogcode = 36581
update Datawarehouse.Mapping.EmailTypeConversionTable set Emailofferid = 502 where catalogcode = 36583
update Datawarehouse.Mapping.EmailTypeConversionTable set Emailofferid = 548 where catalogcode = 36597
update Datawarehouse.Mapping.EmailTypeConversionTable set Emailofferid = 548 where catalogcode = 36595
update Datawarehouse.Mapping.EmailTypeConversionTable set Emailofferid = 548 where catalogcode = 36599
update Datawarehouse.Mapping.EmailTypeConversionTable set Emailofferid = 549 where catalogcode = 36611
update Datawarehouse.Mapping.EmailTypeConversionTable set Emailofferid = 549 where catalogcode = 36609
update Datawarehouse.Mapping.EmailTypeConversionTable set Emailofferid = 549 where catalogcode = 36613
update Datawarehouse.Mapping.EmailTypeConversionTable set Emailofferid = 549 where catalogcode = 36618
update Datawarehouse.Mapping.EmailTypeConversionTable set Emailofferid = 549 where catalogcode = 36616
update Datawarehouse.Mapping.EmailTypeConversionTable set Emailofferid = 549 where catalogcode = 36620
update Datawarehouse.Mapping.EmailTypeConversionTable set Emailofferid = 550 where catalogcode = 36625
update Datawarehouse.Mapping.EmailTypeConversionTable set Emailofferid = 550 where catalogcode = 36623
update Datawarehouse.Mapping.EmailTypeConversionTable set Emailofferid = 550 where catalogcode = 36627
update Datawarehouse.Mapping.EmailTypeConversionTable set Emailofferid = 550 where catalogcode = 36635
update Datawarehouse.Mapping.EmailTypeConversionTable set Emailofferid = 550 where catalogcode = 36637
update Datawarehouse.Mapping.EmailTypeConversionTable set Emailofferid = 550 where catalogcode = 36639
update Datawarehouse.Mapping.EmailTypeConversionTable set Emailofferid = 551 where catalogcode = 36723
update Datawarehouse.Mapping.EmailTypeConversionTable set Emailofferid = 551 where catalogcode = 36721
update Datawarehouse.Mapping.EmailTypeConversionTable set Emailofferid = 551 where catalogcode = 36725
update Datawarehouse.Mapping.EmailTypeConversionTable set Emailofferid = 551 where catalogcode = 36730
update Datawarehouse.Mapping.EmailTypeConversionTable set Emailofferid = 551 where catalogcode = 36728
update Datawarehouse.Mapping.EmailTypeConversionTable set Emailofferid = 551 where catalogcode = 36732
update Datawarehouse.Mapping.EmailTypeConversionTable set Emailofferid = 539 where catalogcode = 36739
update Datawarehouse.Mapping.EmailTypeConversionTable set Emailofferid = 539 where catalogcode = 36737
update Datawarehouse.Mapping.EmailTypeConversionTable set Emailofferid = 539 where catalogcode = 36741
update Datawarehouse.Mapping.EmailTypeConversionTable set Emailofferid = 502 where catalogcode = 36794
update Datawarehouse.Mapping.EmailTypeConversionTable set Emailofferid = 502 where catalogcode = 36792
update Datawarehouse.Mapping.EmailTypeConversionTable set Emailofferid = 502 where catalogcode = 36796
update Datawarehouse.Mapping.EmailTypeConversionTable set Emailofferid = 504 where catalogcode = 36835
update Datawarehouse.Mapping.EmailTypeConversionTable set Emailofferid = 504 where catalogcode = 36837
update Datawarehouse.Mapping.EmailTypeConversionTable set Emailofferid = 504 where catalogcode = 36839
update Datawarehouse.Mapping.EmailTypeConversionTable set Emailofferid = 525 where catalogcode = 36850
update Datawarehouse.Mapping.EmailTypeConversionTable set Emailofferid = 525 where catalogcode = 36848
update Datawarehouse.Mapping.EmailTypeConversionTable set Emailofferid = 525 where catalogcode = 36852
update Datawarehouse.Mapping.EmailTypeConversionTable set Emailofferid = 525 where catalogcode = 37125
update Datawarehouse.Mapping.EmailTypeConversionTable set Emailofferid = 525 where catalogcode = 37127
update Datawarehouse.Mapping.EmailTypeConversionTable set Emailofferid = 525 where catalogcode = 37129
update Datawarehouse.Mapping.EmailTypeConversionTable set Emailofferid = 552 where catalogcode = 37140
update Datawarehouse.Mapping.EmailTypeConversionTable set Emailofferid = 552 where catalogcode = 37138
update Datawarehouse.Mapping.EmailTypeConversionTable set Emailofferid = 552 where catalogcode = 37142
update Datawarehouse.Mapping.EmailTypeConversionTable set Emailofferid = 553 where catalogcode = 37161
update Datawarehouse.Mapping.EmailTypeConversionTable set Emailofferid = 553 where catalogcode = 37164
update Datawarehouse.Mapping.EmailTypeConversionTable set Emailofferid = 553 where catalogcode = 37166
update Datawarehouse.Mapping.EmailTypeConversionTable set Emailofferid = 554 where catalogcode = 37172
update Datawarehouse.Mapping.EmailTypeConversionTable set Emailofferid = 554 where catalogcode = 37170
update Datawarehouse.Mapping.EmailTypeConversionTable set Emailofferid = 554 where catalogcode = 37174
update Datawarehouse.Mapping.EmailTypeConversionTable set Emailofferid = 554 where catalogcode = 37178
update Datawarehouse.Mapping.EmailTypeConversionTable set Emailofferid = 554 where catalogcode = 37180
update Datawarehouse.Mapping.EmailTypeConversionTable set Emailofferid = 554 where catalogcode = 37182
update Datawarehouse.Mapping.EmailTypeConversionTable set Emailofferid = 547 where catalogcode = 37186
update Datawarehouse.Mapping.EmailTypeConversionTable set Emailofferid = 547 where catalogcode = 37188
update Datawarehouse.Mapping.EmailTypeConversionTable set Emailofferid = 547 where catalogcode = 37190
update Datawarehouse.Mapping.EmailTypeConversionTable set Emailofferid = 547 where catalogcode = 37194
update Datawarehouse.Mapping.EmailTypeConversionTable set Emailofferid = 547 where catalogcode = 37196
update Datawarehouse.Mapping.EmailTypeConversionTable set Emailofferid = 547 where catalogcode = 37198
update Datawarehouse.Mapping.EmailTypeConversionTable set Emailofferid = 555 where catalogcode = 37392
update Datawarehouse.Mapping.EmailTypeConversionTable set Emailofferid = 555 where catalogcode = 37396
update Datawarehouse.Mapping.EmailTypeConversionTable set Emailofferid = 555 where catalogcode = 37394
update Datawarehouse.Mapping.EmailTypeConversionTable set Emailofferid = 556 where catalogcode = 37666
update Datawarehouse.Mapping.EmailTypeConversionTable set Emailofferid = 556 where catalogcode = 37663
update Datawarehouse.Mapping.EmailTypeConversionTable set Emailofferid = 556 where catalogcode = 37668
update Datawarehouse.Mapping.EmailTypeConversionTable set Emailofferid = 556 where catalogcode = 37674
update Datawarehouse.Mapping.EmailTypeConversionTable set Emailofferid = 556 where catalogcode = 37676
update Datawarehouse.Mapping.EmailTypeConversionTable set Emailofferid = 556 where catalogcode = 37678
update Datawarehouse.Mapping.EmailTypeConversionTable set Emailofferid = 556 where catalogcode = 37682
update Datawarehouse.Mapping.EmailTypeConversionTable set Emailofferid = 556 where catalogcode = 37684
update Datawarehouse.Mapping.EmailTypeConversionTable set Emailofferid = 556 where catalogcode = 37686
update Datawarehouse.Mapping.EmailTypeConversionTable set Emailofferid = 541 where catalogcode = 37700
update Datawarehouse.Mapping.EmailTypeConversionTable set Emailofferid = 541 where catalogcode = 37696
update Datawarehouse.Mapping.EmailTypeConversionTable set Emailofferid = 541 where catalogcode = 37698
update Datawarehouse.Mapping.EmailTypeConversionTable set Emailofferid = 541 where catalogcode = 37704
update Datawarehouse.Mapping.EmailTypeConversionTable set Emailofferid = 541 where catalogcode = 37708
update Datawarehouse.Mapping.EmailTypeConversionTable set Emailofferid = 541 where catalogcode = 37706
update Datawarehouse.Mapping.EmailTypeConversionTable set Emailofferid = 508 where catalogcode = 37722
update Datawarehouse.Mapping.EmailTypeConversionTable set Emailofferid = 508 where catalogcode = 37726
update Datawarehouse.Mapping.EmailTypeConversionTable set Emailofferid = 508 where catalogcode = 37724
update Datawarehouse.Mapping.EmailTypeConversionTable set Emailofferid = 557 where catalogcode = 37732
update Datawarehouse.Mapping.EmailTypeConversionTable set Emailofferid = 557 where catalogcode = 37730
update Datawarehouse.Mapping.EmailTypeConversionTable set Emailofferid = 557 where catalogcode = 37735
update Datawarehouse.Mapping.EmailTypeConversionTable set Emailofferid = 557 where catalogcode = 37742
update Datawarehouse.Mapping.EmailTypeConversionTable set Emailofferid = 557 where catalogcode = 37744
update Datawarehouse.Mapping.EmailTypeConversionTable set Emailofferid = 557 where catalogcode = 37740
update Datawarehouse.Mapping.EmailTypeConversionTable set Emailofferid = 502 where catalogcode = 37762
update Datawarehouse.Mapping.EmailTypeConversionTable set Emailofferid = 502 where catalogcode = 37760
update Datawarehouse.Mapping.EmailTypeConversionTable set Emailofferid = 502 where catalogcode = 37764
update Datawarehouse.Mapping.EmailTypeConversionTable set Emailofferid = 502 where catalogcode = 37768
update Datawarehouse.Mapping.EmailTypeConversionTable set Emailofferid = 502 where catalogcode = 37770
update Datawarehouse.Mapping.EmailTypeConversionTable set Emailofferid = 502 where catalogcode = 37772
update Datawarehouse.Mapping.EmailTypeConversionTable set Emailofferid = 502 where catalogcode = 37779
update Datawarehouse.Mapping.EmailTypeConversionTable set Emailofferid = 502 where catalogcode = 37783
update Datawarehouse.Mapping.EmailTypeConversionTable set Emailofferid = 502 where catalogcode = 37781
update Datawarehouse.Mapping.EmailTypeConversionTable set Emailofferid = 502 where catalogcode = 37804
update Datawarehouse.Mapping.EmailTypeConversionTable set Emailofferid = 502 where catalogcode = 37806
update Datawarehouse.Mapping.EmailTypeConversionTable set Emailofferid = 502 where catalogcode = 37808
update Datawarehouse.Mapping.EmailTypeConversionTable set Emailofferid = 515 where catalogcode = 37787
update Datawarehouse.Mapping.EmailTypeConversionTable set Emailofferid = 515 where catalogcode = 37789
update Datawarehouse.Mapping.EmailTypeConversionTable set Emailofferid = 515 where catalogcode = 37791
update Datawarehouse.Mapping.EmailTypeConversionTable set Emailofferid = 515 where catalogcode = 37795
update Datawarehouse.Mapping.EmailTypeConversionTable set Emailofferid = 515 where catalogcode = 37799
update Datawarehouse.Mapping.EmailTypeConversionTable set Emailofferid = 515 where catalogcode = 37797
update Datawarehouse.Mapping.EmailTypeConversionTable set Emailofferid = 525 where catalogcode = 37863
update Datawarehouse.Mapping.EmailTypeConversionTable set Emailofferid = 525 where catalogcode = 37864
update Datawarehouse.Mapping.EmailTypeConversionTable set Emailofferid = 525 where catalogcode = 37883
update Datawarehouse.Mapping.EmailTypeConversionTable set Emailofferid = 525 where catalogcode = 37878
update Datawarehouse.Mapping.EmailTypeConversionTable set Emailofferid = 525 where catalogcode = 37866
update Datawarehouse.Mapping.EmailTypeConversionTable set Emailofferid = 525 where catalogcode = 37838
update Datawarehouse.Mapping.EmailTypeConversionTable set Emailofferid = 525 where catalogcode = 37846
update Datawarehouse.Mapping.EmailTypeConversionTable set Emailofferid = 525 where catalogcode = 37875
update Datawarehouse.Mapping.EmailTypeConversionTable set Emailofferid = 525 where catalogcode = 37839
update Datawarehouse.Mapping.EmailTypeConversionTable set Emailofferid = 525 where catalogcode = 37867
update Datawarehouse.Mapping.EmailTypeConversionTable set Emailofferid = 525 where catalogcode = 37865
update Datawarehouse.Mapping.EmailTypeConversionTable set Emailofferid = 525 where catalogcode = 37844
update Datawarehouse.Mapping.EmailTypeConversionTable set Emailofferid = 525 where catalogcode = 37868
update Datawarehouse.Mapping.EmailTypeConversionTable set Emailofferid = 525 where catalogcode = 37841
update Datawarehouse.Mapping.EmailTypeConversionTable set Emailofferid = 525 where catalogcode = 37843
update Datawarehouse.Mapping.EmailTypeConversionTable set Emailofferid = 525 where catalogcode = 37840
update Datawarehouse.Mapping.EmailTypeConversionTable set Emailofferid = 525 where catalogcode = 37885
update Datawarehouse.Mapping.EmailTypeConversionTable set Emailofferid = 525 where catalogcode = 37845
update Datawarehouse.Mapping.EmailTypeConversionTable set Emailofferid = 525 where catalogcode = 37842
update Datawarehouse.Mapping.EmailTypeConversionTable set Emailofferid = 525 where catalogcode = 37879
update Datawarehouse.Mapping.EmailTypeConversionTable set Emailofferid = 525 where catalogcode = 37848
update Datawarehouse.Mapping.EmailTypeConversionTable set Emailofferid = 525 where catalogcode = 37862
update Datawarehouse.Mapping.EmailTypeConversionTable set Emailofferid = 525 where catalogcode = 37876
update Datawarehouse.Mapping.EmailTypeConversionTable set Emailofferid = 525 where catalogcode = 37877
update Datawarehouse.Mapping.EmailTypeConversionTable set Emailofferid = 525 where catalogcode = 37881
update Datawarehouse.Mapping.EmailTypeConversionTable set Emailofferid = 525 where catalogcode = 37880
update Datawarehouse.Mapping.EmailTypeConversionTable set Emailofferid = 525 where catalogcode = 37872
update Datawarehouse.Mapping.EmailTypeConversionTable set Emailofferid = 525 where catalogcode = 37870
update Datawarehouse.Mapping.EmailTypeConversionTable set Emailofferid = 525 where catalogcode = 37882
update Datawarehouse.Mapping.EmailTypeConversionTable set Emailofferid = 525 where catalogcode = 37869
update Datawarehouse.Mapping.EmailTypeConversionTable set Emailofferid = 525 where catalogcode = 37968
update Datawarehouse.Mapping.EmailTypeConversionTable set Emailofferid = 525 where catalogcode = 37960
update Datawarehouse.Mapping.EmailTypeConversionTable set Emailofferid = 525 where catalogcode = 37924
update Datawarehouse.Mapping.EmailTypeConversionTable set Emailofferid = 525 where catalogcode = 37930
update Datawarehouse.Mapping.EmailTypeConversionTable set Emailofferid = 525 where catalogcode = 37931
update Datawarehouse.Mapping.EmailTypeConversionTable set Emailofferid = 525 where catalogcode = 37964
update Datawarehouse.Mapping.EmailTypeConversionTable set Emailofferid = 525 where catalogcode = 37923
update Datawarehouse.Mapping.EmailTypeConversionTable set Emailofferid = 525 where catalogcode = 37925
update Datawarehouse.Mapping.EmailTypeConversionTable set Emailofferid = 525 where catalogcode = 37926
update Datawarehouse.Mapping.EmailTypeConversionTable set Emailofferid = 525 where catalogcode = 37948
update Datawarehouse.Mapping.EmailTypeConversionTable set Emailofferid = 525 where catalogcode = 37949
update Datawarehouse.Mapping.EmailTypeConversionTable set Emailofferid = 525 where catalogcode = 37927
update Datawarehouse.Mapping.EmailTypeConversionTable set Emailofferid = 525 where catalogcode = 37963
update Datawarehouse.Mapping.EmailTypeConversionTable set Emailofferid = 525 where catalogcode = 37952
update Datawarehouse.Mapping.EmailTypeConversionTable set Emailofferid = 525 where catalogcode = 37929
update Datawarehouse.Mapping.EmailTypeConversionTable set Emailofferid = 525 where catalogcode = 37962
update Datawarehouse.Mapping.EmailTypeConversionTable set Emailofferid = 525 where catalogcode = 37928
update Datawarehouse.Mapping.EmailTypeConversionTable set Emailofferid = 525 where catalogcode = 37950
update Datawarehouse.Mapping.EmailTypeConversionTable set Emailofferid = 525 where catalogcode = 37955
update Datawarehouse.Mapping.EmailTypeConversionTable set Emailofferid = 525 where catalogcode = 37967
update Datawarehouse.Mapping.EmailTypeConversionTable set Emailofferid = 525 where catalogcode = 37961
update Datawarehouse.Mapping.EmailTypeConversionTable set Emailofferid = 525 where catalogcode = 37957
update Datawarehouse.Mapping.EmailTypeConversionTable set Emailofferid = 525 where catalogcode = 37953
update Datawarehouse.Mapping.EmailTypeConversionTable set Emailofferid = 525 where catalogcode = 37970
update Datawarehouse.Mapping.EmailTypeConversionTable set Emailofferid = 525 where catalogcode = 37951
update Datawarehouse.Mapping.EmailTypeConversionTable set Emailofferid = 525 where catalogcode = 37947
update Datawarehouse.Mapping.EmailTypeConversionTable set Emailofferid = 525 where catalogcode = 37965
update Datawarehouse.Mapping.EmailTypeConversionTable set Emailofferid = 525 where catalogcode = 37966
update Datawarehouse.Mapping.EmailTypeConversionTable set Emailofferid = 525 where catalogcode = 37954
update Datawarehouse.Mapping.EmailTypeConversionTable set Emailofferid = 525 where catalogcode = 37933
update Datawarehouse.Mapping.EmailTypeConversionTable set Emailofferid = 502 where catalogcode = 38009
update Datawarehouse.Mapping.EmailTypeConversionTable set Emailofferid = 502 where catalogcode = 38013
update Datawarehouse.Mapping.EmailTypeConversionTable set Emailofferid = 502 where catalogcode = 38011
update Datawarehouse.Mapping.EmailTypeConversionTable set Emailofferid = 538 where catalogcode = 38033
update Datawarehouse.Mapping.EmailTypeConversionTable set Emailofferid = 538 where catalogcode = 38037
update Datawarehouse.Mapping.EmailTypeConversionTable set Emailofferid = 538 where catalogcode = 38035
update Datawarehouse.Mapping.EmailTypeConversionTable set Emailofferid = 520 where catalogcode = 38043
update Datawarehouse.Mapping.EmailTypeConversionTable set Emailofferid = 520 where catalogcode = 38041
update Datawarehouse.Mapping.EmailTypeConversionTable set Emailofferid = 520 where catalogcode = 38045
update Datawarehouse.Mapping.EmailTypeConversionTable set Emailofferid = 520 where catalogcode = 38050
update Datawarehouse.Mapping.EmailTypeConversionTable set Emailofferid = 520 where catalogcode = 38055
update Datawarehouse.Mapping.EmailTypeConversionTable set Emailofferid = 520 where catalogcode = 38052
update Datawarehouse.Mapping.EmailTypeConversionTable set Emailofferid = 541 where catalogcode = 38064
update Datawarehouse.Mapping.EmailTypeConversionTable set Emailofferid = 541 where catalogcode = 38059
update Datawarehouse.Mapping.EmailTypeConversionTable set Emailofferid = 541 where catalogcode = 38062
update Datawarehouse.Mapping.EmailTypeConversionTable set Emailofferid = 517 where catalogcode = 38069
update Datawarehouse.Mapping.EmailTypeConversionTable set Emailofferid = 517 where catalogcode = 38071
update Datawarehouse.Mapping.EmailTypeConversionTable set Emailofferid = 517 where catalogcode = 38073
update Datawarehouse.Mapping.EmailTypeConversionTable set Emailofferid = 517 where catalogcode = 38079
update Datawarehouse.Mapping.EmailTypeConversionTable set Emailofferid = 517 where catalogcode = 38081
update Datawarehouse.Mapping.EmailTypeConversionTable set Emailofferid = 517 where catalogcode = 38083
update Datawarehouse.Mapping.EmailTypeConversionTable set Emailofferid = 534 where catalogcode = 38108
update Datawarehouse.Mapping.EmailTypeConversionTable set Emailofferid = 533 where catalogcode = 38110
update Datawarehouse.Mapping.EmailTypeConversionTable set Emailofferid = 533 where catalogcode = 38112
update Datawarehouse.Mapping.EmailTypeConversionTable set Emailofferid = 534 where catalogcode = 38116
update Datawarehouse.Mapping.EmailTypeConversionTable set Emailofferid = 533 where catalogcode = 38120
update Datawarehouse.Mapping.EmailTypeConversionTable set Emailofferid = 533 where catalogcode = 38118
update Datawarehouse.Mapping.EmailTypeConversionTable set Emailofferid = 558 where catalogcode = 38128
update Datawarehouse.Mapping.EmailTypeConversionTable set Emailofferid = 558 where catalogcode = 38124
update Datawarehouse.Mapping.EmailTypeConversionTable set Emailofferid = 558 where catalogcode = 38126
update Datawarehouse.Mapping.EmailTypeConversionTable set Emailofferid = 558 where catalogcode = 38146
update Datawarehouse.Mapping.EmailTypeConversionTable set Emailofferid = 558 where catalogcode = 38132
update Datawarehouse.Mapping.EmailTypeConversionTable set Emailofferid = 558 where catalogcode = 38148
update Datawarehouse.Mapping.EmailTypeConversionTable set Emailofferid = 534 where catalogcode = 38496
update Datawarehouse.Mapping.EmailTypeConversionTable set Emailofferid = 534 where catalogcode = 38152
update Datawarehouse.Mapping.EmailTypeConversionTable set Emailofferid = 533 where catalogcode = 38500
update Datawarehouse.Mapping.EmailTypeConversionTable set Emailofferid = 533 where catalogcode = 38156
update Datawarehouse.Mapping.EmailTypeConversionTable set Emailofferid = 533 where catalogcode = 38154
update Datawarehouse.Mapping.EmailTypeConversionTable set Emailofferid = 533 where catalogcode = 38498
update Datawarehouse.Mapping.EmailTypeConversionTable set Emailofferid = 559 where catalogcode = 38160
update Datawarehouse.Mapping.EmailTypeConversionTable set Emailofferid = 559 where catalogcode = 38164
update Datawarehouse.Mapping.EmailTypeConversionTable set Emailofferid = 559 where catalogcode = 38162
update Datawarehouse.Mapping.EmailTypeConversionTable set Emailofferid = 560 where catalogcode = 38450
update Datawarehouse.Mapping.EmailTypeConversionTable set Emailofferid = 504 where catalogcode = 38454
update Datawarehouse.Mapping.EmailTypeConversionTable set Emailofferid = 504 where catalogcode = 38452
update Datawarehouse.Mapping.EmailTypeConversionTable set Emailofferid = 561 where catalogcode = 38466
update Datawarehouse.Mapping.EmailTypeConversionTable set Emailofferid = 561 where catalogcode = 38468
update Datawarehouse.Mapping.EmailTypeConversionTable set Emailofferid = 561 where catalogcode = 38470
update Datawarehouse.Mapping.EmailTypeConversionTable set Emailofferid = 560 where catalogcode = 38474
update Datawarehouse.Mapping.EmailTypeConversionTable set Emailofferid = 504 where catalogcode = 38476
update Datawarehouse.Mapping.EmailTypeConversionTable set Emailofferid = 504 where catalogcode = 38478
update Datawarehouse.Mapping.EmailTypeConversionTable set Emailofferid = 560 where catalogcode = 38482
update Datawarehouse.Mapping.EmailTypeConversionTable set Emailofferid = 504 where catalogcode = 38484
update Datawarehouse.Mapping.EmailTypeConversionTable set Emailofferid = 504 where catalogcode = 38486
update Datawarehouse.Mapping.EmailTypeConversionTable set Emailofferid = 562 where catalogcode = 38682
update Datawarehouse.Mapping.EmailTypeConversionTable set Emailofferid = 563 where catalogcode = 38684
update Datawarehouse.Mapping.EmailTypeConversionTable set Emailofferid = 563 where catalogcode = 38686
update Datawarehouse.Mapping.EmailTypeConversionTable set Emailofferid = 562 where catalogcode = 38690
update Datawarehouse.Mapping.EmailTypeConversionTable set Emailofferid = 563 where catalogcode = 38692
update Datawarehouse.Mapping.EmailTypeConversionTable set Emailofferid = 563 where catalogcode = 38694
update Datawarehouse.Mapping.EmailTypeConversionTable set Emailofferid = 502 where catalogcode = 38706
update Datawarehouse.Mapping.EmailTypeConversionTable set Emailofferid = 502 where catalogcode = 38708
update Datawarehouse.Mapping.EmailTypeConversionTable set Emailofferid = 502 where catalogcode = 38710
update Datawarehouse.Mapping.EmailTypeConversionTable set Emailofferid = 545 where catalogcode = 38714
update Datawarehouse.Mapping.EmailTypeConversionTable set Emailofferid = 545 where catalogcode = 38716
update Datawarehouse.Mapping.EmailTypeConversionTable set Emailofferid = 545 where catalogcode = 38718
update Datawarehouse.Mapping.EmailTypeConversionTable set Emailofferid = 545 where catalogcode = 38722
update Datawarehouse.Mapping.EmailTypeConversionTable set Emailofferid = 545 where catalogcode = 38724
update Datawarehouse.Mapping.EmailTypeConversionTable set Emailofferid = 545 where catalogcode = 38726
update Datawarehouse.Mapping.EmailTypeConversionTable set Emailofferid = 564 where catalogcode = 38794
update Datawarehouse.Mapping.EmailTypeConversionTable set Emailofferid = 533 where catalogcode = 38796
update Datawarehouse.Mapping.EmailTypeConversionTable set Emailofferid = 533 where catalogcode = 38798
update Datawarehouse.Mapping.EmailTypeConversionTable set Emailofferid = 564 where catalogcode = 38802
update Datawarehouse.Mapping.EmailTypeConversionTable set Emailofferid = 533 where catalogcode = 38804
update Datawarehouse.Mapping.EmailTypeConversionTable set Emailofferid = 533 where catalogcode = 38806
update Datawarehouse.Mapping.EmailTypeConversionTable set Emailofferid = 502 where catalogcode = 38814
update Datawarehouse.Mapping.EmailTypeConversionTable set Emailofferid = 502 where catalogcode = 38816
update Datawarehouse.Mapping.EmailTypeConversionTable set Emailofferid = 502 where catalogcode = 38818
update Datawarehouse.Mapping.EmailTypeConversionTable set Emailofferid = 565 where catalogcode = 38833
update Datawarehouse.Mapping.EmailTypeConversionTable set Emailofferid = 565 where catalogcode = 38835
update Datawarehouse.Mapping.EmailTypeConversionTable set Emailofferid = 565 where catalogcode = 38837
update Datawarehouse.Mapping.EmailTypeConversionTable set Emailofferid = 566 where catalogcode = 38840
update Datawarehouse.Mapping.EmailTypeConversionTable set Emailofferid = 566 where catalogcode = 38842
update Datawarehouse.Mapping.EmailTypeConversionTable set Emailofferid = 566 where catalogcode = 38844
update Datawarehouse.Mapping.EmailTypeConversionTable set Emailofferid = 517 where catalogcode = 38847
update Datawarehouse.Mapping.EmailTypeConversionTable set Emailofferid = 517 where catalogcode = 38849
update Datawarehouse.Mapping.EmailTypeConversionTable set Emailofferid = 517 where catalogcode = 38851
update Datawarehouse.Mapping.EmailTypeConversionTable set Emailofferid = 517 where catalogcode = 38854
update Datawarehouse.Mapping.EmailTypeConversionTable set Emailofferid = 517 where catalogcode = 38856
update Datawarehouse.Mapping.EmailTypeConversionTable set Emailofferid = 517 where catalogcode = 38858
update Datawarehouse.Mapping.EmailTypeConversionTable set Emailofferid = 511 where catalogcode = 38861
update Datawarehouse.Mapping.EmailTypeConversionTable set Emailofferid = 511 where catalogcode = 38863
update Datawarehouse.Mapping.EmailTypeConversionTable set Emailofferid = 511 where catalogcode = 38865
update Datawarehouse.Mapping.EmailTypeConversionTable set Emailofferid = 539 where catalogcode = 38868
update Datawarehouse.Mapping.EmailTypeConversionTable set Emailofferid = 539 where catalogcode = 38870
update Datawarehouse.Mapping.EmailTypeConversionTable set Emailofferid = 539 where catalogcode = 38872
update Datawarehouse.Mapping.EmailTypeConversionTable set Emailofferid = 539 where catalogcode = 38875
update Datawarehouse.Mapping.EmailTypeConversionTable set Emailofferid = 539 where catalogcode = 38877
update Datawarehouse.Mapping.EmailTypeConversionTable set Emailofferid = 539 where catalogcode = 38879
update Datawarehouse.Mapping.EmailTypeConversionTable set Emailofferid = 504 where catalogcode = 38882
update Datawarehouse.Mapping.EmailTypeConversionTable set Emailofferid = 504 where catalogcode = 38884
update Datawarehouse.Mapping.EmailTypeConversionTable set Emailofferid = 504 where catalogcode = 38886
update Datawarehouse.Mapping.EmailTypeConversionTable set Emailofferid = 504 where catalogcode = 38889
update Datawarehouse.Mapping.EmailTypeConversionTable set Emailofferid = 504 where catalogcode = 38891
update Datawarehouse.Mapping.EmailTypeConversionTable set Emailofferid = 504 where catalogcode = 38893
update Datawarehouse.Mapping.EmailTypeConversionTable set Emailofferid = 552 where catalogcode = 38896
update Datawarehouse.Mapping.EmailTypeConversionTable set Emailofferid = 552 where catalogcode = 38898
update Datawarehouse.Mapping.EmailTypeConversionTable set Emailofferid = 552 where catalogcode = 38900
update Datawarehouse.Mapping.EmailTypeConversionTable set Emailofferid = 552 where catalogcode = 38903
update Datawarehouse.Mapping.EmailTypeConversionTable set Emailofferid = 552 where catalogcode = 38905
update Datawarehouse.Mapping.EmailTypeConversionTable set Emailofferid = 552 where catalogcode = 38907
update Datawarehouse.Mapping.EmailTypeConversionTable set Emailofferid = 552 where catalogcode = 38910
update Datawarehouse.Mapping.EmailTypeConversionTable set Emailofferid = 552 where catalogcode = 38912
update Datawarehouse.Mapping.EmailTypeConversionTable set Emailofferid = 552 where catalogcode = 38914
update Datawarehouse.Mapping.EmailTypeConversionTable set Emailofferid = 552 where catalogcode = 39029
update Datawarehouse.Mapping.EmailTypeConversionTable set Emailofferid = 552 where catalogcode = 39031
update Datawarehouse.Mapping.EmailTypeConversionTable set Emailofferid = 552 where catalogcode = 39033
*/
select * from Datawarehouse.Mapping.EmailTypeConversionTable2015

/*
select * from datawarehouse.mapping.EmailTypeConversionTable
where CatalogCode in (21326,21333,21308,21315,21322,21324,21329,21331,21304,21306,21311,21313,21260,21262,21275)

/* code to generate email report */

select top 100 * from datawarehouse.Marketing.Email_SalesAndOrders_Summary

select * from datawarehouse.mapping.EmailTypeConversionTable
where EmailId = 47

update datawarehouse.mapping.EmailTypeConversionTable
set EmailId = 48
where catalogcode in (21333,21315,21329,21331,21311,21313)

update datawarehouse.mapping.EmailTypeConversionTable
set Flag_DoublePunch=0 where catalogcode in (14526, 14812, 13779)

update datawarehouse.mapping.EmailTypeConversionTable
set Flag_DoublePunch=1 where catalogcode in (14107, 14111, 14112, 13786, 13782, 13784)

select year(EHistStartDate), month(EHistStartDate), COUNT(CatalogCode)
from DataWarehouse.Marketing.Email_SalesAndOrders_Summary
group by year(EHistStartDate), month(EHistStartDate)
order by year(EHistStartDate), month(EHistStartDate)

select year(EHistStartDate), month(EHistStartDate), COUNT(CatalogCode)
from Datawarehouse.dbo.Email_SalesAndOrders_Summary
group by year(EHistStartDate), month(EHistStartDate)
order by year(EHistStartDate), month(EHistStartDate)


select year(EHistStartDate), COUNT(CatalogCode)
from DataWarehouse.Marketing.Email_SalesAndOrders_Summary
group by year(EHistStartDate)
order by year(EHistStartDate)

select year(EHistStartDate),  COUNT(CatalogCode)
from Datawarehouse.dbo.Email_SalesAndOrders_Summary
group by year(EHistStartDate)
order by year(EHistStartDate)

select a.*
from DataWarehouse.Marketing.Email_SalesAndOrders_Summary a left join
	Datawarehouse..Email_SalesAndOrders_Summary b on a.Adcode = b.Adcode
where b.Adcode is null

select a.*
from Datawarehouse..Email_SalesAndOrders_Summary a left join
	 DataWarehouse.Marketing.Email_SalesAndOrders_Summary b on a.Adcode = b.Adcode
where b.Adcode is null

select * from datawarehouse.mapping.EmailTypeConversionTable

select *
into Datawarehouse.dbo.EmailReportPrep1_ByYear_BKP20130311
from Datawarehouse.dbo.EmailReportPrep1_ByYear
*/

select * from datawarehouse.mapping.EmailTypeConversionTable2015

----- RFI Starts Here
--drop table datawarehouse.dbo.EmailReportPrep1_ByYear
select b.MD_CampaignId as CampaignId ,b.MD_CampaignName as campaignName,b.MD_PromotionTypeID as PromotionTypeID, b.MD_PromotionType as PromotionType,b.MD_Country as Country,
    a.CatalogCode, a.catalogname, 
	EhiststartDate as StartDate, YEAR(EhiststartDate) as EmailYear,
	MONTH(EhiststartDate) as EmailMonth,
	a.StopDate, Sum(a.TotalEmailed) as TotalEmailed,
	Sum(TotalSales) as TotalSales, SUM(TotalOrders) as TotalOrders,
	Sum(TotalCourseParts) as TotalCourseParts, SUM(TotalCourseSales) as TotalCourseSales,
	Sum(TotalCourseUnits) as TotalCourseUnits,
	--b.EmailID, b.EmailType,
	b.Flag_DoublePunch, 
	b.EmailOfferID, c.EmailOffer,
	CONVERT(int, null) as Recency,
	CONVERT(int, Null) as Interval, CONVERT(Int,Null) as Frequency,
	CONVERT(Datetime, Null) as PriorRunDate, GETDATE() as ReportDate,
	CONVERT(Int,Null) as FrequencyByYear
into datawarehouse.dbo.EmailReportPrep1_ByYear
from datawarehouse.Marketing.EmailtrackerNew a
join datawarehouse.mapping.EmailTypeConversionTable2015 b on a.CatalogCode=b.catalogcode
left join DataWarehouse.Mapping.Email_Offers2015 c on b.emailofferid = c.EmailOfferID
Left join DataWarehouse.Mapping.vwAdcodesAll V on a.CatalogCode=v.catalogcode
where a.CustomerSegment='Active' and a.FlagEmailed=1
GROUP BY b.MD_CampaignId ,b.MD_CampaignName,b.MD_PromotionTypeID , b.MD_PromotionType,b.MD_Country, a.CatalogCode, a.catalogname, EhiststartDate,
a.StopDate, CustomerSegment, MultiOrSingle,--b.EmailID, b.EmailType, 
b.Flag_DoublePunch, b.EmailOfferID, c.EmailOffer, YEAR(EhiststartDate), MONTH(EhiststartDate)

  
   

select * from datawarehouse.dbo.EmailReportPrep1_ByYear
 

create index IX_EmailReportPrep1_ByYear1 on datawarehouse.dbo.EmailReportPrep1_ByYear(campaignid)
create index IX_EmailReportPrep1_ByYear2 on datawarehouse.dbo.EmailReportPrep1_ByYear(CatalogCode)

select top 10 * from datawarehouse.mapping.EmailTypeConversionTable2015
 
 

--drop table Datawarehouse.dbo.EmailReportPrep2_ByYear
select distinct campaignid,
	--emailid, 
	Country,
	startdate, 
	dense_rank() over (partition by CampaignId,Country order by StartDate) as Rank3
into Datawarehouse.dbo.EmailReportPrep2_ByYear
from Datawarehouse.dbo.EmailReportPrep1_ByYear
--where campaignid=164
order by CampaignID,Country,  rank3

select * from Datawarehouse.dbo.EmailReportPrep2_ByYear


select * from Datawarehouse.dbo.EmailReportPrep1_ByYear

update A
set a.frequency=b.rank3
from Datawarehouse.dbo.EmailReportPrep1_ByYear a
join
Datawarehouse.dbo.EmailReportPrep2_ByYear b
on a.campaignid=b.campaignid and a.startdate=b.startdate and a.Country=b.Country


update A
set a.PriorRunDate=b.StartDate
From Datawarehouse.dbo.EmailReportPrep1_ByYear a
join
(select *, (frequency+1) as frequency2 from Datawarehouse.dbo.EmailReportPrep1_ByYear) b
on  a.campaignid=b.campaignid and a.frequency=b.frequency2 and a.Country=b.Country 


select * from Datawarehouse.dbo.EmailReportPrep1_ByYear


--drop table Datawarehouse.dbo.EmailReportPrep3_ByYear
select distinct campaignid,
	--emailid, 
	Country,
	emailyear,
	startdate, 
	dense_rank() over (partition by CampaignId, Country,EmailYear order by StartDate) as Rank3
into Datawarehouse.dbo.EmailReportPrep3_ByYear
from Datawarehouse.dbo.EmailReportPrep1_ByYear
--where campaignid=164
order by CampaignID, emailyear,Country, rank3

select * from Datawarehouse.dbo.EmailReportPrep3_ByYear


update A
set a.FrequencyByYear=b.rank3
from Datawarehouse.dbo.EmailReportPrep1_ByYear a
join
Datawarehouse.dbo.EmailReportPrep3_ByYear b
on a.campaignid=b.campaignid 
and a.EmailYear=b.EmailYear 
and a.startdate=b.startdate 
 and a.Country=b.Country


select * from Datawarehouse.dbo.EmailReportPrep1_ByYear
order by CampaignID, emailYear, Startdate, Frequency

update A
set a.interval=DATEDIFF(day,priorrundate,startdate) 
from Datawarehouse.dbo.EmailReportPrep1_ByYear a



update A
set a.interval=0 
from Datawarehouse.dbo.EmailReportPrep1_ByYear a
where interval is null


update A
set a.recency=DATEDIFF(day,startdate,GETDATE()) 
from Datawarehouse.dbo.EmailReportPrep1_ByYear a


select * from Datawarehouse.dbo.EmailReportPrep1_ByYear
where catalogcode=52012

/*
-- backup the original table and copy this.
select *
into Datawarehouse.dbo.EmailReportPrep1BKPDEL2
from Datawarehouse.dbo.EmailReportPrep1
*/

--drop table Datawarehouse.dbo.EmailReportPrep1

select *
into Datawarehouse.dbo.EmailReportPrep1
from Datawarehouse.dbo.EmailReportPrep1_ByYear

select * from  Datawarehouse.dbo.EmailReportPrep1

--drop table Datawarehouse.Marketing.Email_RFI_Report

--insert into Datawarehouse.Marketing.Email_RFI_Report
--select *
-- into Datawarehouse.Marketing.Email_RFI_Report
--from Datawarehouse.dbo.EmailReportPrep1


--truncate table Datawarehouse.Marketing.Email_RFI_Report

--insert into Datawarehouse.Marketing.Email_RFI_Report
--select *from Datawarehouse.dbo.EmailReportPrep1

/*
Delete F from Datawarehouse.Marketing.Email_RFI_Report f
join Datawarehouse.dbo.EmailReportPrep1  s
on f.CatalogCode = S.CatalogCode


select count(*),f.EmailYear from Datawarehouse.Marketing.Email_RFI_Report f
 group by f.EmailYear

insert into Datawarehouse.Marketing.Email_RFI_Report
(campaignid,campaignName,CatalogCode,catalogname,StartDate,EmailYear,EmailMonth,StopDate,TotalEmailed,TotalSales,TotalOrders,TotalCourseParts,
TotalCourseSales,TotalCourseUnits,EmailID,EmailType,Flag_DoublePunch,EmailOfferID,EmailOffer,Recency,Interval,Frequency,PriorRunDate,ReportDate,FrequencyByYear)
select 
campaignid,campaignName,CatalogCode,catalogname,StartDate,EmailYear,EmailMonth,StopDate,TotalEmailed,TotalSales,TotalOrders,TotalCourseParts,
TotalCourseSales,TotalCourseUnits,EmailID,cast(EmailType as varchar(255)),Flag_DoublePunch,EmailOfferID,cast(EmailOffer as varchar(100)),Recency,Interval,Frequency,PriorRunDate,ReportDate,FrequencyByYear
 from Datawarehouse.dbo.EmailReportPrep1
  
 


 select * from Datawarehouse.Marketing.Email_RFI_Report
 where emailyear=2015
 and EmailOfferID is NULL

 select * from Datawarehouse.Mapping.Email_Offers2015



 select * from Datawarehouse.Marketing.Email_RFI_Report f
left  join  [staging].[EmailTypeConversion2015]S
on f.CatalogCode = S.CatalogCode 
where  emailyear=2015 and f.EmailOfferID is NULL


select * from [staging].[EmailTypeConversion2015]S
where catalogcode in (
 select distinct catalogcode from Datawarehouse.Marketing.Email_RFI_Report
 where emailyear=2015
 and EmailOfferID is NULL)

 */

 select * from  Datawarehouse.dbo.EmailReportPrep1
 where EmailOfferID =503
 order by Frequency

 select * from Datawarehouse.Marketing.Email_RFI_Report


 --Add MD_Country


 --MD_Country
 --select * from DataWarehouse.Mapping.vwAdcodesAll
 --where CatalogCode =35233


 --Alter table Datawarehouse.Marketing.Email_RFI_Report add MD_Country varchar(50)

 --update F
 --set f.MD_Country = c.MD_Country
 ----select c.*,f.* 
 --from Datawarehouse.Marketing.Email_RFI_Report f
 --join (select distinct catalogcode,MD_Country from  DataWarehouse.Mapping.vwAdcodesAll) C
 --on c.CatalogCode=f.CatalogCode

 
-- update a
--set Flag_DoublePunch = case when catalogname like '%DP%' then 1
--			when catalogname like '%TP%' then 2 
--			else 0 end from Datawarehouse.Marketing.Email_RFI_Report a
--where EmailYear=2015
 
 End

GO
