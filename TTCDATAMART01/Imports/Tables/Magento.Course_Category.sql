CREATE TABLE [Magento].[Course_Category]
(
[Course_ID] [int] NOT NULL,
[Category_ID] [int] NOT NULL,
[Position] [int] NULL
) ON [PRIMARY]
GO
ALTER TABLE [Magento].[Course_Category] ADD CONSTRAINT [PK__Course_C__C13B3D2FE37656F5] PRIMARY KEY CLUSTERED  ([Course_ID], [Category_ID]) ON [PRIMARY]
GO
