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
    emit newRoute(name, coord);
    return;
}

void Route::cycling(const QString &name, const QString &coord)
{
    qDebug() << "cycling" << name << " " << coord;
    emit newCycling(name, coord);
    return;
}
