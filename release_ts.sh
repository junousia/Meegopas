#!/bin/bash
cp i18n/meegopas_fi_FI.ts i18n/meegopas_fi_FI.ts.backup
cat i18n/meegopas_fi_FI.ts.backup | sed -e 's/..\/qml\/common/..\/qml/g' | sed -e 's/..\/qml\/harmattan/..\/qml/g' | sed -e 's/..\/qml\/symbian/..\/qml/g' > i18n/meegopas_fi_FI.ts
cat i18n/meegopas_fi_FI.ts
~/QtSDK/Desktop/Qt/474/gcc/bin/lrelease i18n/meegopas_fi_FI.ts
cp i18n/meegopas_fi_FI.ts.backup i18n/meegopas_fi_FI.ts
