
extension View {
    func setupObservedObjectProperties(node: Node) {
        for (label, value) in Mirror(reflecting: self).children {
            if let observedObjectReference = value as? AnyObservedObject {
                observedObjectReference.objectReference.node = node
                observedObjectReference.objectReference.label = label
            }
        }
    }
}
