CREATE TABLE [dbo].[WebBestSellerRank]
(
[course_id] [int] NOT NULL,
[guest_bestsellers_rank] [float] NULL,
[authenticated_bestsellers_rank] [float] NULL,
[website] [nvarchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[UpdateDate] [datetime] NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[WebBestSellerRank] ADD CONSTRAINT [PK_WebBestSellerRank] PRIMARY KEY CLUSTERED  ([course_id], [website]) ON [PRIMARY]
GO
