#include "simcore.hpp"
#include <QDebug>

void simcore_cb(EmuEvent event, void* data) {
    SimCore* sim = (SimCore*)data;
    auto     ev  = EmuEventCxx(event);
    using K      = EmuEventKind;
    switch (ev.get_kind()) {
        case K::EEK_GET_MEM16:
        case K::EEK_GET_MEM32:
        case K::EEK_GET_MEM8: {
            emit sim->memoryRead(ev);
            break;
        }

        case K::EEK_SET_MEM8:
        case K::EEK_SET_MEM16:
        case K::EEK_SET_MEM32: {
            emit sim->memoryWrite(ev);
            break;
        }

        case K::EEK_GET_REG8: {
            emit sim->reg8Read(Reg8T(ev.get_value8()), ev.get_addr());
            break;
        }

        case K::EEK_GET_REG16: {
            emit sim->reg16Read(Reg16T(ev.get_value16()), ev.get_addr());
            break;
        }

        case K::EEK_GET_REG32: {
            emit sim->reg32Read(Reg32T(ev.get_value32()), ev.get_addr());
            break;
        }

        case K::EEK_SET_REG8: {
            emit sim->reg8Assigned(Reg8T(ev.get_value8()), ev.get_addr());
            break;
        }

        case K::EEK_SET_REG16: {
            emit sim->reg16Assigned(
                Reg16T(ev.get_value16()), ev.get_addr());
            break;
        }

        case K::EEK_SET_REG32: {
            emit sim->reg32Assigned(
                Reg32T(ev.get_value32()), ev.get_addr());
            break;
        }

        default: {
        }
    }

    sim->addEvent(ev);
    qDebug() << "Created new event num" << sim->getEventNum();
    emit sim->newEvent(sim->getEventNum() - 1);
}

SimCore::SimCore(ESize memSize, QObject* parent)
    : QObject{parent}
    , logger(nullptr)
    , impl(EmuSetting{memSize}, logger.get_handle()) {
    auto logger = EmuLoggerCxx(impl.get_logger());
    logger.set_raw_hook_payload(simcore_cb, this);
}

void SimCore::step() { impl.step(); }
