# Library App (Flutter, MVVM)

A Flutter library app built with the Model–View–ViewModel (MVVM) architecture and Material 3.
It has a book catalog with stock per title, a loan list with due dates and a return button, and a fine summary.

Core rule: **Models hold data, ViewModels make decisions, Views display results.**

## Questions and Answers

### 1. What is the difference between the Model, View, and ViewModel in this application?

The Model only holds data (`Book`, `Loan`). The ViewModel makes the decisions (can this book be borrowed, how much is the fine, what is the status), and the View only shows the results and passes the user's actions to the ViewModel.

### 2. What should happen if a student attempts to borrow a book that already has an active loan?

The app must reject it. `borrowBook` in the ViewModel returns the message "Buku sedang tidak tersedia." and changes nothing, and the View just shows that message in a SnackBar.

### 3. Why is it better to calculate the fine in one place rather than repeating the formula in multiple widgets?

If the formula is copied into many widgets, they can give different results and every copy must be changed when the rule changes. With one place (`FineCalculator`), every screen shows the same number and a fix is made only once.

### 4. What is the difference between a book being Overdue and being Missing?

Overdue means the due date has passed, so a fine is growing, but the book is still counted as borrowed. Missing means six calendar months have passed since the due date, and the bill becomes the fine up to that date plus the book's replacement price.

### 5. If the university changes its weekly fine from Rp5,000 to Rp7,000, how should the app be updated?

Change only the policy constant in `FineCalculator` (for example `baseDailyRate`). The View and ViewModel do not need to change, then re-test the fine scenarios.