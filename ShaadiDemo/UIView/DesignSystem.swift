//
//  DesignSystem.swift
//  ShaadiDemo
//
//  Created by Abhishek Garg on 9/26/25.
//

import SwiftUI

// MARK: - Color Scheme
struct AppColors {
    // Primary Colors
    static let primary = Color(red: 0.2, green: 0.4, blue: 0.8) // Deep Blue
    static let primaryLight = Color(red: 0.3, green: 0.5, blue: 0.9)
    static let primaryDark = Color(red: 0.1, green: 0.3, blue: 0.7)
    
    // Accent Colors
    static let accent = Color(red: 0.9, green: 0.3, blue: 0.4) // Coral Red
    static let accentLight = Color(red: 0.95, green: 0.4, blue: 0.5)
    
    // Success & Error Colors
    static let success = Color(red: 0.2, green: 0.7, blue: 0.3) // Forest Green
    static let successLight = Color(red: 0.3, green: 0.8, blue: 0.4)
    static let error = Color(red: 0.8, green: 0.2, blue: 0.2) // Deep Red
    static let errorLight = Color(red: 0.9, green: 0.3, blue: 0.3)
    
    // Neutral Colors
    static let background = Color(.systemBackground)
    static let secondaryBackground = Color(.secondarySystemBackground)
    static let tertiaryBackground = Color(.tertiarySystemBackground)
    
    // Text Colors
    static let textPrimary = Color(.label)
    static let textSecondary = Color(.secondaryLabel)
    static let textTertiary = Color(.tertiaryLabel)
    
    // Card Colors
    static let cardBackground = Color(.systemBackground)
    static let cardBorder = Color(.separator)
    
    // Gradient Colors
    static let primaryGradient = LinearGradient(
        colors: [primary, primaryLight],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )
    
    static let successGradient = LinearGradient(
        colors: [success, successLight],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )
    
    static let errorGradient = LinearGradient(
        colors: [error, errorLight],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )
    
    static let backgroundGradient = LinearGradient(
        colors: [
            Color(.systemBackground),
            Color(.systemGray6).opacity(0.3)
        ],
        startPoint: .top,
        endPoint: .bottom
    )
}

// MARK: - Typography
struct AppTypography {
    // Headers
    static let largeTitle = Font.system(size: 34, weight: .bold, design: .rounded)
    static let title1 = Font.system(size: 28, weight: .bold, design: .rounded)
    static let title2 = Font.system(size: 22, weight: .bold, design: .rounded)
    static let title3 = Font.system(size: 20, weight: .semibold, design: .rounded)
    
    // Body Text
    static let headline = Font.system(size: 17, weight: .semibold, design: .default)
    static let body = Font.system(size: 17, weight: .regular, design: .default)
    static let callout = Font.system(size: 16, weight: .regular, design: .default)
    static let subheadline = Font.system(size: 15, weight: .regular, design: .default)
    static let footnote = Font.system(size: 13, weight: .regular, design: .default)
    static let caption1 = Font.system(size: 12, weight: .regular, design: .default)
    static let caption2 = Font.system(size: 11, weight: .regular, design: .default)
    
    // Custom Profile Text
    static let profileName = Font.system(size: 24, weight: .bold, design: .rounded)
    static let profileDetails = Font.system(size: 16, weight: .medium, design: .default)
    static let buttonText = Font.system(size: 16, weight: .semibold, design: .default)
    static let statusText = Font.system(size: 14, weight: .semibold, design: .default)
}

// MARK: - Spacing
struct AppSpacing {
    static let xs: CGFloat = 4
    static let sm: CGFloat = 8
    static let md: CGFloat = 12
    static let lg: CGFloat = 16
    static let xl: CGFloat = 20
    static let xxl: CGFloat = 24
    static let xxxl: CGFloat = 32
}

// MARK: - Corner Radius
struct AppCornerRadius {
    static let sm: CGFloat = 8
    static let md: CGFloat = 12
    static let lg: CGFloat = 16
    static let xl: CGFloat = 20
    static let xxl: CGFloat = 25
    static let round: CGFloat = 50
}

// MARK: - Shadows
struct AppShadows {
    static let small = Shadow(color: Color.black.opacity(0.05), radius: 1, x: 0, y: 1)
    static let medium = Shadow(color: Color.black.opacity(0.1), radius: 8, x: 0, y: 4)
    static let large = Shadow(color: Color.black.opacity(0.1), radius: 20, x: 0, y: 10)
    static let card = Shadow(color: Color.black.opacity(0.1), radius: 20, x: 0, y: 10)
    
    struct Shadow {
        let color: Color
        let radius: CGFloat
        let x: CGFloat
        let y: CGFloat
    }
}

// MARK: - Animation Constants
struct AppAnimations {
    static let spring = Animation.spring(response: 0.3, dampingFraction: 0.7)
    static let springSlow = Animation.spring(response: 0.4, dampingFraction: 0.8)
    static let easeInOut = Animation.easeInOut(duration: 0.2)
    static let easeOut = Animation.easeOut(duration: 0.3)
}

// MARK: - View Modifiers
struct CardModifier: ViewModifier {
    func body(content: Content) -> some View {
        content
            .background(
                RoundedRectangle(cornerRadius: AppCornerRadius.xl)
                    .fill(AppColors.cardBackground)
                    .shadow(
                        color: AppShadows.card.color,
                        radius: AppShadows.card.radius,
                        x: AppShadows.card.x,
                        y: AppShadows.card.y
                    )
                    .shadow(
                        color: AppShadows.small.color,
                        radius: AppShadows.small.radius,
                        x: AppShadows.small.x,
                        y: AppShadows.small.y
                    )
            )
            .clipShape(RoundedRectangle(cornerRadius: AppCornerRadius.xl))
    }
}

struct PrimaryButtonModifier: ViewModifier {
    let isPressed: Bool
    
    func body(content: Content) -> some View {
        content
            .scaleEffect(isPressed ? 0.95 : 1.0)
            .animation(AppAnimations.easeInOut, value: isPressed)
    }
}

// MARK: - Extensions
extension View {
    func cardStyle() -> some View {
        modifier(CardModifier())
    }
    
    func primaryButtonStyle(isPressed: Bool = false) -> some View {
        modifier(PrimaryButtonModifier(isPressed: isPressed))
    }
}
