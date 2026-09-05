#!/system/bin/sh
# SysUtils — customize.sh
# Runs during Magisk module installation. Detects Android API and installs
# the correct dmctl binary for this device.

SKIPUNZIP=0

SDK=$(getprop ro.build.version.sdk)
ui_print "- SysUtils: detected API level $SDK"

if [ "$SDK" -ge 35 ]; then
    DMCTL_SRC="META-INF/dmctl/dmctl_android35"
    ui_print "- Installing dmctl for API 35+"
elif [ "$SDK" -ge 34 ]; then
    DMCTL_SRC="META-INF/dmctl/dmctl_android34"
    ui_print "- Installing dmctl for API 34"
elif [ "$SDK" -ge 33 ]; then
    DMCTL_SRC="META-INF/dmctl/dmctl_android33"
    ui_print "- Installing dmctl for API 33"
else
    ui_print "- API $SDK < 33: skipping dmctl (unsupported)"
    DMCTL_SRC=""
fi

if [ -n "$DMCTL_SRC" ]; then
    unzip -o "$ZIPFILE" "$DMCTL_SRC" -d "$TMPDIR"
    cp "$TMPDIR/$DMCTL_SRC" "$MODPATH/system/xbin/dmctl"
    set_perm "$MODPATH/system/xbin/dmctl" root root 0755
fi

set_perm_recursive "$MODPATH/system/xbin" root root 0755 0755
ui_print "- SysUtils: 74 utilities installed to /system/xbin"
