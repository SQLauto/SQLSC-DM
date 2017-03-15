CREATE TABLE [Mapping].[MktDim_Year]
(
[MD_YearID] [int] NOT NULL IDENTITY(1, 1),
[MD_Year] [int] NOT NULL,
[MD_Year_Description] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[FlagActive] [tinyint] NULL CONSTRAINT [DF__MktDim_Ye__FlagA__09589664] DEFAULT ((1))
) ON [PRIMARY]
GO
ALTER TABLE [Mapping].[MktDim_Year] ADD CONSTRAINT [pk_Year_yid] PRIMARY KEY CLUSTERED  ([MD_Year]) ON [PRIMARY]
GO
