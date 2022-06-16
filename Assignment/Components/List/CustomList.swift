//
//  CustomList.swift
//  Assignment
//
//  Created by Tuan on 14/06/2022.
//

import Foundation
import SwiftUI
import SwiftUIRefresh

public struct CustomList<Data, Content, Header>: View
where Data: RandomAccessCollection, Data.Element: Hashable, Content: View, Header: View {
    @Binding var data: Data // Data
    @Binding var isLoadMore: Bool // Is load more or not
    var onLoadMore: () -> Void? // On load more func
    var onRefresh: OnRefresh? // On refresh
    var header: () -> Header? // Header
    let content: (Data.Element) -> Content // Content item
    var isHorizontal = false // Is horizontal
    @State private var contentSize: CGSize = .zero // Content size
    var maxHeight: CGFloat? // Max height custom list
    @Binding var isShowNoData: Bool // Is show empty
    
    public init(data: Binding<Data>,
                isHorizontal: Bool = false,
                isLoadMore: Binding<Bool> = .constant(false),
                isShowNoData: Binding<Bool> = .constant(false),
                onLoadMore: @escaping () -> Void? = {nil},
                onRefresh: OnRefresh? = nil,
                maxHeight: CGFloat = .infinity,
                @ViewBuilder header: @escaping () -> Header? = { nil },
                @ViewBuilder content: @escaping (Data.Element) -> Content) {
        self._data = data
        self._isLoadMore = isLoadMore
        self._isShowNoData = isShowNoData
        self.onLoadMore = onLoadMore
        self.onRefresh = onRefresh
        self.content = content
        self.header = header
        self.isHorizontal = isHorizontal
        self.maxHeight = maxHeight
    }
    
    public var body: some View {
        if onRefresh != nil {
            RefreshableScrollView(showsIndicators: false, onRefresh: onRefresh!) {
                scrollableContent
            }
        } else {
            if (!isHorizontal) {
                ScrollView {
                    scrollableContent
                        .background(
                            GeometryReader { geo -> Color in
                                DispatchQueue.main.async {
                                    contentSize = geo.size
                                }
                                return Color.clear
                            }
                        )
                }
                .frame(
                    maxHeight: maxHeight != .infinity ? (maxHeight! > contentSize.height ? contentSize.height : maxHeight!) : .infinity
                )
            } else {
                ScrollView(.horizontal) {
                    if #available(iOS 14.0, *) {
                        LazyHStack(spacing: .padding8) {
                            self.header()
                            listItems
                        }
                    } else {
                        HStack(spacing: .padding8) {
                            self.header()
                            listItems
                        }
                    }
                }
            }
        }
    }
    
    /// Render content
    private var scrollableContent: some View {
        Group {
            if #available(iOS 14.0, *) {
                LazyVStack(spacing: .padding8) {
                    self.header()
                    listItems
                }
            } else {
                VStack(spacing: .padding8) {
                    self.header()
                    listItems
                }
            }
        }
    }
    
    /// Render list item
    private var listItems: some View {
        Group {
            if (self.isShowNoData) {
                EmptyViewCustom()
            } else {
                ForEach(data, id: \.self) { item in
                    content(item)
                        .onAppear {
                            if (item == data.last && isLoadMore){
                                onLoadMore()
                            }
                        }
                }
                if isLoadMore {
                    ProgressView()
                        .frame(maxWidth: .infinity, alignment: .center)
                } else {
                    EmptyView()
                }
            }
            
        }
    }
}
