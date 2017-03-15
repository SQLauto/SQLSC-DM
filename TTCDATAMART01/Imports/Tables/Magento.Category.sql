CREATE TABLE [Magento].[Category]
(
[Category_ID] [int] NOT NULL,
[Name] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Category_Title] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Is_Active] [int] NULL,
[Parent_ID] [int] NULL,
[Path] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Level] [int] NULL,
[Children_Count] [int] NULL
) ON [PRIMARY]
GO
ALTER TABLE [Magento].[Category] ADD CONSTRAINT [PK__Category__6DB38D4E0BFB3221] PRIMARY KEY CLUSTERED  ([Category_ID]) ON [PRIMARY]
GO
