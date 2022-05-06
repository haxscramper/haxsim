#include "simcore.hpp"
#include <QDebug>

void simcore_cb(EmuEvent event, void* data) {
    SimCore* sim = (SimCore*)data;
    auto     ev  = EmuEventCxx(event);
    qDebug() << haxsim_emu_event_kind_to_string(ev.get_kind());
    switch (ev.get_kind()) {
        default: {
        }
    }
}

SimCore::SimCore(QObject* parent)
    : QObject{parent}
    , logger(nullptr)
    , impl(EmuSetting{}, logger.get_handle()) {
    auto logger = EmuLoggerCxx(impl.get_logger());
    logger.set_raw_hook_payload(simcore_cb, this);
}
