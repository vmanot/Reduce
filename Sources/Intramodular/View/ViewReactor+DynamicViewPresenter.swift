//
// Copyright (c) Vatsal Manot
//

import Merge
import SwiftUIX
import Task

extension ViewReactor where Self: DynamicViewPresenter {
    @inlinable
    public var presenter: DynamicViewPresenter? {
        environment.environment.presenter?.presenter
    }
    
    @inlinable
    public var presented: DynamicViewPresentable? {
        environment.environment.presenter?.presented
    }
    
    @inlinable
    public var presentationName: ViewName? {
        environment.environment.presenter?.presentationName
    }
    
    /// Present a view.
    @inlinable
    public func present(_ item: AnyModalPresentation) {
        guard let presenter = environment.environment.presenter else {
            return assertionFailure()
        }
        
        presenter.present(item.mergeEnvironmentBuilder((router as? EnvironmentProvider)?.environmentBuilder ?? .init()))
    }
    
    /// Dismiss the view owned by `self`.
    @inlinable
    public func dismiss(animated: Bool, completion: (() -> Void)?) {
        guard let presenter = environment.environment.presenter else {
            return assertionFailure()
        }
        
        presenter.dismiss(animated: animated, completion: completion)
    }
    
    /// Dismisses a given subview.
    @inlinable
    public func dismiss(_ subview: Subview) {
        guard let presenter = environment.environment.presenter else {
            return assertionFailure()
        }
        
        presenter.dismissView(named: subview)
    }
}

extension ReactorActionTask where R: ViewReactor {
    @inlinable
    public static func present<V: View>(_ view: V) -> Self {
        .action({ $0.withReactor({ $0.present(view) }) })
    }
    
    @inlinable
    public static func dismiss() -> Self {
        .action({ $0.withReactor({ $0.dismiss() }) })
    }
}
