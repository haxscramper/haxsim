#ifndef SIMCORE_HPP
#define SIMCORE_HPP

#include "haxsim.h"
#include <QObject>

class SimCore : public QObject
{
    Q_OBJECT
  public:
    explicit SimCore(QObject* parent = nullptr);

  signals:

  private:
    FullImplCxx impl;
};

#endif // SIMCORE_HPP
