#include <QCryptographicHash>
#include "shortcut.h"

Shortcut::Shortcut(QObject *parent) :
    QObject(parent)
{
}

int Shortcut::toggleShortcut(const QString &name) {
    QCryptographicHash namehash(QCryptographicHash::Md4);
    namehash.addData(name.toUtf8());
    QFile file("/home/user/.local/share/applications/meegopas_" + QString(namehash.result().toHex()) + ".desktop");
    if (!file.exists()){
        if ( file.open( QIODevice::WriteOnly ) ) {
            QTextStream stream( &file );
            stream.setCodec("UTF-8");
            stream << "[Desktop Entry]" << endl <<
                      "Version=1.0" << endl <<
                      "Type=Application" << endl <<
                      "Name=" << name << endl <<
                      "Exec=/usr/bin/invoker --single-instance --splash=/usr/share/Meegopas/splash-l.png --type=d /opt/Meegopas/bin/Meegopas" << endl <<
                      "Icon=/usr/share/icons/hicolor/80x80/apps/Meegopas80.png\n" << endl <<
                      "X-Window-Icon=" << endl <<
                      "X-HildonDesk-ShowInToolbar=true" << endl <<
                      "X-Osso-Type=application/x-executable" << endl <<
                      "X-Maemo-Service=" << endl <<
                      "X-Maemo-Fixed-Args=parametri" << endl <<
                      "X-Maemo-Method=com.my.interface.Method" << endl;
            return 1;
        } else {
            qDebug( "Could not create file" );
        }
    } else {
        if (file.remove()) return 2;
    }
}

bool Shortcut::checkIfExists(const QString &name){
    QCryptographicHash namehash(QCryptographicHash::Md4);
    namehash.addData(name.toUtf8());
    QFile file("/home/user/.local/share/applications/meegopas_" +
               QString(namehash.result().toHex())
               + ".desktop");
    return file.exists();
}

void Shortcut::removeShortcut(const QString &name) {
    QCryptographicHash namehash(QCryptographicHash::Md4);
    namehash.addData(name.toUtf8());
    QFile file("/home/user/.local/share/applications/meegopas_" + QString(namehash.result().toHex()) + ".desktop");
    if(file.exists()){
        file.remove();
    }
}
