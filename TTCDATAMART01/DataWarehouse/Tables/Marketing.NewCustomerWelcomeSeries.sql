CREATE TABLE [Marketing].[NewCustomerWelcomeSeries]
(
[CustomerID] [nvarchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[MinOrderIDinPeriod] [nvarchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[MinPurchDateInPeriod] [datetime] NULL,
[EmailAddress] [varchar] (60) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[CustomerSince] [datetime] NULL,
[AcquisitionWeek] [datetime] NULL,
[WPMailDate] [datetime] NULL,
[WEmailDate] [datetime] NULL,
[YourAccountEDate] [datetime] NULL,
[FeedBackEmailDate] [datetime] NULL,
[WPEmailDLRDate] [datetime] NULL,
[ComboID] [varchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[NewSeg] [int] NULL,
[Name] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[A12mf] [int] NULL,
[PreferredCategory2] [varchar] (5) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[FlagEmail] [int] NULL,
[FlagEmailPref] [int] NULL,
[FlagValidEmail] [tinyint] NULL,
[FlagMail] [int] NULL,
[Address1] [nvarchar] (120) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Address2] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Address3] [nvarchar] (120) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[City] [nvarchar] (60) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[State] [varchar] (40) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[CountryCode] [varchar] (3) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[FlagReceivedSpclShipCat] [int] NOT NULL,
[CustGroup] [varchar] (7) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[HVLVGroup] [varchar] (2) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[PullDate] [datetime] NULL,
[FlagDigitalPhysical] [varchar] (15) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[FlagAudioVideo] [varchar] (15) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[FeedBackCourseID1] [int] NULL,
[RecoEmailDate] [datetime] NULL,
[JFYEmailDLRDate] [datetime] NULL,
[JFYMailDate] [datetime] NULL,
[ItemID] [varchar] (15) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[FlagOther] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IX_NewCustomerWelcomeSeries_Cover1] ON [Marketing].[NewCustomerWelcomeSeries] ([HVLVGroup]) INCLUDE ([CustomerID], [EmailAddress]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IX_NewCustomerWelcomeSeries_Cover3] ON [Marketing].[NewCustomerWelcomeSeries] ([HVLVGroup], [CustomerID]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IX_NewCustomerWelcomeSeries_Cover2] ON [Marketing].[NewCustomerWelcomeSeries] ([HVLVGroup], [EmailAddress]) ON [PRIMARY]
GO
