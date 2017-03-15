CREATE TABLE [dbo].[TempFormat_20170117DEL]
(
[customerid] [nvarchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[orderid] [nvarchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[dateordered] [smalldatetime] NULL,
[orderitemid] [numeric] (28, 12) NULL,
[courseid] [int] NULL,
[parts] [dbo].[udtCourseParts] NULL,
[subjectcategory] [dbo].[udtSubjectPreference] NULL,
[SubjectCategory2] [dbo].[udtSubjectPreference] NULL,
[FormatMedia] [char] (2) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
