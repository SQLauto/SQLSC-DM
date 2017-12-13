CREATE TABLE [Archive].[Omni_MarketingCloudID_ReportDaily]
(
[Omni_MarketingCloudID_Report_id] [bigint] NOT NULL IDENTITY(1, 1),
[MarketingCloudVisitorID] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[AllVisits] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Date] [datetime] NULL,
[MobileDeviceType] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Carts] [int] NULL,
[CartViews] [int] NULL,
[Checkouts] [int] NULL,
[CartAdditions] [int] NULL,
[InternalSearchPerformed] [int] NULL,
[CartRemovals] [int] NULL,
[InternalSearchNullResult] [int] NULL,
[AccountLogin] [int] NULL,
[PrioritCodeSubmits] [int] NULL,
[FacetClicks] [int] NULL,
[AddtoWishlist] [int] NULL,
[CheckoutLogins] [int] NULL,
[BillingContinues] [int] NULL,
[ShippingAddrContinues] [int] NULL,
[ShippingMethodContinues] [int] NULL,
[PlaceOrderSubmits] [int] NULL,
[egiftaddtocart] [int] NULL,
[egiftopencart] [int] NULL,
[egiftcheckout] [int] NULL,
[egiftpurchase] [int] NULL,
[egiftredeemview] [int] NULL,
[egiftredeem] [int] NULL,
[SocialShareSubmits] [int] NULL,
[PDPGalleryClick] [int] NULL,
[PDPWhatWIllYouLearn] [int] NULL,
[PDPWhatsIncludedClick] [int] NULL,
[OnSaleProductView] [int] NULL,
[UpsellRightArrowClick] [int] NULL,
[UpsellLeftArrowClicke] [int] NULL,
[UniqueVisitors] [int] NULL,
[PageViews] [int] NULL,
[bannerrotation] [int] NULL,
[HomepageHero] [int] NULL,
[ProfessorPageViewVisits] [int] NULL,
[ProfessorPageViewPageViews] [int] NULL,
[RightRail] [int] NULL,
[TrailerVideoViews] [int] NULL,
[UpsellInteractions] [int] NULL,
[DMLastupdated] [datetime] NULL CONSTRAINT [DF__Omni_Mark__DMLas__201B30A5] DEFAULT (getdate())
) ON [PRIMARY]
GO
ALTER TABLE [Archive].[Omni_MarketingCloudID_ReportDaily] ADD CONSTRAINT [PK__Omni_Mar__EB8D2ECC9F4D2D37] PRIMARY KEY CLUSTERED  ([Omni_MarketingCloudID_Report_id]) ON [PRIMARY]
GO
