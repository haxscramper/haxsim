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
    // NOTE order of declarations is important, logger must be initialized
    // first, and then implementation should have handle of the logger
    // object.
    EmuLoggerCxx logger;
    FullImplCxx  impl;
};

#endif // SIMCORE_HPP
