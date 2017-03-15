SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE PROCEDURE [Staging].[CampaignEmail_DropTempTables]
AS
BEGIN
	set nocount on
    
    if object_id('Staging.TempECampaignCourseRank') is not null drop table Staging.TempECampaignCourseRank    
    if object_id('Staging.TempECampaignCourseRank2') is not null drop table Staging.TempECampaignCourseRank2        
    if object_id('Staging.TempECampaignEmailableCustomers') is not null drop table Staging.TempECampaignEmailableCustomers
    if object_id('Staging.TempECampaignCustomerCourseRank') is not null drop table Staging.TempECampaignCustomerCourseRank
    if object_id('Staging.TempECampaignEmailTemplate') is not null drop table Staging.TempECampaignEmailTemplate
    if object_id('Staging.TempECampaignBundleCourse') is not null drop table Staging.TempECampaignBundleCourse    
    if object_id('Staging.TempECampaignBundleCourseByCategory') is not null drop table Staging.TempECampaignBundleCourseByCategory    
END
GO
