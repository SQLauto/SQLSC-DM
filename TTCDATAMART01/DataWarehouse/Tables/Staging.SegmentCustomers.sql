CREATE TABLE [Staging].[SegmentCustomers]
(
[CustomerID] [int] NOT NULL,
[IntlSubjectPref] [char] (2) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[IntlFormatAVPref] [char] (2) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[Gender] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[SegmentGroup] [char] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL
) ON [PRIMARY]
GO
