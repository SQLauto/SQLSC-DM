SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE VIEW [Archive].[vw_Tableau_AppsFlyerEvents]
AS
SELECT        a.AsofDate, a.CustomerID, a.uuid, a.EmailAddress, a.TGCCustomerID, a.CountryCode, a.IntlCampaignID, a.IntlCampaignName, a.IntlMD_Country, a.IntlMD_Audience, 
                         a.IntlMD_Channel, a.IntlMD_ChannelID, a.IntlMD_PromotionType, a.IntlMD_PromotionTypeID, a.IntlMD_Year, a.IntlSubDate, a.IntlSubWeek, a.IntlSubMonth, 
                         a.IntlSubYear, a.IntlSubPlanID, a.IntlSubPlanName, a.IntlSubType, a.IntlSubPaymentHandler, a.SubDate, a.SubWeek, a.SubMonth, a.SubYear, a.SubPlanID, 
                         a.SubPlanName, a.SubType, a.SubPaymentHandler, a.TransactionType, a.CustStatusFlag, a.PaidFlag, a.LTDPaidAmt, a.LastPaidDate, a.LastPaidWeek, 
                         a.LastPaidMonth, a.LastPaidYear, a.LastPaidAmt, a.DSDayCancelled, a.DSMonthCancelled, a.DSDayDeferred, a.TGCCustFlag, a.TGCCustSegmentFcst, 
                         a.TGCCustSegmentFnl, a.MaxSeqNum, a.FirstName, a.LastName, a.Gender, a.Age, a.AgeBin, a.HouseHoldIncomeBin, a.EducationBin, a.address1, a.address2, 
                         a.address3, a.city, a.state, a.country, a.ZipCode, a.RegDate, a.RegMonth, a.RegYear, a.IntlPaidAmt, a.IntlPaidDate, a.DSMonthCancelled_New, a.DS, a.BillingRank, 
                         a.LTDPaymentRank, a.LTDNetPaymentRank, a.DSLTDAmount, a.DSLTDNetAmount, a.Reactivated, a.RFMGroup, b.AttributedTouchType, b.EventName, 
                         b.MediaSource, b.Campaign, CASE WHEN isnull(c.DateDiffCol, 0) = 0 THEN 0 ELSE 1 END AS VLDataIssueIndicator
FROM            Archive.Vw_TGCPlus_CustomerSignature AS a WITH (nolock) LEFT OUTER JOIN
                         Marketing.TGCPLus_AppsFlyer_AppEvents AS b WITH (nolock) ON a.uuid = b.CustomerUserID LEFT OUTER JOIN
                             (SELECT        DATEDIFF(m, MinDSDate, MaxDSDate) AS DateDiffCol, LTDPaymentRank AS FinalLTDPaymentRank, CustomerID, DSDate, DS, DSDays, 
                                                         EntitlementDays, DS_Service_period_from, DS_Service_period_to, DS_Month, DS_ValidDS, DS_Entitled, completed_at, billing_cycle_period_type, 
                                                         Type, pre_tax_amount, service_period_from, service_period_to, actual_service_period_to, subscription_plan_id, payment_handler, BillingRank, 
                                                         Refunded, RefundedAmount, Refunded_Completed_at, Changed_Service_period_to, Changed_Billing_cycle_period_type, 
                                                         Changed_Subscription_plan_id, Changed_Payment_handler, PAS_Cancelled_date, PAS_DeferredSuspension_date, PAS_Suspended_date, Cancelled, 
                                                         Suspended, DeferredSuspension, Prior_billing_cycle_period_type, Prior_subscription_plan_id, Prior_payment_handler, Amount, NetAmount, DSSplits, 
                                                         PaidFlag, BillingDupes, UBIssue, MinDS, MinDSDate, MaxDS, MaxDSDate, LTDAmount, LTDNetAmount, LTDPaymentRank, LTDNetPaymentRank, 
                                                         IntlDSbilling_cycle_period_type, IntlDSsubscription_plan_id, IntlDSpayment_handler, IntlDSAmount, IntlDSuso_offer_id, 
                                                         SubDSbilling_cycle_period_type, SubDSsubscription_plan_id, SubDSpayment_handler, SubDSAmount, SubDSuso_offer_id, CurrentDS, uso_offer_id, 
                                                         uso_offer_code_applied, uso_applied_at, Reactivated, DMLastupdated
                               FROM            Archive.TGCplus_DS WITH (nolock)
                               WHERE        (DATEDIFF(m, MinDSDate, MaxDSDate) + 1 < LTDPaymentRank) AND (CurrentDS = 1)) AS c ON a.CustomerID = c.CustomerID
WHERE        (a.IntlSubDate >= '2017-08-24') AND (a.IntlSubPaymentHandler IN ('ioS', 'Android'))
GO
EXEC sp_addextendedproperty N'MS_DiagramPane1', N'[0E232FF0-B466-11cf-A24F-00AA00A3EFFF, 1.00]
Begin DesignProperties = 
   Begin PaneConfigurations = 
      Begin PaneConfiguration = 0
         NumPanes = 4
         Configuration = "(H (1[34] 4[26] 2[20] 3) )"
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
         Begin Table = "a"
            Begin Extent = 
               Top = 6
               Left = 38
               Bottom = 135
               Right = 262
            End
            DisplayFlags = 280
            TopColumn = 0
         End
         Begin Table = "b"
            Begin Extent = 
               Top = 104
               Left = 410
               Bottom = 233
               Right = 680
            End
            DisplayFlags = 280
            TopColumn = 0
         End
         Begin Table = "c"
            Begin Extent = 
               Top = 6
               Left = 718
               Bottom = 135
               Right = 992
            End
            DisplayFlags = 280
            TopColumn = 0
         End
      End
   End
   Begin SQLPane = 
   End
   Begin DataPane = 
      Begin ParameterDefaults = ""
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
', 'SCHEMA', N'Archive', 'VIEW', N'vw_Tableau_AppsFlyerEvents', NULL, NULL
GO
DECLARE @xp int
SELECT @xp=1
EXEC sp_addextendedproperty N'MS_DiagramPaneCount', @xp, 'SCHEMA', N'Archive', 'VIEW', N'vw_Tableau_AppsFlyerEvents', NULL, NULL
GO
