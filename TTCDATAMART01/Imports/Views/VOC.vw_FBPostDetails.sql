SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE VIEW [VOC].[vw_FBPostDetails] as
select distinct post_id, cast(post_date as date) post_date from Imports.VOC.FB_TopLevelComments
; 

GO
