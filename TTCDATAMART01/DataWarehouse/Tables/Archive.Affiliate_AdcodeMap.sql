CREATE TABLE [Archive].[Affiliate_AdcodeMap]
(
[Adcode] [int] NULL,
[Startdate] [date] NULL,
[DMLastUpdated] [datetime] NULL CONSTRAINT [DF__Affiliate__DMLas__6B97E92E] DEFAULT (getdate())
) ON [PRIMARY]
GO
