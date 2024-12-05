//
//  AnimatedSearchBar.swift
//  Group19_App
//
//  Created by Ayush Patel on 12/2/24.
//

import SwiftUI

struct AnimatedSearchBar: View {
    @Binding var searchtext: String
    @State var iconoffset = false
    @State var state = false
    @State var progress: CGFloat = 1.0
    @State var showTextFi = false

    var body: some View {
        ZStack (alignment: .trailing){
            if state {
            ZStack {
                RoundedRectangle(cornerRadius: 10, style: .continuous)
                RoundedRectangle(cornerRadius: 10, style: .continuous)
                    .stroke(lineWidth: 3)
                    .foregroundColor(.white)
                if showTextFi {
                    TextField("Search...", text: $searchtext)
                        .padding(.horizontal)
                        .foregroundColor(.black)
                }
            }
            .frame(width: state ? 400 : 50, height: 50)
            .foregroundStyle(.white)
            
        }
            icon(searchtext: $searchtext, progress: $progress, iconoffset: $iconoffset, state: $state, showTextFi: $showTextFi)

        }
        .padding(.horizontal)
        .frame(maxWidth: .infinity, alignment: .trailing)

        
    }
}

struct icon: View {
    
    @Binding var searchtext: String
    @Binding var progress: CGFloat
    @Binding var iconoffset: Bool
    @Binding var state: Bool
    @Binding var showTextFi: Bool
    
    var body: some View {
        Button {
            if showTextFi {
                showTextFi = false
                searchtext = ""
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                withAnimation {
                    if !showTextFi && state {
                        showTextFi = true
                    }
                }
            }
            withAnimation {
                state.toggle()
            }
            if progress == 1.0 {
                withAnimation(.linear(duration: 0.5)) {
                    progress = 0.0

                }
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                    withAnimation {
                        iconoffset.toggle()
                    }
                }
            } else {
                withAnimation {
                    iconoffset.toggle()
                }
               
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                    withAnimation(.linear(duration: 0.5)) {
                        progress = 1.0

                    }
                }
            }
        }
        label: {
            VStack (spacing: 0){
                Circle()
                    .trim(from: 0.0, to: progress)
                    .stroke(lineWidth: 3)
                    .rotationEffect(.degrees(88))
                    .frame(width: 15, height: 15)
                    .padding()
                RoundedRectangle(cornerRadius: 5)
                    .frame(width: 3, height: iconoffset ? 20 : 15)
                    .offset(y: -17)
                    .overlay {
                        RoundedRectangle(cornerRadius: 5)
                            .frame(width: 3, height: iconoffset ? 20 : 15)
                            .rotationEffect(.degrees(iconoffset ? 80 : 0), anchor: .center)
                            .offset(y: -17)
                        
                    }

               
            }
        }
        .offset(x: iconoffset ? -5 : -3, y: iconoffset ? -5 : 2)
        .rotationEffect(.degrees(-40))
        .foregroundColor(.black)
        .frame(width: 40, height: 40)
    }
}

#Preview {
    AnimatedSearchBar(searchtext: .constant(""))
}
