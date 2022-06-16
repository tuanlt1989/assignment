//
//  BaseViewModel.swift
//  Assignment
//
//  Created by Tuan on 15/06/2022.
//

import Foundation
import i18nSwift

class BaseViewModel: ObservableObject {
    @Published var isShowMessage = false // Varabile show message or not
    @Published var message = i18n.t(.processingError) // Message toast
    @Published var isLoading = false // Is loading
    @Published var isLoadMore = false // Is load more
    @Published var isRefresh = false // Is refresh
    var refreshComplete: RefreshComplete? { willSet { self.isRefresh = true }}
    @Published var isShowNoData = false // Is show no data
    
    /// Handle error
    func handleError(error: Error?) {
        
    }
}
