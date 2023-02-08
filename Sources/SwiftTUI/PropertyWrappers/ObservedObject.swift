import Combine

@propertyWrapper
public struct ObservedObject<ObjectType>: AnyObservedObject where ObjectType: ObservableObject {
    
    var objectReference = ObservedObjectReference()
    private var object: ObjectType
    
    public init(wrappedValue: ObjectType) {
        self.object = wrappedValue
        setUpObserving(for: wrappedValue)
    }

    public var wrappedValue: ObjectType {
        get {
            guard let node = objectReference.node,
                  let label = objectReference.label
            else {
                assertionFailure("Attempting to access @ObservedObject variable before view is instantiated")
                return object
            }
            if let value = node.state[label] {
                return value as! ObjectType
            }
            return object
        }
        nonmutating set {
            guard let node = objectReference.node,
                  let label = objectReference.label
            else {
                assertionFailure("Attempting to modify @ObservedObject variable before view body was calculated")
                return
            }
            node.observables[label] = newValue
            node.root.application?.invalidateNode(node)
            setUpObserving(for: newValue)
        }
    }
    
    private func setUpObserving(for object: ObjectType) {
        objectReference.cancellable?.cancel()
        objectReference.cancellable = object.objectWillChange.sink(
            receiveValue: { output in
                if let node = objectReference.node {
                    node.root.application?.invalidateNode(node)
                }
            }
        )
    }
}


protocol AnyObservedObject {
    var objectReference: ObservedObjectReference { get }
}

class ObservedObjectReference {
    weak var node: Node?
    var label: String?
    var cancellable: AnyCancellable?
    
    deinit {
        
    }
}
