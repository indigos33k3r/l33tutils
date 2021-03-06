#!/bin/sh
# Pull APKs of installed applications from an android device.
# Expects package names on STDIN, e.g.:
#
# $ ./pull-apk.sh <<EOF
# com.android.vending
# com.google.android.apps.maps
# com.google.android.gms
# com.google.android.youtube
# de.srlabs.snoopsnitch
# edu.cmu.cylab.starslinger
# info.guardianproject.otr.app.im
# org.thoughtcrime.redphone
# org.thoughtcrime.securesms
# EOF
#
# You can then install these on another device with:
#
# $ adb install $local_apk_file # install new
# $ adb install -r $local_apk_file # upgrade existing
#
while read x; do echo "$x" "$(adb shell -n pm path "$x")"; done | \
sed -e 's/package://g' | tr -d '\r' | \
while read x p; do echo >&2 "pull $p"; adb pull "$p" "$x.apk"; done
