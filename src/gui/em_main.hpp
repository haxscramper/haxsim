#ifndef EM_MAIN_HPP
#define EM_MAIN_HPP

#include "simcore.hpp"
#include <QDockWidget>
#include <QMainWindow>
#include <QWidget>

class MemEditor : public QWidget
{
    Q_OBJECT
  public:
};

class MainWindow : public QMainWindow
{
    Q_OBJECT
  public:
    SimCore core;
};

#endif // EM_MAIN_HPP
