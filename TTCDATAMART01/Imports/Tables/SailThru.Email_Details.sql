CREATE TABLE [SailThru].[Email_Details]
(
[Email] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[Engagement] [varchar] (max) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Activity_Click_Time] [varchar] (max) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Activity_Create_Time] [varchar] (max) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Activity_Login_Time] [varchar] (max) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Activity_Open_Time] [varchar] (max) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Activity_Signup_Time] [varchar] (max) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Top_Device_Email] [varchar] (max) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Lifetime_Click] [int] NULL,
[Lifetime_Message] [int] NULL,
[Lifetime_Open] [int] NULL,
[List_Count] [int] NULL,
[Lists] [varchar] (max) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[JSON] [varchar] (max) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
ALTER TABLE [SailThru].[Email_Details] ADD CONSTRAINT [PK__Email_De__A9D105358D32599A] PRIMARY KEY CLUSTERED  ([Email]) ON [PRIMARY]
GO
