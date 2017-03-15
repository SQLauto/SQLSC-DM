CREATE TABLE [Mapping].[Email_adcode]
(
[EmailID] [varchar] (200) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[Adcode] [int] NULL,
[AdcodeName] [varchar] (200) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[Startdate] [datetime] NOT NULL,
[EndDate] [datetime] NOT NULL,
[Subjectline] [varchar] (300) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[SegmentGroup] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[TestFlag] [bit] NULL CONSTRAINT [DF__Email_adc__TestF__72946146] DEFAULT ((0)),
[CourseFlag] [bit] NULL CONSTRAINT [DF__Email_adc__FlagC__7388857F] DEFAULT ((0)),
[MaxCourses] [int] NULL CONSTRAINT [DF__Email_adc__MaxCo__747CA9B8] DEFAULT ((0)),
[EmailCompletedFlag] [bit] NULL CONSTRAINT [DF__Email_adc__Email__7570CDF1] DEFAULT ((0)),
[Countrycode] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[split_percentage] [int] NULL CONSTRAINT [DF__Email_adc__split__5993A952] DEFAULT ((100)),
[primary_adcode] [int] NULL,
[DLRAdcode] [int] NULL,
[DLRFlag] [bit] NULL,
[DLRTestFlag] [bit] NULL,
[DLRSplit_percentage] [int] NULL,
[Priority] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF__Email_adc__Prior__355281F3] DEFAULT ('I’d like to receive all exclusive offers')
) ON [PRIMARY]
GO
