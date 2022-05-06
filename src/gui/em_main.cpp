#include "em_main.hpp"
#include <QApplication>
#include <QDebug>
#include <QDockWidget>
#include <QLabel>
#include <QLayout>
#include <QMainWindow>
#include <QPlainTextEdit>
#include <QPushButton>
#include <QVBoxLayout>

void NimMain();

MemoryTable::MemoryTable(QWidget* parent) {
}

void greebBorder(QWidget* widget) {
    widget->setStyleSheet("border:1px solid rgb(0, 255, 0); ");
}


MemEditor::MemEditor(QWidget* parent)
    : table(new MemoryTable(this)), tools(new QToolBar(this)) {
    setLayout(new QVBoxLayout());
    auto label = new QLabel("Memory", this);
    label->setSizePolicy(QSizePolicy::Expanding, QSizePolicy::Minimum);
    label->setAlignment(Qt::AlignCenter);
    layout()->addWidget(label);
    layout()->addWidget(tools);
    layout()->addWidget(table);
}

DockWidget::DockWidget(const QString& name, QWidget* parent) {
}

RegisterView::RegisterView(QWidget* parent)
    : DockWidget("Registers", parent) {
    setLayout(new QVBoxLayout());
    setWidget(new QLabel("REGISTERS"));
}


MainWindow::MainWindow()
    : mem(new MemEditor(this)), regs(new RegisterView(this)) {
    setCentralWidget(mem);
    regs->show();
    addDockWidget(Qt::RightDockWidgetArea, regs);
}

int main(int argc, char** argv) {
    NimMain();
    QApplication a(argc, argv);
    MainWindow   w;
    w.resize(600, 600);
    w.show();
    return a.exec();
}
