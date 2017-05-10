CREATE TABLE [SailThru].[API_Errors]
(
[ID] [bigint] NOT NULL IDENTITY(1, 1),
[Email] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Log_Datetime] [datetime] NOT NULL,
[Error_Code] [int] NULL,
[Error_Response] [varchar] (max) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[JSON] [varchar] (max) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
