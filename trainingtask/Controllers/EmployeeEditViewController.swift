//
//  EmployeeEditViewController.swift
//  trainingtask
//
//  Created by Артем Томило on 21.09.22.
//

import UIKit

class EmployeeEditViewController: UIViewController {
    
    //MARK: - Private property
    
    private let surnameTextField = MyTextField()
    private let nameTextField = MyTextField()
    private let patronymicTextField = MyTextField()
    private let positionTextField = MyTextField()
    
    private var saveButton = UIBarButtonItem()
    private var cancelButton = UIBarButtonItem()
    
    private var array = [Employee]()
    
    //MARK: - VC lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setup()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        navigationController?.isNavigationBarHidden = false
        navigationController?.navigationBar.backgroundColor = .systemGray6
        view.backgroundColor = .systemGray6
        
        title = "Добавление сотрудника"
    }
    
    //MARK: - Setup function
    
    private func setup() {
        view.addSubview(surnameTextField)
        view.addSubview(nameTextField)
        view.addSubview(patronymicTextField)
        view.addSubview(positionTextField)
        
        NSLayoutConstraint.activate([
            surnameTextField.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 20),
            surnameTextField.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 15),
            surnameTextField.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -15),
            
            nameTextField.topAnchor.constraint(equalTo: surnameTextField.bottomAnchor, constant: 50),
            nameTextField.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 15),
            nameTextField.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -15),
            
            patronymicTextField.topAnchor.constraint(equalTo: nameTextField.bottomAnchor, constant: 50),
            patronymicTextField.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 15),
            patronymicTextField.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -15),
            
            positionTextField.topAnchor.constraint(equalTo: patronymicTextField.bottomAnchor, constant: 50),
            positionTextField.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 15),
            positionTextField.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -15),
        ])
        
        surnameTextField.placeholder = "Фамилия"
        nameTextField.placeholder = "Имя"
        patronymicTextField.placeholder = "Отчество"
        positionTextField.placeholder = "Должность"
        
        saveButton = UIBarButtonItem(barButtonSystemItem: .save, target: self, action: #selector(saveEmployee(_:)))
        navigationItem.rightBarButtonItem = saveButton
        
        cancelButton = UIBarButtonItem(barButtonSystemItem: .cancel, target: self, action: #selector(cancel(_:)))
        navigationItem.leftBarButtonItem = cancelButton
    }
    
    func addNewEmployee(newEmployee: Employee) {
        array.append(newEmployee)
        saveEmployeetoFile(array: array)
        navigationController?.popViewController(animated: true)
    }
    
    func saveEmployeetoFile(array: [Employee]) {
        let path = try! FileManager.default.url(for: .documentDirectory, in: .allDomainsMask, appropriateFor: nil, create: true)
        let jsonPath = path.appendingPathComponent("employees.json")
        
        let encoder = JSONEncoder()
        do {
            let data = try encoder.encode(array)
            try data.write(to: jsonPath, options: Data.WritingOptions.atomic)
        } catch {
            print("Error encoding item array: \(error.localizedDescription)")
        }
    }
    
    //MARK: - Targets
    
    @objc func saveEmployee(_ sender: UIBarButtonItem) {
        if let surname = surnameTextField.text,
           let name = nameTextField.text,
           let patronymic = patronymicTextField.text,
           let position = positionTextField.text {
            
            let employee = Employee(surname: surname, name: name, patronymic: patronymic, position: position)
            addNewEmployee(newEmployee: employee)
            
        }
    }
    
    @objc func cancel(_ sender: UIBarButtonItem) {
        navigationController?.popViewController(animated: true)
    }
}
