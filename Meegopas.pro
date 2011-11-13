# Add more folders to ship with the application, here
harmattan_qml.source = qml/harmattan
harmattan_qml.target = qml
symbian_qml.source = qml/symbian
symbian_qml.target = qml
common_qml.source = qml/common
common_qml.target = qml
images.source = images
loc.source = i18n
fonts.source = fonts
DEPLOYMENTFOLDERS = common_qml images loc fonts

# Additional import path used to resolve QML modules in Creator's code model
QML_IMPORT_PATH = qml/common qml/symbian qml/harmattan qml

symbian {
    TARGET.UID3 = 0x2004bf5e
    DEPLOYMENTFOLDERS += symbian_qml
    # Smart Installer package's UID
    # This UID is from the protected range and therefore the package will
    # fail to install if self-signed. By default qmake uses the unprotected
    # range value if unprotected UID is defined for the application and
    # 0x2002CCCF value if protected UID is given to the application
    # DEPLOYMENT.installer_header = 0x2002CCCF
    DEPLOYMENT.installer_header = 0x200346DE 0x2002AC89 0x2001E61C 0x200267C2

    # Allow network access on Symbian
    TARGET.CAPABILITY += NetworkServices Location

    vendorinfo = \
    "%{\"JukkaNousiainen-EN\"}" \
    ":\"JukkaNousiainen\""

    my_deployment.pkg_prerules = vendorinfo

    CONFIG += qt-components
}

contains(MEEGO_EDITION, harmattan) {
    # add harmattan specific qml
    DEPLOYMENTFOLDERS += harmattan_qml

    # Speed up launching on MeeGo/Harmattan when using applauncherd daemon
    CONFIG += qdeclarative-boostable

    # for MLocale
    CONFIG += meegotouch

    OTHER_FILES += \
        qtc_packaging/debian_harmattan/rules \
        qtc_packaging/debian_harmattan/README \
        qtc_packaging/debian_harmattan/manifest.aegis \
        qtc_packaging/debian_harmattan/copyright \
        qtc_packaging/debian_harmattan/control \
        qtc_packaging/debian_harmattan/compat \
        qtc_packaging/debian_harmattan/changelog
}

simulator {
    DEPLOYMENTFOLDERS += symbian_qml
}

# If your application uses the Qt Mobility libraries, uncomment the following
# lines and add the respective components to the MOBILITY variable.
CONFIG += mobility
MOBILITY += location systeminfo

# The .cpp file which was generated for your project. Feel free to hack it.
SOURCES += main.cpp

# Please do not modify the following two lines. Required for deployment.
include(qmlapplicationviewer/qmlapplicationviewer.pri)
qtcAddDeployment()

TRANSLATIONS += meegopas_fi_FI.ts

