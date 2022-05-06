#ifndef EM_MAIN_HPP
#define EM_MAIN_HPP

#include "simcore.hpp"
#include <QDockWidget>
#include <QMainWindow>
#include <QTableView>
#include <QToolBar>
#include <QWidget>

class MemoryTable : public QTableView
{
    Q_OBJECT
  public:
    explicit MemoryTable(QWidget* parent);
};

class MemEditor : public QWidget
{
    Q_OBJECT
  public:
    explicit MemEditor(QWidget* parent = nullptr);

  private:
    MemoryTable* table;
    QToolBar*    tools;
};


class DockWidget : public QDockWidget
{
    Q_OBJECT
  public:
    explicit DockWidget(const QString& name, QWidget* parent);
};

class RegisterView : public DockWidget
{
    Q_OBJECT
  public:
    explicit RegisterView(QWidget* parent);
};

class MainWindow : public QMainWindow
{
    Q_OBJECT
  public:
    explicit MainWindow();

  private:
    SimCore       core;
    MemEditor*    mem;
    RegisterView* regs;
};


#endif // EM_MAIN_HPP
