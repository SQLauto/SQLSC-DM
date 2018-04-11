CREATE TABLE [Mapping].[adcode_offercodeid_2018]
(
[AdCode] [int] NULL,
[OfferCodeID] [int] NULL
) ON [PRIMARY]
GO
CREATE UNIQUE CLUSTERED INDEX [ClusteredIndex-20180326-112220] ON [Mapping].[adcode_offercodeid_2018] ([AdCode]) ON [PRIMARY]
GO
