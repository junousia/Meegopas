#include <QCryptographicHash>
#include "shortcut.h"

Shortcut::Shortcut(QObject *parent) :
    QObject(parent)
{
}

int Shortcut::toggleShortcut(const QString &name, const QString &coord) {
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
                      "Icon=/usr/share/icons/hicolor/80x80/apps/MeegopasRoute80.png\n" << endl <<
                      "Exec=qdbus com.juknousi.meegopas /com/juknousi/meegopas route \"" << name << "\" " << coord << endl;

            return 1;
        } else {
            qDebug( "Could not create file" );
        }
    } else {
        if (file.remove()) return 2;
    }
    return 0;
}

bool Shortcut::checkIfExists(const QString &name){
    QCryptographicHash namehash(QCryptographicHash::Md4);
    namehash.addData(name.toUtf8());
    QFile file("/home/user/.local/share/applications/meegopas_" +
               QString(namehash.result().toHex())
               + ".desktop");
    return file.exists();
}

int Shortcut::toggleCyclingShortcut(const QString &name, const QString &coord) {
    QCryptographicHash namehash(QCryptographicHash::Md4);
    namehash.addData(name.toUtf8());
    QFile file("/home/user/.local/share/applications/meegopas_cycling_" + QString(namehash.result().toHex()) + ".desktop");
    if (!file.exists()){
        if ( file.open( QIODevice::WriteOnly ) ) {
            QTextStream stream( &file );
            stream.setCodec("UTF-8");
            stream << "[Desktop Entry]" << endl <<
                      "Version=1.0" << endl <<
                      "Type=Application" << endl <<
                      "Name=" << name << endl <<
                      "Icon=/usr/share/icons/hicolor/80x80/apps/MeegopasCycling80.png\n" << endl <<
                      "Exec=qdbus com.juknousi.meegopas /com/juknousi/meegopas cycling \"" << name << "\" " << coord << endl;

            return 1;
        } else {
            qDebug( "Could not create file" );
        }
    } else {
        if (file.remove()) return 2;
    }
    return 0;
}

bool Shortcut::checkIfCyclingExists(const QString &name){
    QCryptographicHash namehash(QCryptographicHash::Md4);
    namehash.addData(name.toUtf8());
    QFile file("/home/user/.local/share/applications/meegopas_cycling_" +
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

void Shortcut::removeCyclingShortcut(const QString &name) {
    QCryptographicHash namehash(QCryptographicHash::Md4);
    namehash.addData(name.toUtf8());
    QFile file("/home/user/.local/share/applications/meegopas_cycling_" + QString(namehash.result().toHex()) + ".desktop");
    if(file.exists()){
        file.remove();
    }
}
