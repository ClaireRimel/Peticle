//
//  AppDependencyManager.swift
//  Peticle
//
//  Created by Claire on 31/08/2025.
//

import Foundation

/// Thread-safe dependency manager for the application
final class AppDependencyManager {
    static let shared = AppDependencyManager()
    
    private let queue = DispatchQueue(label: "com.peticle.dependency-manager", attributes: .concurrent)
    private var dependencies: [String: Any] = [:]
    
    private init() {}
    
    /// Add a dependency with type safety
    /// - Parameter dependency: The dependency to store
    func add<T>(dependency: T) {
        let key = String(describing: T.self)
        queue.async(flags: .barrier) {
            self.dependencies[key] = dependency
        }
    }
    
    /// Retrieve a dependency with type safety
    /// - Returns: The stored dependency or nil if not found
    func get<T>() -> T? {
        let key = String(describing: T.self)
        return queue.sync {
            return dependencies[key] as? T
        }
    }
    
    /// Remove a dependency
    /// - Parameter dependency: The dependency type to remove
    func remove<T>(_ dependency: T.Type) {
        let key = String(describing: T.self)
        queue.async(flags: .barrier) {
            self.dependencies.removeValue(forKey: key)
        }
    }
    
    /// Clear all dependencies
    func clearAll() {
        queue.async(flags: .barrier) {
            self.dependencies.removeAll()
        }
    }
}
