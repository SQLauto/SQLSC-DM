CREATE TABLE [Staging].[Omni_ssis_MarketingCloudID_Report]
(
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
[PageViews] [int] NULL
) ON [PRIMARY]
GO
