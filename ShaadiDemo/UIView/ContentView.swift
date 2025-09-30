//
//  ContentView.swift
//  ShaadiDemo
//
//  Created by Abhishek Garg on 9/26/25.
//

import SwiftUI
import CoreData

struct ContentView: View {
    @StateObject private var vm = ProfilesViewModel()
    @State private var showAlert = false
    
    var body: some View {
        NavigationStack {
            ZStack {
                // Background Gradient
                AppColors.backgroundGradient
                    .ignoresSafeArea()
                
                ScrollView {
                    LazyVStack(spacing: AppSpacing.xl) {
                        // Offline banner at the top of scroll content
                        if !vm.isOnline { 
                            offlineBanner
                                .padding(.horizontal, AppSpacing.lg)
                        }
                        
                        ForEach(vm.profiles, id: \.objectID) { profile in
                            ProfileCardView(
                                profile: profile,
                                onAccept: { 
                                    withAnimation(AppAnimations.springSlow) {
                                        vm.accept(id: profile.id ?? "")
                                    }
                                },
                                onDecline: { 
                                    withAnimation(AppAnimations.springSlow) {
                                        vm.decline(id: profile.id ?? "")
                                    }
                                }
                            )
                            .padding(.horizontal, AppSpacing.lg)
                        }
                    }
                    .padding(.top, AppSpacing.sm)
                    .padding(.bottom, AppSpacing.xl)
                }
            }
            .navigationTitle("Shaadi.com")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: {
                        vm.refresh()
                    }) {
                        Image(systemName: "arrow.clockwise")
                            .font(AppTypography.callout)
                            .foregroundStyle(AppColors.textPrimary)
                    }
                }
            }
        }
        .onReceive(vm.$errorMessage) { msg in showAlert = (msg != nil) }
        .alert("Oops", isPresented: $showAlert, actions: {
            Button("OK", role: .cancel) { vm.errorMessage = nil }
        }, message: { Text(vm.errorMessage ?? "") })
    }
    
    private var offlineBanner: some View {
        HStack(spacing: AppSpacing.md) {
            Image(systemName: "wifi.slash")
                .font(AppTypography.callout)
                .foregroundStyle(AppColors.accent)
            
            Text("You're offline — showing saved profiles")
                .font(AppTypography.footnote)
                .foregroundStyle(AppColors.textPrimary)
            
            Spacer()
        }
        .padding(.horizontal, AppSpacing.lg)
        .padding(.vertical, AppSpacing.md)
        .background(
            RoundedRectangle(cornerRadius: AppCornerRadius.md)
                .fill(AppColors.accent.opacity(0.1))
                .overlay(
                    RoundedRectangle(cornerRadius: AppCornerRadius.md)
                        .stroke(AppColors.accent.opacity(0.3), lineWidth: 1)
                )
        )
    }
}
