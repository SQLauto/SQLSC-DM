CREATE TABLE [dbo].[temp_CrossSell_demo]
(
[salesid] [nvarchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[linenum] [decimal] (28, 12) NOT NULL,
[itemid] [nvarchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[createdby] [nvarchar] (5) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[jscrosssell] [int] NOT NULL
) ON [PRIMARY]
GO
