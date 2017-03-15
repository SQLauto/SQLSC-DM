CREATE TABLE [dbo].[DATES]
(
[DateID] [int] NOT NULL,
[Date] [date] NOT NULL,
[Year] [int] NOT NULL,
[Month] [int] NOT NULL,
[Day] [int] NOT NULL,
[QuarterNumber] [int] NOT NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[DATES] ADD CONSTRAINT [PK_Dates] PRIMARY KEY CLUSTERED  ([DateID]) ON [PRIMARY]
GO
