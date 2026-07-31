//
//  ReminderPickerView.swift
//  Countdown
//
//  Created by Antoine Coilliaux on 23/06/2026.
//

import SwiftUI

struct ReminderPickerView: View {
    let eventDate: Date
    let borderColor : Color
    
    @Binding var reminders: [ReminderOption]

    @State private var isCustomExpanded: Bool = false
    @State private var customDate: Date = Date()
    @State private var showDeniedBanner: Bool = false
    
    
    private var hasCustomReminder: Bool {
        reminders.contains { if case .custom = $0 { return true }; return false }
    }
    private var customReminder: ReminderOption? {
        reminders.first { if case .custom = $0 { return true }; return false }
    }
    
    var body: some View {
        VStack(spacing: 0) {
            if showDeniedBanner {
                deniedBanner
            }
            
            // Préréglages (Presets)
            VStack(spacing: 0) {
                ForEach(Array(ReminderPreset.allCases.enumerated()), id: \.offset) { index, preset in
                    Button {
                        toggle(preset.option)
                    } label: {
                        reminderRow(
                            label: preset.label,
                            sublabel: fireLabel(for: preset.option),
                            isSelected: reminders.contains(preset.option)
                        )
                    }
                    .buttonStyle(.plain)
                    .disabled(!isPresetAvailable(preset.option))
                    .opacity(isPresetAvailable(preset.option) ? 1 : 0.35)

                        AppDivider()
                }
            }
            
            // Partie "Custom"
            // MARK: Custom row
            VStack(spacing: 0) {
                Button {
                            isCustomExpanded.toggle()
                            customDate = defaultCustomDate

                } label: {
                    // 1️⃣ On passe une structure SwiftUI personnalisée au lieu d'un simple String pour le sublabel
                    HStack {
                        VStack(alignment: .leading) {
                            Text(K.ReminderPickerView.custom)
                                .font(.system(size: 16))
                                .foregroundStyle(.white)
                            
                            if let sub = customReminder.map({ formatCustomLabel($0) ?? "" }), !sub.isEmpty {
                                Text(sub)
                                    .font(.system(size: 12))
                                    .foregroundStyle(.white.opacity(0.45))
                            }
                        }
                        
                        Spacer()
                        
                        // 2️⃣ Zone de droite : Chevron rotatif + Checkmark si sélectionné
                        HStack(spacing: 12) {
                            if hasCustomReminder {
                                Image(systemName: "checkmark")
                                    .font(.system(size: 14, weight: .semibold))
                                    .foregroundStyle(.white)
                            }
                            
                            Image(systemName: "chevron.down")
                                .font(.system(size: 12, weight: .semibold))
                                .foregroundStyle(.white.opacity(0.3))
                            // 3️⃣ Animation de rotation à 180° quand le calendrier est déplié
                                .rotationEffect(.degrees(isCustomExpanded ? 180 : 0))
                        }
                    }
                    .padding(.horizontal, 16)
                    .padding(.vertical, 14)
                    .contentShape(Rectangle())
                }
                .buttonStyle(.plain)
                
                if isCustomExpanded {
                    AppDivider()
                    
                    DatePicker(
                        "",
                        selection: $customDate,
                        in: Date()...eventDate,
                        displayedComponents: [.date, .hourAndMinute]
                    )
                    .datePickerStyle(.graphical)
                    .colorScheme(.dark)
                    .padding(12)
                    .onChange(of: customDate) { _, newDate in
                        setCustomReminder(to: newDate)
                    }
                    
                    // Bouton de suppression (s'affiche uniquement si un rappel custom existe)
                    if hasCustomReminder {
                        AppDivider()
                        
                        Button(role: .destructive) {
                                removeCustomReminder()
                                isCustomExpanded = false
                        } label: {
                            Text(K.ReminderPickerView.removeReminder)
                                .font(.system(size: 15))
                                .foregroundStyle(.red)
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 14)
                        }
                    }
                }
            }
        }
        .background(CardBackground(borderColor: borderColor.opacity(0.65)))
        .padding(12)
        .onAppear {
            showDeniedBanner = NotificationManager.shared.isDenied
        }
    }
    
    private func presetRow(preset: ReminderPreset) -> some View {
        Button {
            toggle(preset.option)
        } label: {
            reminderRow(
                label: preset.label,
                sublabel: fireLabel(for: preset.option),
                isSelected: reminders.contains(preset.option)
            )
        }
        .buttonStyle(.plain)
    }
    
    /// Generic row: label on the left, optional sublabel + checkmark on the right.
    private func reminderRow(label: String, sublabel: String?, isSelected: Bool) -> some View {
        HStack {
            VStack(alignment: .leading, spacing: 2) {
                Text(label)
                    .font(.system(size: 16))
                    .foregroundStyle(.white)
                if let sub = sublabel {
                    Text(sub)
                        .font(.system(size: 12))
                        .foregroundStyle(.white.opacity(0.45))
                }
            }
            Spacer()
            if isSelected {
                Image(systemName: "checkmark")
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundStyle(.white)
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 14)
        .contentShape(Rectangle())
    }
    
    /// Small summary card at the bottom listing all active reminders.
    private var reminderSummary: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(K.ReminderPickerView.scheduled)
                .font(.system(size: 11, weight: .semibold))
                .foregroundStyle(.white.opacity(0.4))
                .tracking(1.2)
            
            VStack(spacing: 0) {
                ForEach(Array(reminders.enumerated()), id: \.element.id) { index, reminder in
                    HStack {
                        Image(systemName: "bell.fill")
                            .font(.system(size: 12))
                        Text(reminder.label)
                            .font(.system(size: 14))
                            .foregroundStyle(.white)
                        Spacer()
                        if let fire = reminder.fireDate(for: eventDate) {
                            Text(fire.formatted(date: .abbreviated, time: .shortened))
                                .font(.system(size: 12))
                                .foregroundStyle(.white.opacity(0.45))
                        } else {
                            Text(K.ReminderPickerView.inThePast)
                                .font(.system(size: 12))
                                .foregroundStyle(.red.opacity(0.8))
                        }
                    }
                    .padding(.horizontal, 16)
                    .padding(.vertical, 11)
                    
                    if index < reminders.count - 1 {
                        AppDivider()
                    }
                }
            }
            .background(CardBackground(borderColor: .white))
        }
    }
    
    private var deniedBanner: some View {
        HStack(spacing: 10) {
            Image(systemName: "bell.slash.fill")
                .foregroundStyle(.red)
            VStack(alignment: .leading, spacing: 2) {
                Text(K.ReminderPickerView.notificationsDisabledMessage)
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundStyle(.white)
                Text(K.ReminderPickerView.enableNotifications)
                    .font(.system(size: 12))
                    .foregroundStyle(.white.opacity(0.6))
            }
            Spacer()
            Button {
                if let url = URL(string: UIApplication.openSettingsURLString) {
                    UIApplication.shared.open(url)
                }
            } label: {
                Text(K.ReminderPickerView.settings)
                    .font(.system(size: 13, weight: .semibold))
            }
        }
        .padding(14)
        .background(CardBackground(borderColor: .red.opacity(0.4)))
    }
    
    // MARK: - Helpers
    
    private func toggle(_ option: ReminderOption) {
        Task {
            if reminders.contains(option) {
                reminders.removeAll { $0 == option }
            } else {
                // Request permission on first reminder activation
                let granted = await NotificationManager.shared.requestPermissionIfNeeded()
                if granted {
                    reminders.append(option)
                } else {
                    showDeniedBanner = NotificationManager.shared.isDenied
                }
            }
        }
    }
    
    private func setCustomReminder(to date: Date) {
        removeCustomReminder()
        reminders.append(.custom(date))
    }
    
    private func removeCustomReminder() {
        reminders.removeAll { if case .custom = $0 { return true }; return false }
    }
    
    /// Shows the computed fire date under a preset label, e.g. "Jun 22 · 8:30 AM".
    /// Returns nil if the fire date is in the past (row stays usable but no sublabel).
    private func fireLabel(for option: ReminderOption) -> String? {
        guard let fire = option.fireDate(for: eventDate), fire > Date() else { return nil }
        return fire.formatted(date: .abbreviated, time: .shortened)
    }
    
    private func formatCustomLabel(_ option: ReminderOption) -> String? {
        guard case .custom(let date) = option else { return nil }
        return date.formatted(date: .abbreviated, time: .shortened)
    }
    
    /// Default date for the custom picker: the day before the event at 9 AM,
    /// or 1 hour from now if the event is within 24 hours.
    private var defaultCustomDate: Date {
        let oneDayBefore = Calendar.current.date(byAdding: .day, value: -1, to: eventDate) ?? eventDate
        if oneDayBefore > Date() {
            return Calendar.current.date(bySettingHour: 9, minute: 0, second: 0, of: oneDayBefore) ?? oneDayBefore
        }
        return Date().addingTimeInterval(3600)
    }
    
    private func isPresetAvailable(_ option: ReminderOption) -> Bool {
        option.fireDate(for: eventDate).map { $0 > Date() } ?? false
    }
}

//#Preview {
//    ReminderPickerView()
//}
