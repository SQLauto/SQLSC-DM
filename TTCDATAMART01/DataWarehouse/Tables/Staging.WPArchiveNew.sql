CREATE TABLE [Staging].[WPArchiveNew]
(
[CustomerID] [int] NOT NULL,
[CustomerName] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Prefix] [char] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[FirstName] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[MiddleInitial] [varchar] (2) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[LastName] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Suffix] [char] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Address1] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Address2] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[City] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Region] [varchar] (5) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[PostalCode] [char] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[CouponExpire] [smalldatetime] NULL,
[AdCode] [int] NULL,
[CouponCode] [varchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[CourseID1] [int] NULL,
[CourseID2] [int] NULL,
[CourseID3] [int] NULL,
[CourseID4] [int] NULL,
[CourseID5] [int] NULL,
[WeekOfMailing] [smalldatetime] NULL
) ON [PRIMARY]
GO
