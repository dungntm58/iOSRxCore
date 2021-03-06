//
//  ListViewSourceModel.swift
//  RxCoreList
//
//  Created by Robert Nguyen on 1/13/19.
//  Copyright © 2019 Robert Nguyen. All rights reserved.
//

import DifferenceKit
import RxCocoa
import RxSwift
import RxRelay

extension Int: Differentiable {}
extension ContentIdentifiable where Self: ContentEquatable {
    public func toAnyDifferentiable() -> AnyDifferentiable { .init(self) }
}

public typealias DataSection = ArraySection<Int, AnyDifferentiable>

open class BaseListViewSource: NSObject, ListViewSource {
    private var listModels: [String: [ViewModelItem]]

    final var originalDifferenceSections: [DataSection]
    final var differenceSections: [DataSection]
    final var lastChangeType: ListModelChangeType

    fileprivate(set) open var isAnimating: Bool

    final public var templateSections: [SectionModel]
    final public lazy var templateCells: [CellModel] = { produceCells() }()

    open var shouldAnimateLoading: Bool

    /// Calling this intialization will cause app crashes
    public init(sections: [SectionModel], shouldAnimateLoading: Bool = true) {
        self.templateSections = sections
        self.lastChangeType = .initial
        self.isAnimating = false
        self.shouldAnimateLoading = shouldAnimateLoading
        self.originalDifferenceSections = []
        self.differenceSections = []
        self.listModels = [:]
        // Set up first differenceSections
        for (index, section) in sections.enumerated() {
            section.tag = index
        }
        super.init()
    }

    /// Return a list of model items based on identifier
    final public func models(forIdentifier identifier: String) -> [ViewModelItem]? { listModels[identifier] }

    /// Return a cell model in the section, at a specific row
    open func cell(inSection section: SectionModel, row: Int, onChanged type: ListModelChangeType) -> CellModel { section.cells[0] }

    /// Return a section model
    open func section(atSection section: Int, onChanged type: ListModelChangeType) -> SectionModel {
        templateSections[section]
    }

    /// Return a list of differentiable items
    open func computeDifferentiableObjects(forSection section: Int, onChanged type: ListModelChangeType) -> [AnyDifferentiable] {
        models(forIdentifier: ListViewSourceModel.defaultIdentifier)?.map { $0.toAnyDifferentiable() } ?? []
    }

    open func numberOfDataSections(onChanged type: ListModelChangeType) -> Int { templateSections.count }

    func computedDataSectionsIfAnimating() -> [DataSection] {
        preconditionFailure()
    }

    func componentReloadData() {
        preconditionFailure()
    }
}

private extension BaseListViewSource {
    func produceCells() -> [CellModel] {
        #if swift(>=5.2)
        let allCells = templateSections.flatMap(\.cells)
        let uniqueCells = Dictionary(grouping: allCells, by: \.reuseIdentifier)
            .map(\.value)
            .compactMap(\.first)
        #else
        let allCells = templateSections.flatMap { $0.cells }
        let uniqueCells = Dictionary(grouping: allCells, by: { $0.reuseIdentifier })
            .map { $0.value }
            .compactMap { $0.first }
        #endif

        #if !RELEASE && !PRODUCTION
        if allCells.count != uniqueCells.count {
            Swift.print("More than two different cells have the same reuse identifier, the first found one has been selected")
        }
        #endif
        return uniqueCells
    }

    func updateModel(_ model: ListViewSourceModel) {
        self.lastChangeType = model.type

        let identifier = model.identifier
        guard var models = listModels[identifier] else {
            return listModels[identifier] = model.data
        }
        switch model.type {
        case .initial, .swap:
            models = model.data
        case .addNew(let position):
            switch position {
            case .begin:
                models.insert(contentsOf: model.data, at: 0)
            case .end:
                models.append(contentsOf: model.data)
            case .middle(let start, _):
                models.insert(contentsOf: model.data, at: start)
            }
        case .remove(let position):
            switch position {
            case .begin:
                models.removeFirst()
            case .end:
                models.removeLast()
            case .middle(let start, let length):
                guard length > 0 else { return }
                let end = min(start + length - 1, models.count - 1)
                models.removeSubrange(start...end)
            }
        case .replace(let start, let length):
            guard length > 0 else { return }
            let end = start + length - 1
            models.replaceSubrange(start...end, with: model.data)
        }
        listModels[identifier] = models
    }
}

extension Reactive where Base: BaseListViewSource {
    public var isAnimating: Binder<Bool> {
        Binder(base) {
            target, isAnimating in
            target.isAnimating = isAnimating
            target.componentReloadData()
        }
    }

    public var model: Binder<ListViewSourceModel> {
        Binder(base, scheduler: CurrentThreadScheduler.instance) {
            target, change in
            target.updateModel(change)
            guard change.needsReload else { return }
            let changeType = change.type
            let numberOfSections = target.numberOfDataSections(onChanged: changeType)
            let originalDifferenceSections = (0..<numberOfSections).map { DataSection(model: $0, elements: target.computeDifferentiableObjects(forSection: $0, onChanged: changeType)) }
            DispatchQueue.main.async {
                target.originalDifferenceSections = originalDifferenceSections
                target.componentReloadData()
            }
        }
    }
}
