//
//  ViewWrapper.swift
//  longfolio
//
//  Created by Илья Бочков on 2.04.26.
//

import SwiftUI

struct ViewWrapper<C: View>: View {
    private let content: () -> C
    
    init(@ViewBuilder content: @escaping () -> C) {
        self.content = content
    }
    
    var body: some View {
        content()
    }
}
