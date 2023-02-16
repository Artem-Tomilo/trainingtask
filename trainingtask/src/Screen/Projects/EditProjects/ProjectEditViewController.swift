import UIKit

/*
 ProjectEditViewController - экран Редактирование проекта, отображает необходимые поля для введения нового, либо редактирования существующего проекта
 */
class ProjectEditViewController: UIViewController {
    
    private let projectEditView = ProjectEditView()
    private let spinnerView = SpinnerView()
    
    private let server: Server
    private var possibleProjectToEdit: Project?
    
    init(server: Server, possibleProjectToEdit: Project?) {
        self.server = server
        self.possibleProjectToEdit = possibleProjectToEdit
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureUI()
    }
    
    private func configureUI() {
        view.backgroundColor = .systemRed
        view.addSubview(projectEditView)
        
        NSLayoutConstraint.activate([
            projectEditView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 20),
            projectEditView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 15),
            projectEditView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -15),
            projectEditView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
        
        if let possibleProjectToEdit {
            title = "Редактирование проекта"
            projectEditView.bind(possibleProjectToEdit)
        } else {
            title = "Добавление проекта"
        }
        
        let saveButton = UIBarButtonItem(barButtonSystemItem: .save,
                                         target: self,
                                         action: #selector(saveProjectButtonTapped(_:)))
        navigationItem.rightBarButtonItem = saveButton
        
        let cancelButton = UIBarButtonItem(barButtonSystemItem: .cancel, target: self, action: #selector(cancel(_:)))
        navigationItem.leftBarButtonItem = cancelButton
        
        let gesture = UITapGestureRecognizer(target: self, action: #selector(tapGestureTapped(_:)))
        view.addGestureRecognizer(gesture)
    }
    
    /*
     Метод получает данные из текстФилдов экрана, делает валидацию и собирает модель проекта,
     при редактировании заменяет данные редактирумого проекта новыми данными
     
     Возвращаемое значение - проект
     */
    private func unbind() throws -> Project {
        var project = try projectEditView.unbind()
        if let possibleProjectToEdit {
            project.id = possibleProjectToEdit.id
        }
        return project
    }
    
    /*
     Метод добавляет новый проект в массив на сервере и возвращает на экран Список проектов,
     в случае ошибки происходит ее обработка
     
     parameters:
     newProject - новый проект для добавления
     */
    private func addingNewProjectOnServer(_ newProject: Project) {
        self.spinnerView.showSpinner(viewController: self)
        server.addProject(project: newProject) { result in
            switch result {
            case .success():
                self.spinnerView.hideSpinner()
                self.navigationController?.popViewController(animated: true)
            case .failure(let error):
                self.spinnerView.hideSpinner()
                self.handleError(error)
            }
        }
    }
    
    /*
     Метод изменяет данные проекта на сервере, в случае ошибки происходит ее обработка
     
     parameters:
     editedProject - изменяемый проект
     */
    private func editingProjectOnServer(_ editedProject: Project) {
        self.spinnerView.showSpinner(viewController: self)
        server.editProject(id: editedProject.id, editedProject: editedProject) { result in
            switch result {
            case .success():
                self.spinnerView.hideSpinner()
                self.navigationController?.popViewController(animated: true)
            case .failure(let error):
                self.spinnerView.hideSpinner()
                self.handleError(error)
            }
        }
    }
    
    /*
     Метод, который проверяет и сохраняет либо новый, либо отредактированный проект, в случае ошибки происходит ее обработка
     */
    private func saveProject() throws {
        let bindedProject = try unbind()
        if possibleProjectToEdit != nil {
            editingProjectOnServer(bindedProject)
        } else {
            addingNewProjectOnServer(bindedProject)
        }
    }
    
    /*
     Метод обработки ошибки - ошибка обрабатывается и вызывается алерт с предупреждением
     
     parameters:
     error - обрабатываемая ошибка
     */
    private func handleError(_ error: Error) {
        let projectError = error as! BaseError
        ErrorAlert.showAlertController(message: projectError.message, viewController: self)
    }
    
    /*
     Target на кнопку Save - делает валидацию и вызывает метод saveEmployee(),
     в случае ошибки происходит ее обработка
     */
    @objc func saveProjectButtonTapped(_ sender: UIBarButtonItem) {
        do {
            try saveProject()
        } catch {
            handleError(error)
        }
    }
    
    /*
     Target на кнопку Cancel - возвращает на предыдущий экран
     */
    @objc func cancel(_ sender: UIBarButtonItem) {
        navigationController?.popViewController(animated: true)
    }
    
    /*
     Target для UITapGestureRecognizer, который скрывает клавиатуру при нажатии на сводобное пространство на экране
     */
    @objc func tapGestureTapped(_ sender: UITapGestureRecognizer) {
        guard sender.state == .ended else { return }
        view.endEditing(false)
    }
}
