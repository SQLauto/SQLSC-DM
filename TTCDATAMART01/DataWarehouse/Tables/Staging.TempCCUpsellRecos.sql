CREATE TABLE [Staging].[TempCCUpsellRecos]
(
[CustomerID] [nvarchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[CourseID] [int] NOT NULL,
[Rank] [int] NULL,
[LastOrderDate] [datetime] NULL
) ON [PRIMARY]
GO
