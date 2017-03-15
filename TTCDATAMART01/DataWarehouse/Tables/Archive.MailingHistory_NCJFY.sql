CREATE TABLE [Archive].[MailingHistory_NCJFY]
(
[CustomerID] [nvarchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[Adcode] [int] NULL,
[URL] [varchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[AcquisitionWeek] [datetime] NULL,
[CustGroup] [varchar] (7) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[HVLVGroup] [varchar] (2) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[JFYMailDate] [datetime] NULL,
[JFYStopDate] [datetime] NULL
) ON [PRIMARY]
GO
