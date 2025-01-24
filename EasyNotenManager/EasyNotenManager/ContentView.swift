//
//  ContentView.swift
//  EasyNotenManager
//
//  Created by Oliver Henkel on 24.01.25.
//

import SwiftUI

struct ContentView: View {
    @State private var subjects: [Subject] = [] {
        didSet {
            saveSubjects()
        }
    }
    @State private var newSubjectName: String = ""
    
    var body: some View {
        NavigationView {
            VStack {
                // Hinzufügen von Fächern
                HStack {
                    TextField("Neues Fach", text: $newSubjectName)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .padding(.horizontal)
                    Button(action: addSubject) {
                        Text("Hinzufügen")
                            .padding(.horizontal)
                            .padding(.vertical, 8)
                            .background(Color.blue)
                            .foregroundColor(.white)
                            .cornerRadius(8)
                    }
                }
                .padding()

                // Tabelle der Noten
                ScrollView(.horizontal) {
                    VStack(spacing: 0) {
                        // Fächerzeile mit Löschbuttons
                        HStack(spacing: 0) {
                            TableCell(text: "Fach", isHeader: true, width: 150)
                            ForEach(subjects.indices, id: \.self) { index in
                                HStack(spacing: 0) {
                                    ZStack {
                                        Text(subjects[index].name)
                                            .font(.headline)
                                            .frame(width: 120, alignment: .center) // Konstante Breite für den Namen
                                        HStack {
                                            Spacer()
                                            Button(action: { deleteSubject(at: index) }) {
                                                Image(systemName: "trash")
                                                    .foregroundColor(.red)
                                            }
                                            .padding(.trailing, 5)
                                        }
                                    }
                                    .frame(width: 150) // Gesamtbreite für Fach und Symbol

                                    // Vertikale Trennlinie
                                    if index != subjects.count - 1 { // Kein Strich nach der letzten Zelle
                                        Divider()
                                            .frame(width: 1, height: 40) // Höhe der Linie
                                            .background(Color.gray)
                                    }
                                }
                            }
                        }
                        Divider()

                        // Schulaufgaben
                        HStack(spacing: 0) {
                            TableCell(text: "SA", isHeader: true, width: 150)
                            ForEach(subjects.indices, id: \.self) { index in
                                GradeColumn(grades: $subjects[index].grades.schulaufgaben)
                                    .frame(width: 150)
                                    .border(Color.gray)
                            }
                        }
                        Divider()

                        // Exen
                        HStack(spacing: 0) {
                            TableCell(text: "EX", isHeader: true, width: 150)
                            ForEach(subjects.indices, id: \.self) { index in
                                GradeColumn(grades: $subjects[index].grades.exen)
                                    .frame(width: 150)
                                    .border(Color.gray)
                            }
                        }
                        Divider()

                        // Mündliche Noten
                        HStack(spacing: 0) {
                            TableCell(text: "Mündlich", isHeader: true, width: 150)
                            ForEach(subjects.indices, id: \.self) { index in
                                GradeColumn(grades: $subjects[index].grades.muendlich)
                                    .frame(width: 150)
                                    .border(Color.gray)
                            }
                        }
                        Divider()

                        // Durchschnittsnoten
                        HStack(spacing: 0) {
                            TableCell(text: "Durchschnitt", isHeader: true, width: 150)
                            ForEach(subjects) { subject in
                                TableCell(text: String(format: "%.2f", subject.average), isHeader: false, width: 150)
                            }
                        }
                    }
                    .border(Color.gray)
                }

                // Zeugnisdurchschnitt
                Text("Zeugnisdurchschnitt: \(String(format: "%.2f", overallAverage))")
                    .font(.headline)
                    .padding()
                    .background(Color(.systemGray6)) // Anpassung an Light/Dark Mode
                    .foregroundColor(Color.primary)
                    .cornerRadius(8)
                    .shadow(color: Color.primary.opacity(0.2), radius: 2, x: 0, y: 2)


                Spacer()
            }
            .navigationTitle("Notenmanager")
            .onAppear(perform: loadSubjects) // Daten beim Start laden
        }
    }

    // Fach hinzufügen
    private func addSubject() {
        guard !newSubjectName.isEmpty else { return }
        let newSubject = Subject(name: newSubjectName)
        subjects.append(newSubject)
        newSubjectName = ""
    }

    // Fach löschen
    private func deleteSubject(at index: Int) {
        subjects.remove(at: index)
    }

    // Gesamtdurchschnitt berechnen
    private var overallAverage: Double {
        guard !subjects.isEmpty else { return 0.0 }
        let totalAverage = subjects.reduce(0.0) { $0 + $1.average }
        return totalAverage / Double(subjects.count)
    }

    // Daten speichern
    private func saveSubjects() {
        do {
            let encoder = JSONEncoder()
            let data = try encoder.encode(subjects)
            UserDefaults.standard.set(data, forKey: "subjects")
        } catch {
            print("Fehler beim Speichern der Daten: \(error)")
        }
    }

    // Daten laden
    private func loadSubjects() {
        guard let data = UserDefaults.standard.data(forKey: "subjects") else { return }
        do {
            let decoder = JSONDecoder()
            subjects = try decoder.decode([Subject].self, from: data)
        } catch {
            print("Fehler beim Laden der Daten: \(error)")
        }
    }
}

struct TableCell: View {
    var text: String
    var isHeader: Bool
    var width: CGFloat

    var body: some View {
        Text(text)
            .font(isHeader ? .headline : .body)
            .frame(width: width, height: 40)
            .multilineTextAlignment(.center)
            .background(isHeader ? Color.gray.opacity(0.2) : Color(.systemBackground)) // Dynamischer Hintergrund
            .foregroundColor(isHeader ? .primary : .primary) // Dynamische Textfarbe
            .border(Color.gray)
    }
}

struct GradeColumn: View {
    @Binding var grades: [Int]
    @State private var newGrade: String = ""

    var body: some View {
        VStack {
            ForEach(grades.indices, id: \.self) { index in
                HStack {
                    Text("\(grades[index])")
                    Spacer()
                    Button(action: { grades.remove(at: index) }) {
                        Image(systemName: "minus.circle")
                            .foregroundColor(.red)
                    }
                }
            }

            HStack {
                TextField("Note", text: $newGrade)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .keyboardType(.numberPad)

                Button(action: addGrade) {
                    Image(systemName: "plus.circle")
                        .foregroundColor(.green)
                }
            }
        }
    }

    private func addGrade() {
        if let grade = Int(newGrade), grade >= 1, grade <= 6 {
            grades.append(grade)
            newGrade = ""
        }
    }
}

struct Subject: Identifiable, Codable {
    let id = UUID()
    let name: String
    var grades: Grades = Grades()

    var average: Double {
        grades.average
    }
}

struct Grades: Codable {
    var schulaufgaben: [Int] = []
    var exen: [Int] = []
    var muendlich: [Int] = []

    var average: Double {
        let weightedSchulaufgaben = schulaufgaben.flatMap { [$0, $0] }
        let allGrades = weightedSchulaufgaben + exen + muendlich
        guard !allGrades.isEmpty else { return 0.0 }
        return Double(allGrades.reduce(0, +)) / Double(allGrades.count)
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}

#Preview {
    ContentView()
}
