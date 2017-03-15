CREATE TABLE [Mapping].[FBA_ASIN_Course]
(
[ASIN] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[CourseID] [int] NULL,
[SKU] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[DMLastupdated] [datetime] NULL CONSTRAINT [DF__FBA_ASIN___DMLas__11C81B7A] DEFAULT (getdate())
) ON [PRIMARY]
GO
