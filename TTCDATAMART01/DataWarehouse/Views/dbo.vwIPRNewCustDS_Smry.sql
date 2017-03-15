SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

        
CREATE  View [dbo].[vwIPRNewCustDS_Smry]              
as 
		select year(IntlPurchaseDate) YearIntlPurchase,
			Month(IntlPurchaseDate) MonthIntlPurchase,
			IPR_Channel,
			MD_Channel,
			MD_PromotionType,
			MD_PriceType,
			IntlSubjectPref,
			IntlFormatMediaPref,
			IntlFormatAVPref,
			IntlOrderSource,
			IntlAvgOrderBin,
			IntlPartsBin,
			IntlCoursesBin,
			case when CountryCode in ('US','CA','GB','AU') then CountryCode	
				else 'ROW'
			end as CountryCode,
			IntlAvgOrderBin_2,
			count(CustomerID) as CustCount,
			Sum(IntlPurchAmount) as IntlPurchAmount,
			Sum(IntlParts) as IntlParts,
			Sum(IntlNumOfCOurses) as IntlNumOfCOurses,
			Sum(DS1moSales) as DS1moSales,
			Sum(DS2moSales) as DS2moSales,
			Sum(DS3moSales) as DS3moSales,
			Sum(DS6moSales) as DS6moSales,
			Sum(DS12moSales) as DS12moSales,
			Sum(DS1moOrders) as DS1moOrders,
			Sum(DS2moOrders) as DS2moOrders,
			Sum(DS3moOrders) as DS3moOrders,
			Sum(DS6moOrders) as DS6moOrders,
			Sum(DS12moOrders) as DS12moOrders,
			Sum(DS1moFlagRepeatByr) as DS1moFlagRepeatByr,
			Sum(DS2moFlagRepeatByr) as DS2moFlagRepeatByr,
			Sum(DS3moFlagRepeatByr) as DS3moFlagRepeatByr,
			Sum(DS6moFlagRepeatByr) as DS6moFlagRepeatByr,
			Sum(DS12moFlagRepeatByr) as DS12moFlagRepeatByr,
			Sum(DS1moOrderUnits) as DS1moOrderUnits,
			Sum(DS2moOrderUnits) as DS2moOrderUnits,
			Sum(DS3moOrderUnits) as DS3moOrderUnits,
			Sum(DS6moOrderUnits) as DS6moOrderUnits,
			Sum(DS24moOrderUnits) as DS24moOrderUnits,
			Sum(DS1moEmailContacts) as DS1moEmailContacts,
			Sum(DS2moEmailContacts) as DS2moEmailContacts,
			Sum(DS3moEmailContacts) as DS3moEmailContacts,
			Sum(DS6moEmailContacts) as DS6moEmailContacts,
			Sum(DS12moEmailContacts) as DS12moEmailContacts,
			Sum(DS1momailContacts) as DS1momailContacts,
			Sum(DS2momailContacts) as DS2momailContacts,
			Sum(DS3momailContacts) as DS3momailContacts,
			Sum(DS6momailContacts) as DS6momailContacts,
			Sum(DS12momailContacts) as DS12momailContacts,
			Sum(DS1moParts) as DS1moParts,
			Sum(DS2moParts) as DS2moParts,
			Sum(DS3moParts) as DS3moParts,
			Sum(DS6moParts) as DS6moParts,
			Sum(DS12moParts) as DS12moParts
		from vwIPRNewCustDS		
		group by year(IntlPurchaseDate),
			Month(IntlPurchaseDate),
			IPR_Channel,
			MD_Channel,
			MD_PromotionType,
			MD_PriceType,
			IntlSubjectPref,
			IntlFormatMediaPref,
			IntlFormatAVPref,
			IntlOrderSource,
			IntlAvgOrderBin,
			IntlPartsBin,
			IntlCoursesBin,
			case when CountryCode in ('US','CA','GB','AU') then CountryCode	
				else 'ROW'
			end,
			IntlAvgOrderBin_2


GO
