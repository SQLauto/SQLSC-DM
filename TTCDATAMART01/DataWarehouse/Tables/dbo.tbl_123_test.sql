CREATE TABLE [dbo].[tbl_123_test]
(
[id] [int] NULL
) ON [PRIMARY]
GO
EXEC sp_addextendedproperty N'Description', N' Detailed Description', 'SCHEMA', N'dbo', 'TABLE', N'tbl_123_test', NULL, NULL
GO
EXEC sp_addextendedproperty N'Description', 'Hey, here is my description!', 'SCHEMA', N'dbo', 'TABLE', N'tbl_123_test', 'COLUMN', N'id'
GO
