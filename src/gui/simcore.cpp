#include "simcore.hpp"

void simcore_cb(EmuEvent event, void* data) {
    SimCore* sim = (SimCore*)data;
}

SimCore::SimCore(QObject* parent) : QObject{parent}, impl(EmuSetting{}, 0) {
    auto logger = impl.get_logger();
    haxsim_emu_logger_set_raw_hook_payload(&logger, simcore_cb, this);
}
