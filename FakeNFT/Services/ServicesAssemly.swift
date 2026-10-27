final class ServicesAssembly {

    private let networkClient: NetworkClient
    private let nftStorage: NftStorage
    private var useMock = false

    init(
        networkClient: NetworkClient,
        nftStorage: NftStorage
    ) {
        self.networkClient = networkClient
        self.nftStorage = nftStorage
    }

    var nftService: NftService {
        useMock ?
            NftServiceMockImpl()
        :
            NftServiceImpl(
                networkClient: networkClient,
                storage: nftStorage
            )
    }

    var orderService: OrderService {
        useMock ?
            OrderServiceMockImpl(result: .success(
                Order(
                    id: "df432926-0dda-43f6-8da9-bae96de34cf9",
                    nfts: [
                        "c14cf3bc-7470-4eec-8a42-5eaa65f4053c",
                        "d6a02bd1-1255-46cd-815b-656174c1d9c0",
                        "d30d016c-92a9-48c2-8086-d376d5cbe257",
                        "f991a551-3046-4bd6-9ab8-b4f8d6561df7"
                    ]
                )
            ))
        :
            OrderServiceImpl(networkClient: networkClient)
    }

    var cartStorage: CartStorage {
        CartStorage()
    }

    var currencyService: CurrencyService {
        useMock ?
            CurrencyServiceMockImpl(result: .success(
                Currency.mockList
            ))
        :
            CurrencyServiceImpl(networkClient: networkClient)
    }

    var paymentService: PaymentService {
        PaymentServiceImpl(networkClient: networkClient)
    }
}
