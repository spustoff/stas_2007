//
//  OnboardingView.swift
//  ChronoRoad Note
//
//  Created by Вячеслав on 10/6/25.
//

import SwiftUI

struct OnboardingView: View {
    @State private var currentStep = 0
    @AppStorage(Constants.UserDefaultsKeys.hasCompletedOnboarding) private var hasCompletedOnboarding = false
    
    var body: some View {
        ZStack {
            // Background
            LinearGradient(
                colors: [AppColors.primaryBackground, AppColors.primaryBackground.opacity(0.8)],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()
            
            VStack(spacing: 40) {
                // Progress Indicator
                progressIndicator
                
                // Content
                TabView(selection: $currentStep) {
                    ForEach(0..<Constants.Onboarding.totalSteps, id: \.self) { step in
                        OnboardingStepView(step: step)
                            .tag(step)
                    }
                }
                .tabViewStyle(PageTabViewStyle(indexDisplayMode: .never))
                .animation(.easeInOut, value: currentStep)
                
                // Navigation Buttons
                navigationButtons
            }
            .padding()
        }
    }
    
    private var progressIndicator: some View {
        HStack(spacing: 8) {
            ForEach(0..<Constants.Onboarding.totalSteps, id: \.self) { step in
                Circle()
                    .fill(step <= currentStep ? AppColors.accentYellow : AppColors.glassBackground)
                    .frame(width: 12, height: 12)
                    .scaleEffect(step == currentStep ? 1.2 : 1.0)
                    .animation(.easeInOut(duration: 0.3), value: currentStep)
            }
        }
        .padding(.top, 20)
    }
    
    private var navigationButtons: some View {
        HStack {
            if currentStep > 0 {
                Button("Previous") {
                    withAnimation {
                        currentStep -= 1
                    }
                }
                .foregroundColor(AppColors.secondaryText)
            }
            
            Spacer()
            
            if currentStep < Constants.Onboarding.totalSteps - 1 {
                Button("Next") {
                    withAnimation {
                        currentStep += 1
                    }
                }
                .padding(.horizontal, 24)
                .padding(.vertical, 12)
                .background(AppColors.accentYellow)
                .foregroundColor(.white)
                .cornerRadius(25)
            } else {
                Button("Get Started") {
                    completeOnboarding()
                }
                .padding(.horizontal, 24)
                .padding(.vertical, 12)
                .background(AppColors.accentGreen)
                .foregroundColor(.white)
                .cornerRadius(25)
            }
        }
        .padding(.bottom, 20)
    }
    
    private func completeOnboarding() {
        hasCompletedOnboarding = true
    }
}

struct OnboardingStepView: View {
    let step: Int
    
    var body: some View {
        VStack(spacing: 30) {
            // Icon
            Image(systemName: stepIcon)
                .font(.system(size: 100))
                .foregroundColor(AppColors.accentYellow)
                .padding(.top, 40)
            
            // Title
            Text(Constants.Onboarding.stepTitles[step])
                .font(.largeTitle.bold())
                .foregroundColor(AppColors.primaryText)
                .multilineTextAlignment(.center)
            
            // Description
            Text(Constants.Onboarding.stepDescriptions[step])
                .font(.body)
                .foregroundColor(AppColors.secondaryText)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 20)
            
            // Feature Preview
            featurePreview
            
            Spacer()
        }
    }
    
    private var stepIcon: String {
        switch step {
        case 0: return "note.text.badge.plus"
        case 1: return "checkmark.circle.fill"
        case 2: return "lightbulb.fill"
        case 3: return "calendar"
        default: return "note.text.badge.plus"
        }
    }
    
    private var featurePreview: some View {
        Group {
            switch step {
            case 0:
                welcomePreview
            case 1:
                taskPreview
            case 2:
                notePreview
            case 3:
                plannerPreview
            default:
                EmptyView()
            }
        }
    }
    
    private var welcomePreview: some View {
        VStack(spacing: 16) {
            HStack {
                Image(systemName: "checkmark.circle.fill")
                    .foregroundColor(AppColors.successGreen)
                Text("Smart Task Management")
                    .foregroundColor(AppColors.primaryText)
                Spacer()
            }
            
            HStack {
                Image(systemName: "note.text")
                    .foregroundColor(AppColors.infoBlue)
                Text("Dynamic Note System")
                    .foregroundColor(AppColors.primaryText)
                Spacer()
            }
            
            HStack {
                Image(systemName: "calendar")
                    .foregroundColor(AppColors.warningYellow)
                Text("Daily Planning")
                    .foregroundColor(AppColors.primaryText)
                Spacer()
            }
        }
        .padding()
        .glassmorphism()
    }
    
    private var taskPreview: some View {
        VStack(spacing: 12) {
            HStack {
                Circle()
                    .fill(AppColors.successGreen)
                    .frame(width: 12, height: 12)
                Text("Complete project proposal")
                    .foregroundColor(AppColors.primaryText)
                Spacer()
                Text("High")
                    .font(.caption)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 2)
                    .background(AppColors.errorRed.opacity(0.3))
                    .foregroundColor(AppColors.errorRed)
                    .cornerRadius(8)
            }
            
            HStack {
                Circle()
                    .stroke(AppColors.secondaryText, lineWidth: 2)
                    .frame(width: 12, height: 12)
                Text("Schedule team meeting")
                    .foregroundColor(AppColors.primaryText)
                Spacer()
                Text("Medium")
                    .font(.caption)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 2)
                    .background(AppColors.warningYellow.opacity(0.3))
                    .foregroundColor(AppColors.warningYellow)
                    .cornerRadius(8)
            }
            
            HStack {
                Circle()
                    .stroke(AppColors.secondaryText, lineWidth: 2)
                    .frame(width: 12, height: 12)
                Text("Update portfolio")
                    .foregroundColor(AppColors.primaryText)
                Spacer()
                Text("Low")
                    .font(.caption)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 2)
                    .background(AppColors.successGreen.opacity(0.3))
                    .foregroundColor(AppColors.successGreen)
                    .cornerRadius(8)
            }
        }
        .padding()
        .glassmorphism()
    }
    
    private var notePreview: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: "lightbulb.fill")
                    .foregroundColor(AppColors.warningYellow)
                Text("Ideas for App Improvement")
                    .font(.headline)
                    .foregroundColor(AppColors.primaryText)
                Spacer()
            }
            
            Text("1. Add dark mode support\n2. Implement push notifications\n3. Create iOS widget")
                .font(.body)
                .foregroundColor(AppColors.secondaryText)
                .frame(maxWidth: .infinity, alignment: .leading)
            
            HStack {
                Text("Ideas")
                    .font(.caption)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 2)
                    .background(AppColors.warningYellow.opacity(0.3))
                    .foregroundColor(AppColors.warningYellow)
                    .cornerRadius(8)
                
                Spacer()
                
                Image(systemName: "heart.fill")
                    .foregroundColor(AppColors.errorRed)
            }
        }
        .padding()
        .glassmorphism()
    }
    
    private var plannerPreview: some View {
        VStack(spacing: 12) {
            HStack {
                Text("Today")
                    .font(.headline)
                    .foregroundColor(AppColors.primaryText)
                Spacer()
                Text("Oct 6, 2025")
                    .font(.caption)
                    .foregroundColor(AppColors.secondaryText)
            }
            
            VStack(spacing: 8) {
                HStack {
                    Rectangle()
                        .fill(AppColors.accentYellow)
                        .frame(width: 4, height: 20)
                    Text("9:00 AM - Team Meeting")
                        .foregroundColor(AppColors.primaryText)
                    Spacer()
                }
                
                HStack {
                    Rectangle()
                        .fill(AppColors.successGreen)
                        .frame(width: 4, height: 20)
                    Text("2:00 PM - Project Review")
                        .foregroundColor(AppColors.primaryText)
                    Spacer()
                }
                
                HStack {
                    Rectangle()
                        .fill(AppColors.infoBlue)
                        .frame(width: 4, height: 20)
                    Text("4:00 PM - Note Review")
                        .foregroundColor(AppColors.primaryText)
                    Spacer()
                }
            }
        }
        .padding()
        .glassmorphism()
    }
}

#Preview {
    OnboardingView()
}
