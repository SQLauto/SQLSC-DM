SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE VIEW [Archive].[Vw_TGC_DigitalConsumptionAllYrs]
AS

			select Customerid, StreamingDate as ActionDate
				,Courseid, LectureNumber
				,FormatPurchased, TransactionType
				,Action, TotalActions
				,(StreamSeconds/60) MediaTimePlayed
				,convert(varchar,CourseID) + convert(varchar,Lecturenumber) as CourseLecture
			from Archive.DigitalConsumptionHistory
			where StreamingDate < '1/1/2017'
			and CustomerID is not null
				union all
			select CustomerID, Actiondate
				,CourseID, LectureNumber
				,FormatPurchased, TransactionType
				,Action, TotalActions
				,MediaTimePlayed
				,convert(varchar,CourseID) + convert(varchar,Lecturenumber) as CourseLecture
			FROM Archive.Vw_TGC_DigitalConsumption
			where Actiondate >= '1/1/2017'
			and CustomerID is not null

GO
