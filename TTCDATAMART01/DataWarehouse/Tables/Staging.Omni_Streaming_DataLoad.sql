CREATE TABLE [Staging].[Omni_Streaming_DataLoad]
(
[Date] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[customerID] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[CourseID] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[lecture_number] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[media_type] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[transaction_type] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[platform] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[device] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[action] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[total_actions] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[stream_seconds] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Userid] [varchar] (200) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[medianame] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[country] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Video_Length] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
