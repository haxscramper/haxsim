#ifndef SIMCORE_HPP
#define SIMCORE_HPP

#include "haxsim.h"
#include <QObject>
#include <QVector>

template <typename T>
using CL = const T&;


Q_DECLARE_METATYPE(EmuEventCxx);

/// Stored list of the event IDs
struct EventStore {
    QVector<EmuEventCxx> events;
};

class SimCore : public QObject
{
    Q_OBJECT
  public:
    explicit SimCore(ESize memSize, QObject* parent = nullptr);
    inline int   memSize() { return impl.get_mem_size(); }
    inline EByte memGet(EPointer addr) { return impl.get_mem(addr); }
    inline void  memSet(EPointer addr, EByte value) {
        impl.set_mem(addr, value);
    }

  signals:
    /// Signal emitted on each memory write operation
    void memoryWrite(EmuEventCxx);
    /// Signal emutted on each memory read operation
    void memoryRead(EmuEventCxx);

  private:
    // NOTE order of declarations is important, logger must be initialized
    // first, and then implementation should have handle of the logger
    // object.
    EmuLoggerCxx logger;
    FullImplCxx  impl;
};

#endif // SIMCORE_HPP
