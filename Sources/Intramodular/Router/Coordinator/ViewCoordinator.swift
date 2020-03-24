//
// Copyright (c) Vatsal Manot
//

import Merge
import Foundation
import SwiftUIX

public protocol ViewCoordinator: ViewRouter {
    func transition(for: Route) -> ViewTransition
}

// MARK: - Implementation -

open class OpaqueBaseViewCoordinator: DynamicViewPresentable {
    public let cancellables = Cancellables()
    
    open var environmentBuilder = EnvironmentBuilder()
    
    open var name: ViewName? {
        return nil
    }
    
    open fileprivate(set) var presenter: DynamicViewPresenter?
    open fileprivate(set) var children: [DynamicViewPresentable] = []
    
    public init() {
        
    }
    
    func becomeChild(of parent: OpaqueBaseViewCoordinator) {
        
    }
}

open class BaseViewCoordinator<Route: ViewRoute>: OpaqueBaseViewCoordinator, ViewCoordinator {
    public func insertEnvironmentObject<B: ObservableObject>(_ bindable: B) {
        environmentBuilder.insert(bindable)
        
        children.forEach({ $0.insertEnvironmentObject(bindable) })
    }
    
    public func mergeEnvironmentBuilder(_ builder: EnvironmentBuilder) {
        environmentBuilder.merge(builder)
        
        children.forEach({ $0.mergeEnvironmentBuilder(builder) })
    }
    
    open func addChild(_ presentable: DynamicViewPresentable) {
        presentable.insertEnvironmentObject(AnyViewCoordinator(self))
        presentable.mergeEnvironmentBuilder(environmentBuilder)
        
        (presentable as? OpaqueBaseViewCoordinator)?.becomeChild(of: self)
        
        children.append(presentable)
    }
    
    override open func becomeChild(of parent: OpaqueBaseViewCoordinator) {
        presenter = parent as? DynamicViewPresenter // FIXME!!!
        
        parent.insertEnvironmentObject(AnyViewCoordinator(self))
        
        mergeEnvironmentBuilder(parent.environmentBuilder)
        
        children.forEach({ ($0 as? OpaqueBaseViewCoordinator)?.becomeChild(of: self) })
    }
    
    open func transition(for _: Route) -> ViewTransition {
        fatalError()
    }
    
    public func triggerPublisher(for route: Route) -> AnyPublisher<ViewTransitionContext, ViewRouterError> {
        Empty().eraseToAnyPublisher()
    }
    
    @discardableResult
    public func trigger(_ route: Route) -> AnyPublisher<ViewTransitionContext, ViewRouterError> {
        let publisher = triggerPublisher(for: route)
        let result = PassthroughSubject<ViewTransitionContext, ViewRouterError>()
        
        publisher.subscribe(result, storeIn: cancellables)
        
        return result.eraseToAnyPublisher()
    }
    
    public func parent<R, C: BaseViewCoordinator<R>>(ofType type: C.Type) -> C? {
        presenter as? C
    }
}

// MARK: - Auxiliary Implementation -

@propertyWrapper
public struct ReactorRouter<C: ViewCoordinator>: DynamicProperty {
    @Environment(\.viewReactors) var environmentReactors
    @EnvironmentObject public var _wrappedValue: AnyViewCoordinator<C.Route>
    
    public var wrappedValue: C {
        _wrappedValue.environmentBuilder.transformEnvironment {
            $0.viewReactors.insert(self.environmentReactors)
        }
        
        return _wrappedValue.base as! C
    }
    
    public init() {
        
    }
}

// MARK: - Helpers -

extension ActionLabelView {
    public init<Coordinator: ViewCoordinator>(
        trigger route: Coordinator.Route,
        in coordinator: Coordinator,
        @ViewBuilder label: () -> Label
    ) {
        self.init(action: { coordinator.trigger(route) }, label: label)
    }
}
