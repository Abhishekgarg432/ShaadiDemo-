//
//  ProfileCardView.swift
//  ShaadiDemo
//
//  Created by Abhishek Garg on 9/26/25.
//

import SwiftUI
import CoreData

struct ProfileCardView: View {
    let profile: CDProfile
    let onAccept: () -> Void
    let onDecline: () -> Void
    
    @State private var isPressed = false
    @State private var showImageOverlay = false
    
    var body: some View {
        VStack(spacing: 0) {
            ZStack(alignment: .bottomLeading) {
                AsyncImage(url: URL(string: profile.imageURL ?? "")) { phase in
                    switch phase {
                    case .empty:
                        ZStack {
                            LinearGradient(
                                colors: [AppColors.textTertiary.opacity(0.1), AppColors.textTertiary.opacity(0.3)],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                            ProgressView()
                                .scaleEffect(1.2)
                                .tint(AppColors.primary)
                        }
                    case .success(let image):
                        image
                            .resizable()
                            .scaledToFill()
                            .frame(height: 280)
                            .clipped()
                            .overlay(
                                LinearGradient(
                                    colors: [Color.clear, Color.black.opacity(0.3)],
                                    startPoint: .top,
                                    endPoint: .bottom
                                )
                            )
                    case .failure:
                        ZStack {
                            LinearGradient(
                                colors: [AppColors.textTertiary.opacity(0.1), AppColors.textTertiary.opacity(0.3)],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                            Image(systemName: "person.circle.fill")
                                .font(.system(size: 60))
                                .foregroundStyle(AppColors.textSecondary)
                        }
                    @unknown default:
                        EmptyView()
                    }
                }
                .frame(height: 280)
                .clipped()
                
                // Status Badge Overlay
                if profile.status != DecisionStatus.none.rawValue {
                    VStack {
                        Spacer()
                        HStack {
                            Spacer()
                            statusBadge
                                .padding(.trailing, 16)
                                .padding(.bottom, 16)
                        }
                    }
                }
            }
            
            // Profile Information Section
            VStack(alignment: .leading, spacing: 16) {
                VStack(alignment: .leading, spacing: AppSpacing.sm) {
                    Text(profile.fullName ?? "")
                        .font(AppTypography.profileName)
                        .foregroundStyle(AppColors.textPrimary)
                    
                    HStack(spacing: AppSpacing.sm) {
                        Image(systemName: "calendar")
                            .foregroundStyle(AppColors.textSecondary)
                            .font(AppTypography.caption1)
                        Text("\(profile.age) years old")
                            .font(AppTypography.profileDetails)
                            .foregroundStyle(AppColors.textSecondary)
                        
                        Spacer()
                        
                        Image(systemName: "location")
                            .foregroundStyle(AppColors.textSecondary)
                            .font(AppTypography.caption1)
                        Text(profile.city ?? "")
                            .font(AppTypography.profileDetails)
                            .foregroundStyle(AppColors.textSecondary)
                    }
                }
                
                // Action Buttons
                if profile.status == DecisionStatus.none.rawValue {
                    HStack(spacing: AppSpacing.lg) {
                        // Decline Button
                        Button(action: {
                            withAnimation(AppAnimations.spring) {
                                onDecline()
                            }
                        }) {
                            HStack(spacing: AppSpacing.sm) {
                                Image(systemName: "xmark")
                                    .font(AppTypography.buttonText)
                                Text("Decline")
                                    .font(AppTypography.buttonText)
                            }
                            .foregroundStyle(.white)
                            .frame(maxWidth: .infinity)
                            .frame(height: 50)
                            .background(AppColors.errorGradient)
                            .clipShape(RoundedRectangle(cornerRadius: AppCornerRadius.round))
                            .shadow(color: AppColors.error.opacity(0.3), radius: AppShadows.medium.radius, x: AppShadows.medium.x, y: AppShadows.medium.y)
                        }
                        .primaryButtonStyle(isPressed: isPressed)
                        .onLongPressGesture(minimumDuration: 0, maximumDistance: .infinity, pressing: { pressing in
                            withAnimation(AppAnimations.easeInOut) {
                                isPressed = pressing
                            }
                        }, perform: {})
                        
                        // Accept Button
                        Button(action: {
                            withAnimation(AppAnimations.spring) {
                                onAccept()
                            }
                        }) {
                            HStack(spacing: AppSpacing.sm) {
                                Image(systemName: "heart.fill")
                                    .font(AppTypography.buttonText)
                                Text("Accept")
                                    .font(AppTypography.buttonText)
                            }
                            .foregroundStyle(.white)
                            .frame(maxWidth: .infinity)
                            .frame(height: 50)
                            .background(AppColors.successGradient)
                            .clipShape(RoundedRectangle(cornerRadius: AppCornerRadius.round))
                            .shadow(color: AppColors.success.opacity(0.3), radius: AppShadows.medium.radius, x: AppShadows.medium.x, y: AppShadows.medium.y)
                        }
                        .primaryButtonStyle(isPressed: isPressed)
                        .onLongPressGesture(minimumDuration: 0, maximumDistance: .infinity, pressing: { pressing in
                            withAnimation(AppAnimations.easeInOut) {
                                isPressed = pressing
                            }
                        }, perform: {})
                    }
                }
            }
            .padding(AppSpacing.xl)
            .background(AppColors.cardBackground)
        }
        .cardStyle()
        .scaleEffect(isPressed ? 0.98 : 1.0)
        .animation(AppAnimations.spring, value: isPressed)
    }
    
    private var statusBadge: some View {
        Group {
            if profile.status == DecisionStatus.accepted.rawValue {
                statusLabel(text: "Accepted", color: .green, icon: "checkmark.circle.fill")
            } else if profile.status == DecisionStatus.declined.rawValue {
                statusLabel(text: "Declined", color: .red, icon: "xmark.circle.fill")
            }
        }
    }
    
    private func statusLabel(text: String, color: Color, icon: String) -> some View {
        HStack(spacing: AppSpacing.xs) {
            Image(systemName: icon)
                .font(AppTypography.statusText)
            Text(text)
                .font(AppTypography.statusText)
        }
        .foregroundStyle(.white)
        .padding(.horizontal, AppSpacing.md)
        .padding(.vertical, AppSpacing.sm)
        .background(
            Capsule()
                .fill(color)
                .shadow(color: color.opacity(0.3), radius: AppShadows.small.radius, x: AppShadows.small.x, y: AppShadows.small.y)
        )
    }
}
