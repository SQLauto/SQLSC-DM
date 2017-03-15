CREATE TABLE [Staging].[rfm_movement_new]
(
[EffectiveDate] [datetime] NULL,
[MovementCategory] [char] (3) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[RFM] [char] (7) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[A12MF] [int] NULL,
[MovementType] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[MovementCount] [int] NULL,
[FlagDRTV] [bit] NULL
) ON [PRIMARY]
GO
