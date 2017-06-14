CREATE TABLE [Staging].[TempTGCandPlusMappingStream]
(
[CustomerID] [nvarchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[FlagStreamedTGCL12M] [int] NOT NULL,
[FlagStreamedTGCL12M_DgAudio] [int] NULL,
[FlagStreamedTGCL12M_DgVideo] [int] NULL,
[FlagStreamedTGCL12M_PhyAudio] [int] NULL,
[FlagStreamedTGCL12M_PhyVideo] [int] NULL
) ON [PRIMARY]
GO
