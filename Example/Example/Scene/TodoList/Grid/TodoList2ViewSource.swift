//
//  Todo2ViewSource.swift
//  Core-CleanSwift-Example
//
//  Created by Robert Nguyen on 1/23/19.
//  Copyright © 2019 Robert Nguyễn. All rights reserved.
//

import UIKit
import RxCoreBase
import RxCoreList
import RxCoreRequest
import DifferenceKit

class TodoList2ViewSource: BaseCollectionViewSource, UICollectionViewDelegateFlowLayout {
    weak var store: TodoStore?
    
    init(store: TodoStore?) {
        self.store = store
        let cell = DefaultCellModel(type: .nib(nibName: "TodoCollectionViewCell", bundle: nil))
        let sectionModels: [DefaultSectionModel] = [
            .init(cells: [ cell ])
        ]
        super.init(sections: sectionModels, shouldAnimateLoading: true)
        
        store?.state
            .filter { $0.error == nil && !$0.isLogout }
            .map { $0.list }
            .distinctUntilChanged()
            .map {
                response in
                if response.currentPage == 0 {
                    return ListViewSourceModel(type: .initial, data: response.data, needsReload: true)
                } else {
                    return ListViewSourceModel(type: .addNew(at: .end(length: response.data.count)), data: response.data, needsReload: true)
                }
            }
            .bind(to: modelRelay)
            .disposed(by: disposeBag)
    }
    
    override func bind(value: ViewModelItem, to cell: UICollectionViewCell, at indexPath: IndexPath) {
        let item = value as! TodoEntity
        let dataCell = cell as! TodoCollectionViewCell
        
        dataCell.lbTime.text = item.createdAt.toISO()
        dataCell.lbTitle.text = item.title
    }
    
    override func objects(in section: SectionModel, at index: Int, onChanged type: ListModelChangeType) -> [AnyDifferentiable] {
        if let models = models(forIdentifier: "default") {
            return models.map { $0.toAnyDifferentiable() }
        }
        
        return super.objects(in: section, at: index, onChanged: type)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: collectionView.frame.width, height: 60)
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        store?.dispatch(type: .selectTodo, payload: indexPath.row)
    }
    
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        guard let cell = cell as? LoadingAnimatable else {
            return
        }
        cell.startAnimation()
        
        let currentPage = store?.currentState.list.currentPage ?? 0
        store?.dispatch(type: .load, payload: Payload.List.Request(page: currentPage + 1, cancelRunning: false))
    }
}
