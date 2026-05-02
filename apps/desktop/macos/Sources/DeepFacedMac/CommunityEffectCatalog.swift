import Foundation

struct CommunityCreatorRecord: Codable, Hashable {
    let id: String
    let handle: String
    let displayName: String
    let verified: Bool
}

struct CommunityEffectRecord: Codable, Hashable, Identifiable {
    let id: String
    let slug: String
    let name: String
    let creator: CommunityCreatorRecord
    let kind: String
    let description: String
    let assetURL: URL
    let thumbnailURL: URL?
    let featureFlags: [String]
    let packageSizeMb: Double
    let deepARStudioVersion: String
}

struct CommunityCatalogResponse: Codable {
    let effects: [CommunityEffectRecord]
}

enum CommunityEffectCatalogError: LocalizedError {
    case missingCatalogURL
    case invalidResponse

    var errorDescription: String? {
        switch self {
        case .missingCatalogURL:
            "No community catalog URL is configured."
        case .invalidResponse:
            "The community catalog returned an invalid response."
        }
    }
}

struct CommunityEffectCatalogClient {
    let catalogURL: URL?

    init(catalogURL: URL? = CommunityEffectCatalogClient.defaultCatalogURL()) {
        self.catalogURL = catalogURL
    }

    func fetchPublishedEffects() async throws -> [CommunityEffectRecord] {
        guard let catalogURL else {
            throw CommunityEffectCatalogError.missingCatalogURL
        }

        let (data, response) = try await URLSession.shared.data(from: catalogURL)
        guard (response as? HTTPURLResponse)?.statusCode == 200 else {
            throw CommunityEffectCatalogError.invalidResponse
        }

        return try JSONDecoder.deepFaced.decode(CommunityCatalogResponse.self, from: data).effects
    }

    private static func defaultCatalogURL() -> URL? {
        guard
            let rawValue = Bundle.main.object(forInfoDictionaryKey: "CommunityCatalogURL") as? String,
            !rawValue.isEmpty
        else {
            return nil
        }

        return URL(string: rawValue)
    }
}

struct CommunityEffectCache {
    let rootDirectory: URL

    init(fileManager: FileManager = .default) {
        let applicationSupport = fileManager.urls(for: .applicationSupportDirectory, in: .userDomainMask).first
        rootDirectory = (applicationSupport ?? fileManager.temporaryDirectory)
            .appending(path: "Deep Faced")
            .appending(path: "Effects")
    }

    func localPackageURL(for effect: CommunityEffectRecord) -> URL {
        rootDirectory
            .appending(path: effect.slug)
            .appending(path: "\(effect.slug).deepar")
    }
}

private extension JSONDecoder {
    static var deepFaced: JSONDecoder {
        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase
        return decoder
    }
}
