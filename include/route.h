#include <QObject>
#include <QString>
#include <QDeclarativeContext>

#ifndef ROUTE_H
#define ROUTE_H

class Route : public QObject
{
    Q_OBJECT
private:
    const QDeclarativeContext *root;

public:
    explicit Route();
    void setContext(const QDeclarativeContext *ctxt);
    void route(const QString &name, const QString &coord);
    void cycling(const QString &name, const QString &coord);
signals:
    void newRoute(const QString &name, const QString &coord);
    void newCycling(const QString &name, const QString &coord);
};

#endif // ROUTE_H
