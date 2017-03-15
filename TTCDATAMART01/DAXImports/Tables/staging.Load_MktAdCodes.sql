CREATE TABLE [staging].[Load_MktAdCodes]
(
[AdCode] [int] NOT NULL,
[CatalogCode] [int] NOT NULL,
[Name] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[Description] [varchar] (254) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[FixedCost] [money] NOT NULL,
[VariableCost] [money] NOT NULL,
[TotalCostToDate] [money] NOT NULL,
[ChannelType] [char] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ChannelName] [char] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[AdID] [int] NULL,
[SaleDate] [datetime] NULL,
[ActiveFlag] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[CostPerPiece] [money] NULL,
[PiecesMailed] [int] NULL,
[MiscLostFlag] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
