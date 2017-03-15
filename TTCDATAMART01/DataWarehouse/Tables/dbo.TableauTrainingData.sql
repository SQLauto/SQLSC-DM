CREATE TABLE [dbo].[TableauTrainingData]
(
[OrderID] [nvarchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[TotalQuantity] [int] NULL,
[CourseID] [int] NULL,
[DateOrdered] [smalldatetime] NULL,
[CourseReleaseDate] [smalldatetime] NULL,
[FormatMedia] [char] (2) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[PaymentStatus] [int] NULL,
[FlagReturn] [bit] NULL,
[FlagPaymentRejected] [bit] NULL,
[FormatAD] [char] (2) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[FormatAV] [char] (2) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[CourseName] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[SubjectCategory] [varchar] (5) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Parts] [money] NULL,
[TotalParts] [money] NULL,
[SalesPrice] [money] NULL,
[TotalSales] [money] NULL,
[SubjectCategory2] [varchar] (5) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[CustomerID] [nvarchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[OrderSource] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[FinalSales] [money] NULL,
[ShipCountryCode] [nvarchar] (40) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Age] [int] NULL,
[AgeBin] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
