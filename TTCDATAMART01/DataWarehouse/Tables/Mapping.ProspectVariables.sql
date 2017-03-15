CREATE TABLE [Mapping].[ProspectVariables]
(
[CustomerID] [nvarchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[MultiBuyerCodeLevel] [varchar] (5) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[MPKeyCode] [int] NULL,
[ListGroupLevel] [varchar] (40) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ListID] [varchar] (40) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ListName] [varchar] (500) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ListSelection] [varchar] (500) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ListTypeOld] [varchar] (40) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ListType] [varchar] (40) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ListLevel] [varchar] (5) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ResponseCategory] [varchar] (40) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ProductCategory] [varchar] (40) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[SubjectCategory] [varchar] (40) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ListOrderFrequency] [varchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[MBComboCategory] [varchar] (5) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[MBMatchingCombos] [varchar] (5) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[MailedAdcode] [int] NULL,
[Prior12MoContactsBin] [varchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[TableName] [varchar] (200) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[OSWType] [varchar] (40) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[OSWYear] [int] NULL,
[ListTypeName] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[MBComboCategoryName] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
