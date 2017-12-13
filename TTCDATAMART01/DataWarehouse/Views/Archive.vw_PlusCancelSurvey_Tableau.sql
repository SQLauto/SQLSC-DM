SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE VIEW [Archive].[vw_PlusCancelSurvey_Tableau]
AS
SELECT        Main.uuid, Main.CancelDate, a.customerid, CASE WHEN a.TGCCustFlag = 1 THEN 'TGC Customer' ELSE 'Not a TGC Customer' END AS TGCCustomerType, 
                         a.IntlMD_Channel, a.IntlSubDate, a.IntlSubType, a.IntlSubPaymentHandler, isnull(a.LTDPaidAmt, 0) LTDPaidAmt, a.DSDayCancelled, 
                         isnull(Cancel.Cancel_Foundanothersourceforthecontentthatinterestsme, 0) Cancel_Foundanothersourceforthecontentthatinterestsme, 
                         isnull(Cancel.Cancel_Isnotavailableordoesnotperformwellonmypreferredviewingdevice, 0) Cancel_Isnotavailableordoesnotperformwellonmypreferredviewingdevice, 
                         isnull(Cancel.Cancel_Notenoughtimetowatchthevideos, 0) Cancel_Notenoughtimetowatchthevideos, isnull(Cancel.Cancel_Priceistoohighforthevalueoftheservice, 0) 
                         Cancel_Priceistoohighforthevalueoftheservice, isnull(Cancel.Cancel_Videoprogrammingdidnotmeetmyexpectations, 0) 
                         Cancel_Videoprogrammingdidnotmeetmyexpectations, isnull(Feature.[Feature_Ability to pause your subscription for a period of time], 0) 
                         [Feature_Ability to pause your subscription for a period of time], isnull(Feature.[Feature_Availability of audio-only courses], 0) 
                         [Feature_Availability of audio-only courses], isnull(Feature.[Feature_More content from preferred partners], 0) [Feature_More content from preferred partners], 
                         isnull(Feature.[Feature_Special offers related to monthly and annual plans], 0) [Feature_Special offers related to monthly and annual plans],
						 isnull(Feature.[Feature_Provide certificates of course completion and/or quizzes measuring understanding of course material] ,0) [Feature_Provide certificates of course completion and/or quizzes measuring understanding of course material]
FROM            Marketing.TGCPLus_GA_Cancels(nolock) Main LEFT JOIN
                         marketing.tgcplus_customersignature(nolock) a ON Main.uuid = a.uuid LEFT JOIN
                             (SELECT        uuid, [1] AS [Cancel_Foundanothersourceforthecontentthatinterestsme], 
                                                         [2] AS [Cancel_Isnotavailableordoesnotperformwellonmypreferredviewingdevice], [3] AS [Cancel_Notenoughtimetowatchthevideos], 
                                                         [4] AS [Cancel_Priceistoohighforthevalueoftheservice], [5] AS [Cancel_Videoprogrammingdidnotmeetmyexpectations], [6] AS [Cancel_Others]
                               FROM            (SELECT        uuid, CASE WHEN Replace(EventLabel, ' ', '') = 'Foundanothersourceforthecontentthatinterestsme' THEN 1 WHEN Replace(EventLabel, ' ', 
                                                                                   '') = 'Isnotavailableordoesnotperformwellonmypreferredviewingdevice' THEN 2 WHEN Replace(EventLabel, ' ', '') 
                                                                                   = 'Notenoughtimetowatchthevideos' THEN 3 WHEN Replace(EventLabel, ' ', '') 
                                                                                   = 'Priceistoohighforthevalueoftheservice' THEN 4 WHEN Replace(EventLabel, ' ', '') 
                                                                                   = 'Videoprogrammingdidnotmeetmyexpectations' THEN 5 ELSE 6 END AS EventLabel, users
                                                         FROM            archive.ga_survey(nolock)
                                                         WHERE        Action = 'Cancel Survey - Why are you canceling your Great Courses Plus Subscription') p PIVOT (COUNT(users) FOR EventLabel IN ([1], 
                                                         [2], [3], [4], [5], [6])) AS pvt) Cancel ON Main.uuid = Cancel.uuid LEFT JOIN
                             (SELECT        uuid, [1] AS [Feature_Ability to pause your subscription for a period of time], [2] AS [Feature_Availability of audio-only courses], 
                                                         [3] AS [Feature_More content from preferred partners], [4] AS [Feature_Special offers related to monthly and annual plans], 
														 [5] as [Feature_Provide certificates of course completion and/or quizzes measuring understanding of course material], 
                                                         [6] AS [Feature_Others]
                               FROM            (SELECT        uuid, 
																	CASE 
																		WHEN Replace(EventLabel, ' ', '') = 'Abilitytopauseyoursubscriptionforaperiodoftime' THEN 1 
																		WHEN Replace(EventLabel, ' ', '') = 'Availabilityofaudio-onlycourses' THEN 2 
																		WHEN Replace(EventLabel, ' ', '') = 'Morecontentfrompreferredpartners(suchasNationalGeographic,Smithsonian,etc.)' THEN 3 
																		WHEN Replace(EventLabel, ' ', '') = 'Specialoffersrelatedtomonthlyandannualplans' THEN 4 
																		WHEN EventLabel = 'Provide certificates of course completion and/or quizzes measuring understanding of course material' then 5
																		ELSE 6 END AS EventLabel, users
                                                         FROM            archive.ga_survey(nolock)
                                                         WHERE        Action = 'Cancel Survey - Would the following features reverse your decision to cancel?') p PIVOT (COUNT(users) FOR EventLabel IN ([1], 
                                                         [2], [3], [4], [5], [6])) AS pvt) Feature ON Main.uuid = Feature.uuid
WHERE        Main.CancelDate > '2017-08-03' AND IIF(a.customerid IS NULL, 1, 0) = 0 AND iif(Main.uuid IS NULL, 1, 0) = 0;
GO
EXEC sp_addextendedproperty N'MS_DiagramPane1', N'[0E232FF0-B466-11cf-A24F-00AA00A3EFFF, 1.00]
Begin DesignProperties = 
   Begin PaneConfigurations = 
      Begin PaneConfiguration = 0
         NumPanes = 4
         Configuration = "(H (1[25] 4[23] 2[23] 3) )"
      End
      Begin PaneConfiguration = 1
         NumPanes = 3
         Configuration = "(H (1 [50] 4 [25] 3))"
      End
      Begin PaneConfiguration = 2
         NumPanes = 3
         Configuration = "(H (1 [50] 2 [25] 3))"
      End
      Begin PaneConfiguration = 3
         NumPanes = 3
         Configuration = "(H (4 [30] 2 [40] 3))"
      End
      Begin PaneConfiguration = 4
         NumPanes = 2
         Configuration = "(H (1 [56] 3))"
      End
      Begin PaneConfiguration = 5
         NumPanes = 2
         Configuration = "(H (2 [66] 3))"
      End
      Begin PaneConfiguration = 6
         NumPanes = 2
         Configuration = "(H (4 [50] 3))"
      End
      Begin PaneConfiguration = 7
         NumPanes = 1
         Configuration = "(V (3))"
      End
      Begin PaneConfiguration = 8
         NumPanes = 3
         Configuration = "(H (1[56] 4[18] 2) )"
      End
      Begin PaneConfiguration = 9
         NumPanes = 2
         Configuration = "(H (1 [75] 4))"
      End
      Begin PaneConfiguration = 10
         NumPanes = 2
         Configuration = "(H (1[66] 2) )"
      End
      Begin PaneConfiguration = 11
         NumPanes = 2
         Configuration = "(H (4 [60] 2))"
      End
      Begin PaneConfiguration = 12
         NumPanes = 1
         Configuration = "(H (1) )"
      End
      Begin PaneConfiguration = 13
         NumPanes = 1
         Configuration = "(V (4))"
      End
      Begin PaneConfiguration = 14
         NumPanes = 1
         Configuration = "(V (2))"
      End
      ActivePaneConfig = 0
   End
   Begin DiagramPane = 
      Begin Origin = 
         Top = 0
         Left = 0
      End
      Begin Tables = 
      End
   End
   Begin SQLPane = 
   End
   Begin DataPane = 
      Begin ParameterDefaults = ""
      End
      Begin ColumnWidths = 9
         Width = 284
         Width = 1500
         Width = 1500
         Width = 1500
         Width = 1500
         Width = 1500
         Width = 1500
         Width = 1500
         Width = 1500
      End
   End
   Begin CriteriaPane = 
      Begin ColumnWidths = 11
         Column = 1440
         Alias = 900
         Table = 1170
         Output = 720
         Append = 1400
         NewValue = 1170
         SortType = 1350
         SortOrder = 1410
         GroupBy = 1350
         Filter = 1350
         Or = 1350
         Or = 1350
         Or = 1350
      End
   End
End
', 'SCHEMA', N'Archive', 'VIEW', N'vw_PlusCancelSurvey_Tableau', NULL, NULL
GO
DECLARE @xp int
SELECT @xp=1
EXEC sp_addextendedproperty N'MS_DiagramPaneCount', @xp, 'SCHEMA', N'Archive', 'VIEW', N'vw_PlusCancelSurvey_Tableau', NULL, NULL
GO
