//
// Copyright (c) Vatsal Manot
//

import Merge
import Foundation
import SwiftUIX

#if os(iOS) || os(tvOS) || targetEnvironment(macCatalyst)

open class UIViewControllerCoordinator<Route: ViewRoute>: BaseViewCoordinator<Route> {
    public var rootViewController: UIViewController
    
    public init(rootViewController: UIViewController) {
        self.rootViewController = rootViewController
    }
    
    public convenience init<Route: ViewRoute>(parent: UIViewControllerCoordinator<Route>) {
        self.init(rootViewController: parent.rootViewController)
        
        parent.addChild(self)
    }

    public override func triggerPublisher(for route: Route) -> AnyPublisher<ViewTransitionContext, ViewRouterError> {
        transition(for: route)
            .mergeEnvironmentBuilder(environmentBuilder)
            .triggerPublisher(in: rootViewController, animated: true, coordinator: self)
    }
}

open class UIWindowCoordinator<Route: ViewRoute>: BaseViewCoordinator<Route> {
    public var window: UIWindow
    
    public init(window: UIWindow) {
        self.window = window
    }
    
    public convenience init<Route: ViewRoute>(parent: UIWindowCoordinator<Route>) {
        self.init(window: parent.window)
        
        parent.addChild(self)
    }
    
    @discardableResult
    public override func triggerPublisher(for route: Route) -> AnyPublisher<ViewTransitionContext, ViewRouterError> {
        return transition(for: route)
            .mergeEnvironmentBuilder(environmentBuilder)
            .triggerPublisher(in: window, coordinator: self)
            .handleSubscription({ _ in self.window.makeKeyAndVisible() })
            .eraseToAnyPublisher()
    }
}

#endif
