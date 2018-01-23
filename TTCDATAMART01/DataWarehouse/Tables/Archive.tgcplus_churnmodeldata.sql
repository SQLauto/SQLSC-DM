CREATE TABLE [Archive].[tgcplus_churnmodeldata]
(
[CustomerID] [bigint] NULL,
[Domain] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[DSMonthCancelled_new] [int] NULL,
[PaidType] [varchar] (19) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[TGCCustomerType] [varchar] (18) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[TGCCustSegmentFnl] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Gender] [varchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Age] [int] NULL,
[HouseHoldIncomeBin] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[EducationBin] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[city] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[State] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[IntlCampaignName] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[IntlMD_Channel] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[IntlMD_PromotionType] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[IntlSubDate] [date] NULL,
[IntlSubPaymentHandler] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[IntlPaidDate] [date] NULL,
[IntlPaidAmt] [float] NULL,
[LastPaidDate] [date] NULL,
[LTDPaidAmt] [float] NULL,
[LastPaidAmt] [float] NULL,
[DSDayCancelled] [int] NULL,
[registered_via_platform] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[FirstDeviceCategory] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[BrowserSignUp] [varchar] (7) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[FirstStreamDate] [date] NULL,
[Days_Join_Stream] [int] NULL,
[FirstPlatform] [varchar] (256) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[FirstBrowser] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[FirstCourse] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[FirstLecture] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[FirstLectureNumber] [bigint] NULL,
[FirstGenre] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[FirstFilmType] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[HouseholdIncome_Median] [float] NULL,
[ZipPopulation] [float] NULL,
[Categories_7days] [int] NULL,
[Courses_7days] [int] NULL,
[Lectures_7days] [int] NULL,
[StreamedMins_7days] [numeric] (38, 1) NULL,
[Categories_14days] [int] NULL,
[Courses_14days] [int] NULL,
[Lectures_14days] [int] NULL,
[StreamedMins_14days] [numeric] (38, 1) NULL,
[Categories_30days] [int] NULL,
[Courses_30days] [int] NULL,
[Lectures_30days] [int] NULL,
[StreamedMins_30days] [numeric] (38, 1) NULL,
[CardBrand] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[CardFunding] [varchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Day1Consumption] [numeric] (38, 1) NULL,
[Day2Consumption] [numeric] (38, 1) NULL,
[Day3Consumption] [numeric] (38, 1) NULL,
[Day4Consumption] [numeric] (38, 1) NULL,
[Day5Consumption] [numeric] (38, 1) NULL,
[Day6Consumption] [numeric] (38, 1) NULL,
[Day7Consumption] [numeric] (38, 1) NULL,
[Day8Consumption] [numeric] (38, 1) NULL,
[Day9Consumption] [numeric] (38, 1) NULL,
[Day10Consumption] [numeric] (38, 1) NULL,
[Day11Consumption] [numeric] (38, 1) NULL,
[Day12Consumption] [numeric] (38, 1) NULL,
[Day13Consumption] [numeric] (38, 1) NULL,
[Day14Consumption] [numeric] (38, 1) NULL,
[Day15Consumption] [numeric] (38, 1) NULL,
[Day16Consumption] [numeric] (38, 1) NULL,
[Day17Consumption] [numeric] (38, 1) NULL,
[Day18Consumption] [numeric] (38, 1) NULL,
[Day19Consumption] [numeric] (38, 1) NULL,
[Day20Consumption] [numeric] (38, 1) NULL,
[Day21Consumption] [numeric] (38, 1) NULL,
[Day22Consumption] [numeric] (38, 1) NULL,
[Day23Consumption] [numeric] (38, 1) NULL,
[Day24Consumption] [numeric] (38, 1) NULL,
[Day25Consumption] [numeric] (38, 1) NULL,
[Day26Consumption] [numeric] (38, 1) NULL,
[Day27Consumption] [numeric] (38, 1) NULL,
[Day28Consumption] [numeric] (38, 1) NULL,
[Day29Consumption] [numeric] (38, 1) NULL,
[Day30Consumption] [numeric] (38, 1) NULL,
[Day1Genres] [int] NULL,
[Day2Genres] [int] NULL,
[Day3Genres] [int] NULL,
[Day4Genres] [int] NULL,
[Day5Genres] [int] NULL,
[Day6Genres] [int] NULL,
[Day7Genres] [int] NULL,
[Day8Genres] [int] NULL,
[Day9Genres] [int] NULL,
[Day10Genres] [int] NULL,
[Day11Genres] [int] NULL,
[Day12Genres] [int] NULL,
[Day13Genres] [int] NULL,
[Day14Genres] [int] NULL,
[Day15Genres] [int] NULL,
[Day16Genres] [int] NULL,
[Day17Genres] [int] NULL,
[Day18Genres] [int] NULL,
[Day19Genres] [int] NULL,
[Day20Genres] [int] NULL,
[Day21Genres] [int] NULL,
[Day22Genres] [int] NULL,
[Day23Genres] [int] NULL,
[Day24Genres] [int] NULL,
[Day25Genres] [int] NULL,
[Day26Genres] [int] NULL,
[Day27Genres] [int] NULL,
[Day28Genres] [int] NULL,
[Day29Genres] [int] NULL,
[Day30Genres] [int] NULL,
[Day1Lectures] [int] NULL,
[Day2Lectures] [int] NULL,
[Day3Lectures] [int] NULL,
[Day4Lectures] [int] NULL,
[Day5Lectures] [int] NULL,
[Day6Lectures] [int] NULL,
[Day7Lectures] [int] NULL,
[Day8Lectures] [int] NULL,
[Day9Lectures] [int] NULL,
[Day10Lectures] [int] NULL,
[Day11Lectures] [int] NULL,
[Day12Lectures] [int] NULL,
[Day13Lectures] [int] NULL,
[Day14Lectures] [int] NULL,
[Day15Lectures] [int] NULL,
[Day16Lectures] [int] NULL,
[Day17Lectures] [int] NULL,
[Day18Lectures] [int] NULL,
[Day19Lectures] [int] NULL,
[Day20Lectures] [int] NULL,
[Day21Lectures] [int] NULL,
[Day22Lectures] [int] NULL,
[Day23Lectures] [int] NULL,
[Day24Lectures] [int] NULL,
[Day25Lectures] [int] NULL,
[Day26Lectures] [int] NULL,
[Day27Lectures] [int] NULL,
[Day28Lectures] [int] NULL,
[Day29Lectures] [int] NULL,
[Day30Lectures] [int] NULL,
[AdobePageActivity_AccountPageVisits] [bigint] NULL,
[AdobePageActivity_FAQVisits] [bigint] NULL,
[AdobePageActivity_SocialPageVisits] [bigint] NULL,
[AdobePageActivity_RegistrationPageVisits] [bigint] NULL,
[AdobePageActivity_CancelPageVisits] [bigint] NULL,
[Day1_FR] [numeric] (38, 6) NULL,
[Day2_FR] [numeric] (38, 6) NULL,
[Day3_FR] [numeric] (38, 6) NULL,
[Day4_FR] [numeric] (38, 6) NULL,
[Day5_FR] [numeric] (38, 6) NULL,
[Day6_FR] [numeric] (38, 6) NULL,
[Day7_FR] [numeric] (38, 6) NULL,
[Day8_FR] [numeric] (38, 6) NULL,
[Day9_FR] [numeric] (38, 6) NULL,
[Day10_FR] [numeric] (38, 6) NULL,
[Day11_FR] [numeric] (38, 6) NULL,
[Day12_FR] [numeric] (38, 6) NULL,
[Day13_FR] [numeric] (38, 6) NULL,
[Day14_FR] [numeric] (38, 6) NULL,
[Day15_FR] [numeric] (38, 6) NULL,
[Day16_FR] [numeric] (38, 6) NULL,
[Day17_FR] [numeric] (38, 6) NULL,
[Day18_FR] [numeric] (38, 6) NULL,
[Day19_FR] [numeric] (38, 6) NULL,
[Day20_FR] [numeric] (38, 6) NULL,
[Day21_FR] [numeric] (38, 6) NULL,
[Day22_FR] [numeric] (38, 6) NULL,
[Day23_FR] [numeric] (38, 6) NULL,
[Day24_FR] [numeric] (38, 6) NULL,
[Day25_FR] [numeric] (38, 6) NULL,
[Day26_FR] [numeric] (38, 6) NULL,
[Day27_FR] [numeric] (38, 6) NULL,
[Day28_FR] [numeric] (38, 6) NULL,
[Day29_FR] [numeric] (38, 6) NULL,
[Day30_FR] [numeric] (38, 6) NULL,
[Day1_FinishedLectures] [int] NULL,
[Day2_FinishedLectures] [int] NULL,
[Day3_FinishedLectures] [int] NULL,
[Day4_FinishedLectures] [int] NULL,
[Day5_FinishedLectures] [int] NULL,
[Day6_FinishedLectures] [int] NULL,
[Day7_FinishedLectures] [int] NULL,
[Day8_FinishedLectures] [int] NULL,
[Day9_FinishedLectures] [int] NULL,
[Day10_FinishedLectures] [int] NULL,
[Day11_FinishedLectures] [int] NULL,
[Day12_FinishedLectures] [int] NULL,
[Day13_FinishedLectures] [int] NULL,
[Day14_FinishedLectures] [int] NULL,
[Day15_FinishedLectures] [int] NULL,
[Day16_FinishedLectures] [int] NULL,
[Day17_FinishedLectures] [int] NULL,
[Day18_FinishedLectures] [int] NULL,
[Day19_FinishedLectures] [int] NULL,
[Day20_FinishedLectures] [int] NULL,
[Day21_FinishedLectures] [int] NULL,
[Day22_FinishedLectures] [int] NULL,
[Day23_FinishedLectures] [int] NULL,
[Day24_FinishedLectures] [int] NULL,
[Day25_FinishedLectures] [int] NULL,
[Day26_FinishedLectures] [int] NULL,
[Day27_FinishedLectures] [int] NULL,
[Day28_FinishedLectures] [int] NULL,
[Day29_FinishedLectures] [int] NULL,
[Day30_FinishedLectures] [int] NULL,
[BehindtheScenes_FR] [numeric] (38, 6) NULL,
[BonusFeatures_FR] [numeric] (38, 6) NULL,
[Economics_FR] [numeric] (38, 6) NULL,
[FoodWine_FR] [numeric] (38, 6) NULL,
[Health_FR] [numeric] (38, 6) NULL,
[History_FR] [numeric] (38, 6) NULL,
[Hobby_FR] [numeric] (38, 6) NULL,
[Literature_FR] [numeric] (38, 6) NULL,
[Mathematics_FR] [numeric] (38, 6) NULL,
[Music_FR] [numeric] (38, 6) NULL,
[NatGeo_FR] [numeric] (38, 6) NULL,
[Phil_FR] [numeric] (38, 6) NULL,
[Professional_FR] [numeric] (38, 6) NULL,
[Science_FR] [numeric] (38, 6) NULL,
[Trailers_FR] [numeric] (38, 6) NULL,
[Travel_FR] [numeric] (38, 6) NULL,
[LastStreamedDate_FreeTrialMonth] [date] NULL
) ON [PRIMARY]
GO
