import Foundation

extension Bundle {
    var commitId: String? {
        guard let gitCommit = self.infoDictionary?["GIT_COMMIT"] as? String else {
                return nil
        }
        
        return "\(gitCommit) (\(gitStatus))"
    }
    
    var shortCommitId: String? {
        return commitId.map {
            return String($0.prefix(8))
        }
    }
    
    var gitStatus: GitStatus {
        return (self.infoDictionary?["GIT_STATUS"] as? String)
               .flatMap { GitStatus(rawValue: $0) }
               ?? .unknown
    }

    var buddybuildBuildNumber: Int? {
        return self.infoDictionary?["BUDDYBUILD_BUILD_NUMBER"] as? Int
    }
}

public enum GitStatus: String {
    case clean
    case dirty
    case unknown
}
