#include "simcore.hpp"

void simcore_cb(EmuEvent event, void* data) {
    SimCore* sim = (SimCore*)data;
}

SimCore::SimCore(QObject* parent)
    : QObject{parent}
    , logger(nullptr)
    , impl(EmuSetting{}, logger.get_handle()) {
    auto logger = EmuLoggerCxx(impl.get_logger());
    logger.set_raw_hook_payload(simcore_cb, this);
}
