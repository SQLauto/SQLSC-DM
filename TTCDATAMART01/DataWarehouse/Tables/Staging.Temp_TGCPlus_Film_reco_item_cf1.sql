CREATE TABLE [Staging].[Temp_TGCPlus_Film_reco_item_cf1]
(
[vid_1] [varchar] (256) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[vid_2] [varchar] (256) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[cosine_similarity] [float] NULL,
[dot_prod_StreamedMins] [numeric] (38, 2) NULL,
[vect_length_StreamedMins_1] [float] NOT NULL,
[vect_length_StreamedMins_2] [float] NOT NULL,
[vid_2_rec_rank] [bigint] NULL
) ON [PRIMARY]
GO
