CREATE TABLE [dbo].[DimDate]
(
[DateID] [int] NOT NULL,
[Date] [datetime] NOT NULL,
[Year] [int] NOT NULL,
[Month] [int] NOT NULL,
[Day] [int] NOT NULL,
[Half] [int] NOT NULL,
[Quarter] [int] NOT NULL,
[Week] [int] NOT NULL,
[Weekend] [int] NOT NULL,
[FlagHoliday] [int] NOT NULL CONSTRAINT [DF__DimDate__FlagHol__70ACE42B] DEFAULT ((0))
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[DimDate] ADD CONSTRAINT [PK_DimDate_id] PRIMARY KEY CLUSTERED  ([DateID]) ON [PRIMARY]
GO
