#ifndef SIMCORE_HPP
#define SIMCORE_HPP

#include "haxsim.h"
#include <QObject>
#include <QVector>

template <typename T>
using CL = const T&;

using U8  = unsigned char;
using U16 = unsigned short;
using U32 = unsigned long;

using I8  = char;
using I16 = short;
using I32 = long;

Q_DECLARE_METATYPE(EmuEventCxx);

class SimCore : public QObject
{
    Q_OBJECT
  public:
    /// Construct new simulator core instance, with given memory size \arg
    /// memSize
    explicit SimCore(ESize memSize, QObject* parent = nullptr);
    /// Get event at index \arg idx
    inline EmuEventCxx getEvent(int idx) { return events.at(idx); }
    /// Return size of the pysical memory
    inline int memSize() { return impl.get_mem_size(); }
    /// Get byte from the physical memory at address \arg addr
    inline EByte memGet(EPointer addr) { return impl.get_mem(addr); }
    /// Get number of stored events
    inline int getEventNum() const { return events.length(); }
    /// Add event \arg ev to full list of events
    inline void addEvent(const EmuEventCxx& ev) { events.append(ev); }

    /// Set byte \arg value at memory position \arg addr
    inline void memSet(EPointer addr, EByte value) {
        impl.set_mem(addr, value);
    }
    /// Compile program in \arg str, and load it starting from position
    /// \arg pos
    inline void compileAndLoad(
        const QString& str,
        int            pos [[maybe_unused]] = 0) {
        auto text = str.toStdString();
        impl.compile_and_load(text.data());
    }


  signals:
    /// Signal emitted on each memory write operation
    void memoryWrite(EmuEventCxx);
    /// Signal emutted on each memory read operation
    void memoryRead(EmuEventCxx);
    /// Emitted for every new item added to the event list. Integer
    /// parameter of the event stores index of newly created item.
    void newEvent(int);
    /// Require full memory reload from first to last cell
    void fullMemoryReload();

    void reg8Assigned(Reg8T, U8);
    void reg16Assigned(Reg16T, U16);
    void reg32Assigned(Reg32T, U32);
    void reg8Read(Reg8T, U8);
    void reg16Read(Reg16T, U16);
    void reg32Read(Reg32T, U32);

  public slots:
    void step();

  private:
    // NOTE order of declarations is important, logger must be initialized
    // first, and then implementation should have handle of the logger
    // object.
    EmuLoggerCxx         logger; /// Reference to the logger implementation
    QVector<EmuEventCxx> events; /// Full list of all events
    FullImplCxx impl; /// Reference to the full emulator implementation
};

#endif // SIMCORE_HPP
