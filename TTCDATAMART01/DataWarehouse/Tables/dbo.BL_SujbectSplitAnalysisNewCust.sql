CREATE TABLE [dbo].[BL_SujbectSplitAnalysisNewCust]
(
[CustomerID] [nvarchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[OrderID] [nvarchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[YearOrdered] [int] NULL,
[MonthOrdered] [int] NULL,
[DateOrdered] [date] NULL,
[SequenceNum] [int] NULL,
[CourseID] [int] NULL,
[AbbrvCourseName] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[SubjectCategory2] [varchar] (5) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ReleaseDate] [datetime] NULL,
[Totalsales] [money] NULL,
[TotalParts] [dbo].[udtCourseParts] NULL,
[TotalQuantity] [int] NULL
) ON [PRIMARY]
GO
