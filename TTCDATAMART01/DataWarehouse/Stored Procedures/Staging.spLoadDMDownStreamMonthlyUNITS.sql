SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO


CREATE PROCEDURE [Staging].[spLoadDMDownStreamMonthlyUNITS]

AS
/* Last Updated: 2006-01-19 tlj Chagned to use single pass - reduced time from 30 to 45 minutes to 35 second load.
*/

	truncate TABLE Marketing.DMDownStreamMonthlyUNITS

insert into Marketing.DMDownStreamMonthlyUNITS
Select Customerid,
	DS1moSales = sum(case when DOwnStreamDays < 30
		AND SequenceNum > 1 AND FinalSales < 1500 then FinalSales else 0 end),
	DS2moSales = sum(case when DOwnStreamDays < 60
		AND SequenceNum > 1 AND FinalSales < 1500 then FinalSales else 0 end),
 	DS3moSales = sum(case when DOwnStreamDays < 90
		AND SequenceNum > 1 AND FinalSales < 1500 then FinalSales else 0 end),
 	DS4moSales = sum(case when DOwnStreamDays < 120
		AND SequenceNum > 1 AND FinalSales < 1500 then FinalSales else 0 end),
 	DS5moSales = sum(case when DOwnStreamDays < 150
		AND SequenceNum > 1 AND FinalSales < 1500 then FinalSales else 0 end),
 	DS6moSales = sum(case when DOwnStreamDays < 180
		AND SequenceNum > 1 AND FinalSales < 1500 then FinalSales else 0 end),
 	DS7moSales = sum(case when DOwnStreamDays < 210
		AND SequenceNum > 1 AND FinalSales < 1500 then FinalSales else 0 end),
 	DS8moSales = sum(case when DOwnStreamDays < 240
		AND SequenceNum > 1 AND FinalSales < 1500 then FinalSales else 0 end),
 	DS9moSales = sum(case when DOwnStreamDays < 270
		AND SequenceNum > 1 AND FinalSales < 1500 then FinalSales else 0 end),
 	DS10moSales = sum(case when DOwnStreamDays < 300
		AND SequenceNum > 1 AND FinalSales < 1500 then FinalSales else 0 end),
 	DS11moSales = sum(case when DOwnStreamDays < 330
		AND SequenceNum > 1 AND FinalSales < 1500 then FinalSales else 0 end),
 	DS12moSales = sum(case when DOwnStreamDays < 360
		AND SequenceNum > 1 AND FinalSales < 1500 then FinalSales else 0 end),
 	DS24moSales = sum(case when DOwnStreamDays < 730
		AND SequenceNum > 1 AND FinalSales < 1500 then FinalSales else 0 end),
 	DS36moSales = sum(case when DOwnStreamDays < 1095
		AND SequenceNum > 1 AND FinalSales < 1500 then FinalSales else 0 end),
 	DS48moSales = sum(case when DOwnStreamDays < 1460
		AND SequenceNum > 1 AND FinalSales < 1500 then FinalSales else 0 end),
 	DS60moSales = sum(case when DOwnStreamDays < 1825
		AND SequenceNum > 1 AND FinalSales < 1500 then FinalSales else 0 end),
 	DS72moSales = sum(case when DOwnStreamDays < 2190
		AND SequenceNum > 1 AND FinalSales < 1500 then FinalSales else 0 end),
 	DS84moSales = sum(case when DOwnStreamDays < 2555
		AND SequenceNum > 1 AND FinalSales < 1500 then FinalSales else 0 end),
 	DS96moSales = sum(case when DOwnStreamDays < 2920
		AND SequenceNum > 1 AND FinalSales < 1500 then FinalSales else 0 end),
 	DS108moSales = sum(case when DOwnStreamDays < 3285
		AND SequenceNum > 1 AND FinalSales < 1500 then FinalSales else 0 end),
 	DS120moSales = sum(case when DOwnStreamDays < 3650
		AND SequenceNum > 1 AND FinalSales < 1500 then FinalSales else 0 end),
 	DS132moSales = sum(case when DOwnStreamDays < 4015
		AND SequenceNum > 1 AND FinalSales < 1500 then FinalSales else 0 end),
 	DS144moSales = sum(case when DOwnStreamDays < 4380
		AND SequenceNum > 1 AND FinalSales < 1500 then FinalSales else 0 end),
 	DS156moSales = sum(case when DOwnStreamDays < 4745
		AND SequenceNum > 1 AND FinalSales < 1500 then FinalSales else 0 end),
 	DS168moSales = sum(case when DOwnStreamDays < 5110
		AND SequenceNum > 1 AND FinalSales < 1500 then FinalSales else 0 end),
 	DS180moSales = sum(case when DOwnStreamDays < 5475
		AND SequenceNum > 1 AND FinalSales < 1500 then FinalSales else 0 end),
	DS1moOrders = sum(case when DOwnStreamDays < 30
		AND SequenceNum > 1 AND FinalSales < 1500 then 1 else 0 end),
	DS2moOrders = sum(case when DOwnStreamDays < 60
		AND SequenceNum > 1 AND FinalSales < 1500 then 1 else 0 end),
	DS3moOrders = sum(case when DOwnStreamDays < 90
		AND SequenceNum > 1 AND FinalSales < 1500 then 1 else 0 end),
	DS4moOrders = sum(case when DOwnStreamDays < 120
		AND SequenceNum > 1 AND FinalSales < 1500 then 1 else 0 end),
	DS5moOrders = sum(case when DOwnStreamDays < 150
		AND SequenceNum > 1 AND FinalSales < 1500 then 1 else 0 end),
	DS6moOrders = sum(case when DOwnStreamDays < 180
		AND SequenceNum > 1 AND FinalSales < 1500 then 1 else 0 end),
	DS7moOrders = sum(case when DOwnStreamDays < 210
		AND SequenceNum > 1 AND FinalSales < 1500 then 1 else 0 end),
	DS8moOrders = sum(case when DOwnStreamDays < 240
		AND SequenceNum > 1 AND FinalSales < 1500 then 1 else 0 end),
	DS9moOrders = sum(case when DOwnStreamDays < 270
		AND SequenceNum > 1 AND FinalSales < 1500 then 1 else 0 end),
	DS10moOrders = sum(case when DOwnStreamDays < 300
		AND SequenceNum > 1 AND FinalSales < 1500 then 1 else 0 end),
	DS11moOrders = sum(case when DOwnStreamDays < 330
		AND SequenceNum > 1 AND FinalSales < 1500 then 1 else 0 end),
	DS12moOrders = sum(case when DOwnStreamDays < 360
		AND SequenceNum > 1 AND FinalSales < 1500 then 1 else 0 end),
	DS24moOrders = sum(case when DOwnStreamDays < 730
		AND SequenceNum > 1 AND FinalSales < 1500 then 1 else 0 end),
	DS36moOrders = sum(case when DOwnStreamDays < 1095
		AND SequenceNum > 1 AND FinalSales < 1500 then 1 else 0 end),
	DS48moOrders = sum(case when DOwnStreamDays < 1460
		AND SequenceNum > 1 AND FinalSales < 1500 then 1 else 0 end),
	DS60moOrders = sum(case when DOwnStreamDays < 1825
		AND SequenceNum > 1 AND FinalSales < 1500 then 1 else 0 end),
	DS72moOrders = sum(case when DOwnStreamDays < 2190
		AND SequenceNum > 1 AND FinalSales < 1500 then 1 else 0 end),
	DS84moOrders = sum(case when DOwnStreamDays < 2555
		AND SequenceNum > 1 AND FinalSales < 1500 then 1 else 0 end),
	DS96moOrders = sum(case when DOwnStreamDays < 2920
		AND SequenceNum > 1 AND FinalSales < 1500 then 1 else 0 end),
	DS108moOrders = sum(case when DOwnStreamDays < 3285
		AND SequenceNum > 1 AND FinalSales < 1500 then 1 else 0 end),
	DS120moOrders = sum(case when DOwnStreamDays < 3650
		AND SequenceNum > 1 AND FinalSales < 1500 then 1 else 0 end),
	DS132moOrders = sum(case when DOwnStreamDays < 4015
		AND SequenceNum > 1 AND FinalSales < 1500 then 1 else 0 end),
	DS144moOrders = sum(case when DOwnStreamDays < 4380
		AND SequenceNum > 1 AND FinalSales < 1500 then 1 else 0 end),
 	DS156moOrders = sum(case when DOwnStreamDays < 4745
		AND SequenceNum > 1 AND FinalSales < 1500 then 1 else 0 end),
 	DS168moOrders = sum(case when DOwnStreamDays < 5110
		AND SequenceNum > 1 AND FinalSales < 1500 then 1 else 0 end),
 	DS180moOrders = sum(case when DOwnStreamDays < 5475
		AND SequenceNum > 1 AND FinalSales < 1500 then 1 else 0 end),
	DS1moFlagRepeatByr = max(case when DOwnStreamDays < 30
		AND SequenceNum > 1 AND FinalSales < 1500 then 1 else 0 end), 	
	DS2moFlagRepeatByr = max(case when DOwnStreamDays < 60
		AND SequenceNum > 1 AND FinalSales < 1500 then 1 else 0 end),
	DS3moFlagRepeatByr = max(case when DOwnStreamDays < 90
		AND SequenceNum > 1 AND FinalSales < 1500 then 1 else 0 end),
	DS4moFlagRepeatByr = max(case when DOwnStreamDays < 120
		AND SequenceNum > 1 AND FinalSales < 1500 then 1 else 0 end),
	DS5moFlagRepeatByr = max(case when DOwnStreamDays < 150
		AND SequenceNum > 1 AND FinalSales < 1500 then 1 else 0 end),
	DS6moFlagRepeatByr = max(case when DOwnStreamDays < 180
		AND SequenceNum > 1 AND FinalSales < 1500 then 1 else 0 end),
	DS7moFlagRepeatByr = max(case when DOwnStreamDays < 210
		AND SequenceNum > 1 AND FinalSales < 1500 then 1 else 0 end),
	DS8moFlagRepeatByr = max(case when DOwnStreamDays < 240
		AND SequenceNum > 1 AND FinalSales < 1500 then 1 else 0 end),
	DS9moFlagRepeatByr = max(case when DOwnStreamDays < 270
		AND SequenceNum > 1 AND FinalSales < 1500 then 1 else 0 end),
	DS10moFlagRepeatByr = max(case when DOwnStreamDays < 300
		AND SequenceNum > 1 AND FinalSales < 1500 then 1 else 0 end),
	DS11moFlagRepeatByr = max(case when DOwnStreamDays < 330
		AND SequenceNum > 1 AND FinalSales < 1500 then 1 else 0 end),
	DS12moFlagRepeatByr = max(case when DOwnStreamDays < 360
		AND SequenceNum > 1 AND FinalSales < 1500 then 1 else 0 end),
	DS24moFlagRepeatByr = max(case when DOwnStreamDays < 730
		AND SequenceNum > 1 AND FinalSales < 1500 then 1 else 0 end),
	DS36moFlagRepeatByr = max(case when DOwnStreamDays < 1095
		AND SequenceNum > 1 AND FinalSales < 1500 then 1 else 0 end),
	DS48moFlagRepeatByr = max(case when DOwnStreamDays < 1460
		AND SequenceNum > 1 AND FinalSales < 1500 then 1 else 0 end),
	DS60moFlagRepeatByr = max(case when DOwnStreamDays < 1825
		AND SequenceNum > 1 AND FinalSales < 1500 then 1 else 0 end),
	DS72moFlagRepeatByr = max(case when DOwnStreamDays < 2190
		AND SequenceNum > 1 AND FinalSales < 1500 then 1 else 0 end),
	DS84moFlagRepeatByr = max(case when DOwnStreamDays < 2555
		AND SequenceNum > 1 AND FinalSales < 1500 then 1 else 0 end),
	DS96moFlagRepeatByr = max(case when DOwnStreamDays < 2920
		AND SequenceNum > 1 AND FinalSales < 1500 then 1 else 0 end),
	DS108moFlagRepeatByr = max(case when DOwnStreamDays < 3285
		AND SequenceNum > 1 AND FinalSales < 1500 then 1 else 0 end),
	DS120moFlagRepeatByr = max(case when DOwnStreamDays < 3650
		AND SequenceNum > 1 AND FinalSales < 1500 then 1 else 0 end),
    DS132moFlagRepeatByr = max(case when DOwnStreamDays < 4015
		AND SequenceNum > 1 AND FinalSales < 1500 then 1 else 0 end),
	DS144moFlagRepeatByr = max(case when DOwnStreamDays < 4380
		AND SequenceNum > 1 AND FinalSales < 1500 then 1 else 0 end),
 	DS156moFlagRepeatByr = max(case when DOwnStreamDays < 4745
		AND SequenceNum > 1 AND FinalSales < 1500 then 1 else 0 end),
 	DS168moFlagRepeatByr = max(case when DOwnStreamDays < 5110
		AND SequenceNum > 1 AND FinalSales < 1500 then 1 else 0 end),
 	DS180moFlagRepeatByr = max(case when DOwnStreamDays < 5475
		AND SequenceNum > 1 AND FinalSales < 1500 then 1 else 0 end),
	DS1moUnits = sum(case when DOwnStreamDays < 30
		AND SequenceNum > 1 AND FinalSales < 1500 then TotalCourseQuantity else 0 end),
	DS2moUnits = sum(case when DOwnStreamDays < 60
		AND SequenceNum > 1 AND FinalSales < 1500 then TotalCourseQuantity else 0 end),
 	DS3moUnits = sum(case when DOwnStreamDays < 90
		AND SequenceNum > 1 AND FinalSales < 1500 then TotalCourseQuantity else 0 end),
 	DS4moUnits = sum(case when DOwnStreamDays < 120
		AND SequenceNum > 1 AND FinalSales < 1500 then TotalCourseQuantity else 0 end),
 	DS5moUnits = sum(case when DOwnStreamDays < 150
		AND SequenceNum > 1 AND FinalSales < 1500 then TotalCourseQuantity else 0 end),
 	DS6moUnits = sum(case when DOwnStreamDays < 180
		AND SequenceNum > 1 AND FinalSales < 1500 then TotalCourseQuantity else 0 end),
 	DS7moUnits = sum(case when DOwnStreamDays < 210
		AND SequenceNum > 1 AND FinalSales < 1500 then TotalCourseQuantity else 0 end),
 	DS8moUnits = sum(case when DOwnStreamDays < 240
		AND SequenceNum > 1 AND FinalSales < 1500 then TotalCourseQuantity else 0 end),
 	DS9moUnits = sum(case when DOwnStreamDays < 270
		AND SequenceNum > 1 AND FinalSales < 1500 then TotalCourseQuantity else 0 end),
 	DS10moUnits = sum(case when DOwnStreamDays < 300
		AND SequenceNum > 1 AND FinalSales < 1500 then TotalCourseQuantity else 0 end),
 	DS11moUnits = sum(case when DOwnStreamDays < 330
		AND SequenceNum > 1 AND FinalSales < 1500 then TotalCourseQuantity else 0 end),
 	DS12moUnits = sum(case when DOwnStreamDays < 360
		AND SequenceNum > 1 AND FinalSales < 1500 then TotalCourseQuantity else 0 end),
 	DS24moUnits = sum(case when DOwnStreamDays < 730
		AND SequenceNum > 1 AND FinalSales < 1500 then TotalCourseQuantity else 0 end),
 	DS36moUnits = sum(case when DOwnStreamDays < 1095
		AND SequenceNum > 1 AND FinalSales < 1500 then TotalCourseQuantity else 0 end),
 	DS48moUnits = sum(case when DOwnStreamDays < 1460
		AND SequenceNum > 1 AND FinalSales < 1500 then TotalCourseQuantity else 0 end),
 	DS60moUnits = sum(case when DOwnStreamDays < 1825
		AND SequenceNum > 1 AND FinalSales < 1500 then TotalCourseQuantity else 0 end),
 	DS72moUnits = sum(case when DOwnStreamDays < 2190
		AND SequenceNum > 1 AND FinalSales < 1500 then TotalCourseQuantity else 0 end),
 	DS84moUnits = sum(case when DOwnStreamDays < 2555
		AND SequenceNum > 1 AND FinalSales < 1500 then TotalCourseQuantity else 0 end),
 	DS96moUnits = sum(case when DOwnStreamDays < 2920
		AND SequenceNum > 1 AND FinalSales < 1500 then TotalCourseQuantity else 0 end),
 	DS108moUnits = sum(case when DOwnStreamDays < 3285
		AND SequenceNum > 1 AND FinalSales < 1500 then TotalCourseQuantity else 0 end),
 	DS120moUnits = sum(case when DOwnStreamDays < 3650
		AND SequenceNum > 1 AND FinalSales < 1500 then TotalCourseQuantity else 0 end),
 	DS132moUnits = sum(case when DOwnStreamDays < 4015
		AND SequenceNum > 1 AND FinalSales < 1500 then TotalCourseQuantity else 0 end),
 	DS144moUnits = sum(case when DOwnStreamDays < 4380
		AND SequenceNum > 1 AND FinalSales < 1500 then TotalCourseQuantity else 0 end),
 	DS156moUnits = sum(case when DOwnStreamDays < 4745
		AND SequenceNum > 1 AND FinalSales < 1500 then TotalCourseQuantity else 0 end),
 	DS168moUnits = sum(case when DOwnStreamDays < 5110
		AND SequenceNum > 1 AND FinalSales < 1500 then TotalCourseQuantity else 0 end),
 	DS180moUnits = sum(case when DOwnStreamDays < 5475
		AND SequenceNum > 1 AND FinalSales < 1500 then TotalCourseQuantity else 0 end),
	DS1moParts = sum(case when DOwnStreamDays < 30
		AND SequenceNum > 1 AND FinalSales < 1500 then TotalCourseParts else 0 end),
	DS2moParts = sum(case when DOwnStreamDays < 60
		AND SequenceNum > 1 AND FinalSales < 1500 then TotalCourseParts else 0 end),
 	DS3moParts = sum(case when DOwnStreamDays < 90
		AND SequenceNum > 1 AND FinalSales < 1500 then TotalCourseParts else 0 end),
 	DS4moParts = sum(case when DOwnStreamDays < 120
		AND SequenceNum > 1 AND FinalSales < 1500 then TotalCourseParts else 0 end),
 	DS5moParts = sum(case when DOwnStreamDays < 150
		AND SequenceNum > 1 AND FinalSales < 1500 then TotalCourseParts else 0 end),
 	DS6moParts = sum(case when DOwnStreamDays < 180
		AND SequenceNum > 1 AND FinalSales < 1500 then TotalCourseParts else 0 end),
 	DS7moParts = sum(case when DOwnStreamDays < 210
		AND SequenceNum > 1 AND FinalSales < 1500 then TotalCourseParts else 0 end),
 	DS8moParts = sum(case when DOwnStreamDays < 240
		AND SequenceNum > 1 AND FinalSales < 1500 then TotalCourseParts else 0 end),
 	DS9moParts = sum(case when DOwnStreamDays < 270
		AND SequenceNum > 1 AND FinalSales < 1500 then TotalCourseParts else 0 end),
 	DS10moParts = sum(case when DOwnStreamDays < 300
		AND SequenceNum > 1 AND FinalSales < 1500 then TotalCourseParts else 0 end),
 	DS11moParts = sum(case when DOwnStreamDays < 330
		AND SequenceNum > 1 AND FinalSales < 1500 then TotalCourseParts else 0 end),
 	DS12moParts = sum(case when DOwnStreamDays < 360
		AND SequenceNum > 1 AND FinalSales < 1500 then TotalCourseParts else 0 end),
 	DS24moParts = sum(case when DOwnStreamDays < 730
		AND SequenceNum > 1 AND FinalSales < 1500 then TotalCourseParts else 0 end),
 	DS36moParts = sum(case when DOwnStreamDays < 1095
		AND SequenceNum > 1 AND FinalSales < 1500 then TotalCourseParts else 0 end),
 	DS48moParts = sum(case when DOwnStreamDays < 1460
		AND SequenceNum > 1 AND FinalSales < 1500 then TotalCourseParts else 0 end),
 	DS60moParts = sum(case when DOwnStreamDays < 1825
		AND SequenceNum > 1 AND FinalSales < 1500 then TotalCourseParts else 0 end),
 	DS72moParts = sum(case when DOwnStreamDays < 2190
		AND SequenceNum > 1 AND FinalSales < 1500 then TotalCourseParts else 0 end),
 	DS84moParts = sum(case when DOwnStreamDays < 2555
		AND SequenceNum > 1 AND FinalSales < 1500 then TotalCourseParts else 0 end),
 	DS96moParts = sum(case when DOwnStreamDays < 2920
		AND SequenceNum > 1 AND FinalSales < 1500 then TotalCourseParts else 0 end),
 	DS108moParts = sum(case when DOwnStreamDays < 3285
		AND SequenceNum > 1 AND FinalSales < 1500 then TotalCourseParts else 0 end),
 	DS120moParts = sum(case when DOwnStreamDays < 3650
		AND SequenceNum > 1 AND FinalSales < 1500 then TotalCourseParts else 0 end),
 	DS132moParts = sum(case when DOwnStreamDays < 4015
		AND SequenceNum > 1 AND FinalSales < 1500 then TotalCourseParts else 0 end),
 	DS144moParts = sum(case when DOwnStreamDays < 4380
		AND SequenceNum > 1 AND FinalSales < 1500 then TotalCourseParts else 0 end),
 	DS156moParts = sum(case when DOwnStreamDays < 4745
		AND SequenceNum > 1 AND FinalSales < 1500 then TotalCourseParts else 0 end),
 	DS168moParts = sum(case when DOwnStreamDays < 5110
		AND SequenceNum > 1 AND FinalSales < 1500 then TotalCourseParts else 0 end),
 	DS180moParts = sum(case when DOwnStreamDays < 5475
		AND SequenceNum > 1 AND FinalSales < 1500 then TotalCourseParts else 0 end),
	DS1moCourseSales = sum(case when DOwnStreamDays < 30
		AND SequenceNum > 1 AND FinalSales < 1500 then TotalCourseSales else 0 end),
	DS2moCourseSales = sum(case when DOwnStreamDays < 60
		AND SequenceNum > 1 AND FinalSales < 1500 then TotalCourseSales else 0 end),
 	DS3moCourseSales = sum(case when DOwnStreamDays < 90
		AND SequenceNum > 1 AND FinalSales < 1500 then TotalCourseSales else 0 end),
 	DS4moCourseSales = sum(case when DOwnStreamDays < 120
		AND SequenceNum > 1 AND FinalSales < 1500 then TotalCourseSales else 0 end),
 	DS5moCourseSales = sum(case when DOwnStreamDays < 150
		AND SequenceNum > 1 AND FinalSales < 1500 then TotalCourseSales else 0 end),
 	DS6moCourseSales = sum(case when DOwnStreamDays < 180
		AND SequenceNum > 1 AND FinalSales < 1500 then TotalCourseSales else 0 end),
 	DS7moCourseSales = sum(case when DOwnStreamDays < 210
		AND SequenceNum > 1 AND FinalSales < 1500 then TotalCourseSales else 0 end),
 	DS8moCourseSales = sum(case when DOwnStreamDays < 240
		AND SequenceNum > 1 AND FinalSales < 1500 then TotalCourseSales else 0 end),
 	DS9moCourseSales = sum(case when DOwnStreamDays < 270
		AND SequenceNum > 1 AND FinalSales < 1500 then TotalCourseSales else 0 end),
 	DS10moCourseSales = sum(case when DOwnStreamDays < 300
		AND SequenceNum > 1 AND FinalSales < 1500 then TotalCourseSales else 0 end),
 	DS11moCourseSales = sum(case when DOwnStreamDays < 330
		AND SequenceNum > 1 AND FinalSales < 1500 then TotalCourseSales else 0 end),
 	DS12moCourseSales = sum(case when DOwnStreamDays < 360
		AND SequenceNum > 1 AND FinalSales < 1500 then TotalCourseSales else 0 end),
 	DS24moCourseSales = sum(case when DOwnStreamDays < 730
		AND SequenceNum > 1 AND FinalSales < 1500 then TotalCourseSales else 0 end),
 	DS36moCourseSales = sum(case when DOwnStreamDays < 1095
		AND SequenceNum > 1 AND FinalSales < 1500 then TotalCourseSales else 0 end),
 	DS48moCourseSales = sum(case when DOwnStreamDays < 1460
		AND SequenceNum > 1 AND FinalSales < 1500 then TotalCourseSales else 0 end),
 	DS60moCourseSales = sum(case when DOwnStreamDays < 1825
		AND SequenceNum > 1 AND FinalSales < 1500 then TotalCourseSales else 0 end),
 	DS72moCourseSales = sum(case when DOwnStreamDays < 2190
		AND SequenceNum > 1 AND FinalSales < 1500 then TotalCourseSales else 0 end),
 	DS84moCourseSales = sum(case when DOwnStreamDays < 2555
		AND SequenceNum > 1 AND FinalSales < 1500 then TotalCourseSales else 0 end),
 	DS96moCourseSales = sum(case when DOwnStreamDays < 2920
		AND SequenceNum > 1 AND FinalSales < 1500 then TotalCourseSales else 0 end),
 	DS108moCourseSales = sum(case when DOwnStreamDays < 3285
		AND SequenceNum > 1 AND FinalSales < 1500 then TotalCourseSales else 0 end),
 	DS120moCourseSales = sum(case when DOwnStreamDays < 3650
		AND SequenceNum > 1 AND FinalSales < 1500 then TotalCourseSales else 0 end),
 	DS132moCourseSales = sum(case when DOwnStreamDays < 4015
		AND SequenceNum > 1 AND FinalSales < 1500 then TotalCourseSales else 0 end),
 	DS144moCourseSales = sum(case when DOwnStreamDays < 4380
		AND SequenceNum > 1 AND FinalSales < 1500 then TotalCourseSales else 0 end),
 	DS156moCourseSales = sum(case when DOwnStreamDays < 4745
		AND SequenceNum > 1 AND FinalSales < 1500 then TotalCourseSales else 0 end),
 	DS168moCourseSales = sum(case when DOwnStreamDays < 5110
		AND SequenceNum > 1 AND FinalSales < 1500 then TotalCourseSales else 0 end),
 	DS180moCourseSales = sum(case when DOwnStreamDays < 5475
		AND SequenceNum > 1 AND FinalSales < 1500 then TotalCourseSales else 0 end),
	DS18moSales = sum(case when DOwnStreamDays < 540
		AND SequenceNum > 1 AND FinalSales < 1500 then FinalSales else 0 end),
	DS18moOrders = sum(case when DOwnStreamDays < 540
		AND SequenceNum > 1 AND FinalSales < 1500 then 1 else 0 end),
 	DS18moFlagRepeatByr = max(case when DOwnStreamDays < 540
		AND SequenceNum > 1 AND FinalSales < 1500 then 1 else 0 end),
	DS18moUnits = sum(case when DOwnStreamDays < 540
		AND SequenceNum > 1 AND FinalSales < 1500 then TotalCourseQuantity else 0 end),
 	DS18moParts = sum(case when DOwnStreamDays < 540
		AND SequenceNum > 1 AND FinalSales < 1500 then TotalCourseParts else 0 end),
 	DS18moCourseSales = sum(case when DOwnStreamDays < 540
		AND SequenceNum > 1 AND FinalSales < 1500 then TotalCourseSales else 0 end)
FROM marketing.DMPurchaseOrders
where CustomerID <> 50317413
group by customerid
GO
