//
//  ContentView.swift
//  FocusTasks
//
//  Created by Князь on 16.10.2025.
//

import SwiftUI
import Foundation

struct ContentView: View {
    @State private var tasks: [Task] = []
    @State private var newTitle: String = ""
    @State private var showDuplicateAlert = false
    @State private var editingID: UUID? = nil
    @FocusState private var focusedTaskID: UUID?
    
    
    @AppStorage("tasksData") private var tasksData: Data?
    private let encoder = JSONEncoder()
    private let decoder = JSONDecoder()
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 12) {
                HStack {
                    TextField("Новая задача", text: $newTitle)
                        .textFieldStyle(.roundedBorder)
                        .submitLabel(.done)
                        .onSubmit { addTask() }
                    
                    Button("Добавить") { addTask() }
                        .buttonStyle(.borderedProminent)
                        .disabled(newTitle.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                }
                .padding(.horizontal)
                
                if tasks.isEmpty {
                    VStack(spacing: 8) {
                        Image(systemName: "checklist")
                            .font(.largeTitle)
                            .foregroundStyle(.secondary)
                        Text("Пока пусто")
                            .font(.headline)
                        Text("Добавь первую задачу — начнём список.")
                            .foregroundStyle(.secondary)
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                } else {
                    List {
                        ForEach($tasks) { $task in
                            HStack(spacing: 12) {
                                Button {
                                    task.isDone.toggle()
                                } label: {
                                    Image(systemName: task.isDone ? "checkmark.circle.fill" : "circle")
                                }

                                if editingID == task.id {
                                    TextField("Название задачи", text: $task.title)
                                        .textFieldStyle(.roundedBorder)
                                        .submitLabel(.done)
                                        .focused($focusedTaskID, equals: task.id)
                                        .onSubmit { finishEdit(id: task.id) }
                                        .onAppear { focusedTaskID = task.id }
                                } else {
                                    Text(task.title)
                                        .strikethrough(task.isDone)
                                        .foregroundStyle(task.isDone ? .secondary : .primary)
                                        .animation(.default, value: task.isDone)
                                        .onTapGesture { startEdit(id: task.id) }
                                }
                            }
                            .swipeActions(edge: .trailing, allowsFullSwipe: false) {
                                Button("Изменить") { startEdit(id: task.id) }
                            }
                        }
                        .onDelete(perform: deleteTasks)
                    }
                    .listStyle(.insetGrouped)
                }
            }
            .navigationTitle("FocusTasks")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    EditButton()
                }
                ToolbarItemGroup(placement: .keyboard) {
                    Spacer()
                    if let id = editingID {
                        Button("Готово") { finishEdit(id: id) }
                    }
                }
            }
            .animation(.default, value: tasks)
            .alert("Такая задача уже есть", isPresented: $showDuplicateAlert) {
                Button("OK", role: .cancel) { }
            } message: {
                Text("Задача с такой формулировкой уже есть")
            }
            .onAppear { loadTasks() }
            .onChange(of: tasks) {
                saveTasks()
            }
        }
    }
    
    
    
    private func addTask() {
        let trimmed = newTitle.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return }

        let parts = trimmed.components(separatedBy: .whitespacesAndNewlines)
                           .filter { !$0.isEmpty }
        let compact = parts.joined(separator: " ")

        guard !hasDuplicate(compact) else {
            showDuplicateAlert = true
            return
        }

        tasks.insert(Task(title: compact), at: 0)

        newTitle = ""
    }
    
    private func deleteTasks(_ offsets: IndexSet) {
        tasks.remove(atOffsets: offsets)
    }
    
    private func saveTasks() {
        do {
            encoder.outputFormatting = [.withoutEscapingSlashes]
            let data = try encoder.encode(tasks)
            tasksData = data
        } catch {
            print("saveTasks error:", error)
        }
    }
        private func loadTasks() {
            guard let data = tasksData else { return }
            do {
                let loaded = try  decoder.decode([Task].self,from: data)
                tasks = loaded
            } catch {
                print("loadTasks error:", error)
            }
        }
    
    private func startEdit(id: UUID) {
        editingID = id
        focusedTaskID = id
    }
    
    private func finishEdit(id: UUID) {
        guard let i = tasks.firstIndex(where: { $0.id == id}) else {
            editingID = nil
            focusedTaskID = nil
            return
        }
        let trimmed = tasks[i].title.trimmingCharacters(in: .whitespacesAndNewlines)
        tasks[i].title = trimmed.isEmpty ? "Без названия" : trimmed
        editingID = nil
        focusedTaskID = nil
    }
    
    private func normalized(_ s: String) -> String {
        let parts = s.components(separatedBy: .whitespacesAndNewlines)
            .filter { !$0.isEmpty }
        return parts.joined(separator: " ").lowercased()
    }
    
    private func hasDuplicate(_ title: String) -> Bool {
        let key = normalized(title)
        return tasks.contains { normalized($0.title) == key }
    }
    
}

#Preview {
    ContentView()
}
