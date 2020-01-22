//
// Copyright (c) Vatsal Manot
//

import Merge
import SwiftUIX

extension ViewReactor {
    public var cancellables: Cancellables {
        environment.object.cancellables
    }
    
    public var injectedReactors: ViewReactors {
        environment.injectedReactors
    }
}

extension ViewReactor where Self: DynamicViewPresenter {
    public var isPresented: Bool {
        environment.dynamicViewPresenter?.isPresented ?? false
    }
    
    /// Present a view.
    public func present<V: View>(
        _ view: V,
        onDismiss: (() -> Void)? = nil,
        style: ModalViewPresentationStyle = .automatic,
        completion: (() -> Void)? = nil
    ) {
        environment.dynamicViewPresenter?.present(
            view.attach(self),
            onDismiss: onDismiss,
            style: style,
            completion: completion
        )
    }
    
    /// Dismiss the view owned by `self`.
    public func dismiss(completion: (() -> Void)?) {
        environment.dynamicViewPresenter?.dismiss(completion: completion)
    }
    
    /// Dismiss the view owned by `self`.
    public func dismiss() {
        environment.dynamicViewPresenter?.dismiss()
    }
    
    /// Dismiss the view with the given name.
    public func dismiss(viewNamed name: Subview) {
        environment.dynamicViewPresenter?.dismiss(viewNamed: name)
    }
}

extension ViewReactor {
    public func status(of action: Action) -> OpaqueTask.StatusDescription? {
        environment.taskPipeline[.init(action)]?.statusDescription
    }
}
