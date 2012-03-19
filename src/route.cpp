#include <QDebug>
#include <QDeclarativeItem>
#include <QtGui>
#include <QtDeclarative>
#include "route.h"

Route::Route()
{
}

void Route::setContext(const QDeclarativeContext *ctxt) {
    root = ctxt;
}

void Route::route(const QString &name, const QString &coord)
{
    qDebug() << name << " " << coord;
    QFile file("/home/user/meegopas.log");
    if (!file.exists()){
        if ( file.open( QIODevice::ReadWrite|QIODevice::Append|QIODevice::Unbuffered ) ) {
            QTextStream stream( &file );
            stream.setCodec("UTF-8");
            stream << "arguments.at(i).toLocal8Bit().constData() << endl" << endl;
        }
    }

    emit newRoute(name, coord);
    return;
}
