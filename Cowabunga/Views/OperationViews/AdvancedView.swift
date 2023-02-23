//
//  AdvancedView.swift
//  Cowabunga
//
//  Created by lemin on 2/7/23.
//

import SwiftUI
import UniformTypeIdentifiers

struct AdvancedView: View {
    @State private var operations: [AdvancedCategory] = []
    @State private var isImporting: Bool = false
    
    // lazyvgrid
    
    var body: some View {
        VStack {
            List(operations, children: \.operations) { operation in
                if operation.categoryName != nil {
                    // it is an operation
                    NavigationLink(destination: EditingOperationView(category: operation.categoryName!, editing: true, operation: try! AdvancedManager.getOperationFromName(operationName: operation.name))) {
                        HStack {
                            if !operation.isActive {
                                Image(systemName: "xmark.seal.fill")
                                    .foregroundColor(.red)
                            }
                            VStack (alignment: .leading) {
                                Text(operation.name.replacingOccurrences(of: "_", with: " "))
                                if operation.author != "" {
                                    Text("by: " + operation.author)
                                        .font(.caption)
                                }
                            }
                            .padding(.horizontal, 8)
                        }
                    }
                } else {
                    // it is a category
                    HStack {
                        Text("Uncategorized")//operation.name.replacingOccurrences(of: "_", with: " "))
                            .padding(.horizontal, 8)
                    }
                }
            }
            .onAppear {
                updateCategories()
            }
            .toolbar {
                HStack {
                    // import an operation
                    Button(action: {
                        isImporting.toggle()
                    }) {
                        Image(systemName: "square.and.arrow.down")
                    }
                    .foregroundColor(.blue)
                    
                    // create a new operation
                    NavigationLink(destination: EditingOperationView(category: "None", editing: false, operation: CorruptingObject(operationName: AdvancedManager.getAvailableName("New_Operation").replacingOccurrences(of: "_", with: " "), filePath: "/var", applyInBackground: false))) {
                        Image(systemName: "plus")
                    }
                }
            }
            .sheet(isPresented: $isImporting) {
                DocumentPicker(
                    types: [
                        UTType(filenameExtension: "cowperation") ?? .zip
                    ]
                ) { result in
                    if result.first == nil { UIApplication.shared.alert(body: NSLocalizedString("Couldn't get url of file. Did you select it?", comment: "")); return }
                    let url: URL = result.first!
                    do {
                        // try adding the operation
                        try AdvancedManager.importOperation(url)
                        operations.removeAll()
                        operations = try AdvancedManager.loadOperations()
                        UIApplication.shared.alert(title: NSLocalizedString("Success!", comment: ""), body: NSLocalizedString("The operation was successfully imported.", comment: "when importing a custom operation"))
                    } catch { UIApplication.shared.alert(body: error.localizedDescription) }
                }
            }
            .navigationTitle("Custom Operations")
        }
    }
    
    func updateCategories() {
        // load the operation categories
        do {
            operations = try AdvancedManager.loadOperations()
        } catch {
            UIApplication.shared.alert(title: NSLocalizedString("Failed to load operations.", comment: ""), body: error.localizedDescription)
        }
    }
}

struct AdvancedView_Previews: PreviewProvider {
    static var previews: some View {
        AdvancedView()
    }
}
