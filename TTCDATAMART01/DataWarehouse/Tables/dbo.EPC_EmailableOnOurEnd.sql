CREATE TABLE [dbo].[EPC_EmailableOnOurEnd]
(
[DaxCustomerID_MGNT] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[EmailAddress_MGNT] [varchar] (150) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[DaxCustomerID_DAX] [nvarchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[EmailAddress_DAX] [nvarchar] (80) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[EmailPref] [int] NULL,
[ValidEmail] [int] NULL,
[ChildAccount] [int] NULL,
[Emailable] [int] NULL
) ON [PRIMARY]
GO
