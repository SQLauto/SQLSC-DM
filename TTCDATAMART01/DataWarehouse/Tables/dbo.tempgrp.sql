CREATE TABLE [dbo].[tempgrp]
(
[CustomerID] [nvarchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[FirstName] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[LastName] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[MaxOpenDate] [datetime] NULL,
[SingleOrMulti] [varchar] (5) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[EmailAddress] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[FlagSelected] [int] NOT NULL,
[LastOrderDate] [datetime] NULL,
[CountryCode] [varchar] (3) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[PreferredCategory2] [varchar] (5) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[MediaFormatPreference] [varchar] (2) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[OrderSourcePreference] [varchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[CustGroup] [int] NULL
) ON [PRIMARY]
GO
