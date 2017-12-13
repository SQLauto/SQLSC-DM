CREATE TABLE [Marketing].[TGCPlus_CllbrtvFilter_CourseReco]
(
[vid_1] [bigint] NULL,
[vid_2] [bigint] NULL,
[cosine_similarity] [float] NULL,
[dot_prod_StreamedMins] [numeric] (38, 2) NULL,
[vect_length_StreamedMins_1] [float] NOT NULL,
[vect_length_StreamedMins_2] [float] NOT NULL,
[vid_2_rec_rank] [bigint] NULL,
[Course_id] [bigint] NULL,
[CourseName] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Reco_CourseID] [bigint] NULL,
[Reco_CourseName] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
