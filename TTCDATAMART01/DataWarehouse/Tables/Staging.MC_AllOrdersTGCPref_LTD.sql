CREATE TABLE [Staging].[MC_AllOrdersTGCPref_LTD]
(
[CustomerID] [nvarchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[OrderID] [nvarchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[DateOrdered] [datetime] NULL,
[Adcode] [int] NULL,
[MD_ChannelID] [int] NULL,
[MD_Channel] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[MD_ChannelRU] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[PhysclMail_ChnlRU] [bit] NULL,
[SpaceAds_ChnlRU] [bit] NULL,
[DgtlMrktng_ChnlRU] [bit] NULL,
[Email_ChnlRU] [bit] NULL,
[WebDefault_ChnlRU] [bit] NULL,
[Other_ChnlRU] [bit] NULL,
[OrderItemID] [numeric] (28, 12) NULL,
[CourseID] [int] NULL,
[Parts] [money] NULL,
[SubjectCategory2] [varchar] (5) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[OrderSource] [nchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[PhoneOS] [bit] NULL,
[WebOS] [bit] NULL,
[EmailOS] [bit] NULL,
[MailOS] [bit] NULL,
[OtherOS] [bit] NULL,
[FormatMedia] [char] (2) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[DVD] [bit] NULL,
[CD] [bit] NULL,
[DigitalVideo] [bit] NULL,
[DigitalAudio] [bit] NULL,
[VideoTape] [bit] NULL,
[AudioTape] [bit] NULL,
[FormatAV] [char] (2) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[FormatPD] [varchar] (8) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[AsOfDate] [date] NULL
) ON [PRIMARY]
GO
