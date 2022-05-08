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

        default: {
        }
    }

    sim->addEvent(ev);
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
