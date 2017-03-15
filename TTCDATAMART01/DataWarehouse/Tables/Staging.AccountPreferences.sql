CREATE TABLE [Staging].[AccountPreferences]
(
[CustomerID] [nvarchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[PreferenceID] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL
) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [idx_AccountPreferences_PreferenceID] ON [Staging].[AccountPreferences] ([CustomerID], [PreferenceID]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IX_AccountPreferences] ON [Staging].[AccountPreferences] ([PreferenceID]) INCLUDE ([CustomerID]) ON [PRIMARY]
GO
