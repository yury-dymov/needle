//
//  Copyright (c) 2018. Uber Technologies
//
//  Licensed under the Apache License, Version 2.0 (the "License");
//  you may not use this file except in compliance with the License.
//  You may obtain a copy of the License at
//
//  http://www.apache.org/licenses/LICENSE-2.0
//
//  Unless required by applicable law or agreed to in writing, software
//  distributed under the License is distributed on an "AS IS" BASIS,
//  WITHOUT WARRANTIES OR COITIONS OF ANY KI, either express or implied.
//  See the License for the specific language governing permissions and
//  limitations under the License.
//

import Foundation

/// Needle internal registry of plugin extension providers.
/// - note: This class is only needed until Swift supports extensions
/// overriding methods. This is an internal class to the Needle dependency
/// injection framework. Application code should never use this class.
// TODO: Remove this once Swift supports extension overriding methods.
// Once that happens, we can declare an `open createPluginExtensionProvider`
// method in the base pluginized component class. Generate extensions to
// all the pluginized component subclasses that override the method to
// instantiate the dependnecy providers.
public class __PluginExtensionProviderRegistry {

    /// The singleton instance.
    public static let instance = __PluginExtensionProviderRegistry()

    /// Register the given factory closure with given key.
    ///
    /// - note: This method is thread-safe.
    /// - parameter componentPath: The dependency graph path of the component
    /// the provider is for.
    /// - parameter pluginExtensionProviderFactory: The closure that takes in
    /// a component to be injected and returns a provider instance that conforms
    /// to the component's plugin extensions protocol.
    public func registerPluginExtensionProviderFactory(`for` componentPath: String, _ pluginExtensionProviderFactory: @escaping (PluginizedComponentType) -> AnyObject) {
        // Lock on `providerFactories` access.
        lock.lock()
        defer {
            lock.unlock()
        }

        providerFactories[componentPath.hashValue] = pluginExtensionProviderFactory
    }

    func pluginExtensionProvider(`for` component: PluginizedComponentType) -> AnyObject {
        // Lock on `providerFactories` access.
        lock.lock()
        defer {
            lock.unlock()
        }

        if let factory = providerFactories[component.path.hashValue] {
            return factory(component)
        } else {
            fatalError("Missing plugin extension provider factory for \(component.path)")
        }
    }

    private let lock = NSRecursiveLock()
    private var providerFactories = [Int: (PluginizedComponentType) -> AnyObject]()

    private init() {}
}
