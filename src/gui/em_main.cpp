#include <QApplication>
#include <QDebug>
#include <QDockWidget>
#include <QLayout>
#include <QMainWindow>
#include <QPlainTextEdit>
#include <QPushButton>
#include <QVBoxLayout>
#include "em_main.hpp"

void NimMain();


int main(int argc, char** argv) {
    NimMain();
    QApplication a(argc, argv);
    MainWindow  w;
    auto         main = new QWidget(&w);
    auto         edit = new QPlainTextEdit(main);
    auto         ok   = new QPushButton("Central button", main);
    main->setLayout(new QVBoxLayout());
    main->layout()->addWidget(edit);
    main->layout()->addWidget(ok);
    w.setCentralWidget(main);
    QObject::connect(ok, &QPushButton::clicked, [edit]() {
        qDebug() << "Pressed button";
        std::string s    = edit->toPlainText().toStdString();
        char*       data = s.data();
        //        haxsim_print_test(data);
    });
    w.show();
    return a.exec();
}
