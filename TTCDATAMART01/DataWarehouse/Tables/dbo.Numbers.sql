CREATE TABLE [dbo].[Numbers]
(
[Number] [bigint] NULL
) ON [PRIMARY]
GO
CREATE UNIQUE CLUSTERED INDEX [n] ON [dbo].[Numbers] ([Number]) ON [PRIMARY]
GO
