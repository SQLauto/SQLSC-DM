CREATE TABLE [Marketing].[EPC_Prospect_EmailPull]
(
[Emailaddress] [varchar] (51) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[NewCourseAnnouncements] [int] NULL,
[FreeLecturesClipsandInterviews] [int] NULL,
[ExclusiveOffers] [int] NULL,
[EmailFrequency] [int] NULL,
[MagentoDaxMapped_Flag] [int] NULL,
[magento_created_date] [datetime] NULL,
[store_country] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[website_country] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[DMLastupdated] [datetime] NOT NULL
) ON [PRIMARY]
GO
