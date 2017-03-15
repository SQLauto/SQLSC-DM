SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
create VIEW [Staging].[vwCustomerEmailMailPreferences]
AS
    select convert(datetime,convert(varchar,CustomerSince,101)) CustomerSince,
          YEAR(CustomerSince) YearOf, Month(CustomerSince) MonthOf,
          DAY(customerSince) DayOf,
          CustomerID, EmailAddress, 
          EmailPreferenceID, EmailPreferenceValue, FlagEmailable, 
          MailPreferenceID, MailPreferenceValue
    from Marketing.DMCustomerStaticEmail
    where CustomerSInce >= DATEADD(month,-1,getdate())
GO
