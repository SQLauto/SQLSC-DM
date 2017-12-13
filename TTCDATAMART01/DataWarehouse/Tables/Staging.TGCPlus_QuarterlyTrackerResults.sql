CREATE TABLE [Staging].[TGCPlus_QuarterlyTrackerResults]
(
[RESPONDENTNUMBER] [float] NULL,
[SUBMITDATE] [datetime] NULL,
[EMAIL] [nvarchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[CUSTOMERID] [nvarchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[COUNTRY] [nvarchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[GENSAT_VALUE] [float] NULL,
[SUBSCRIPTION_RENEWAL_VALUE] [float] NULL,
[COURSEEXPECTATIONS_VALUE] [float] NULL,
[IDEALSTREAMINGSERVICE_VALUE] [float] NULL,
[RECOMMEND_VALUE] [float] NULL,
[WEBSITE_EASENAV_VALUE] [float] NULL,
[WEBSITE_LAYOUT_VALUE] [float] NULL,
[WEBSITE_ACCURACY_VALUE] [float] NULL,
[CUSTEFFORT_VALUE] [float] NULL,
[COURSESAT_VALUE] [float] NULL,
[USAGE_COMPUTER_VALUE] [float] NULL,
[USAGE_MOBILEWEB_VALUE] [float] NULL,
[USAGE_ROKU_VALUE] [float] NULL,
[USAGE_KINDLE_VALUE] [nvarchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[USAGE_ANDROIDPHONE_VALUE] [nvarchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[USAGE_IPHONE_VALUE] [float] NULL,
[USAGE_ANDROIDTABLET_VALUE] [float] NULL,
[USAGE_IPAD_VALUE] [float] NULL,
[USAGE_WINDOWS_VALUE] [float] NULL,
[USAGE_FIRETV_VALUE] [float] NULL,
[USAGE_APPLETV_VALUE] [float] NULL,
[FUNCSAT_COMPUTER_VALUE] [float] NULL,
[FUNCSAT_MOBILEWEB_VALUE] [float] NULL,
[FUNCSAT_ROKU_VALUE] [float] NULL,
[FUNCSAT_KINDLE_VALUE] [float] NULL,
[FUNCSAT_ANDROIDPHONE_VALUE] [float] NULL,
[FUNCSAT_IPHONE_VALUE] [float] NULL,
[FUNCSAT_ANDROIDTABLET_VALUE] [float] NULL,
[FUNCSAT_IPAD_VALUE] [float] NULL,
[FUNCSAT_WINDOWS_VALUE] [nvarchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[FUNCSAT_FIRETV_VALUE] [nvarchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[FUNCSAT_APPLETV_VALUE] [float] NULL,
[PERFSAT_COMPUTER_VALUE] [float] NULL,
[PERFSAT_MOBILEWEB_VALUE] [float] NULL,
[PERFSAT_ROKU_VALUE] [float] NULL,
[PERFSAT_KINDLE_VALUE] [nvarchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[PERFSAT_ANDROIDPHONE_VALUE] [nvarchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[PERFSAT_IPHONE_VALUE] [float] NULL,
[PERFSAT_ANDROIDTABLET_VALUE] [float] NULL,
[PERFSAT_IPAD_VALUE] [float] NULL,
[PERFSAT_WINDOWS_VALUE] [nvarchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[PERFSAT_FIRETV_VALUE] [nvarchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[PERFSAT_APPLETV_VALUE] [float] NULL
) ON [PRIMARY]
GO