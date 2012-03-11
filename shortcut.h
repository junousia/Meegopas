#ifndef SHORTCUT_H
#define SHORTCUT_H

#include <QObject>
#include <QDebug>
#include <QList>
#include <QFile>
#include <QTextStream>

class Shortcut : public QObject
{
    Q_OBJECT
public:
    Shortcut(QObject *parent = 0);

public slots:
    int toggleShortcut(const QString &name);
    bool checkIfExists(const QString &name);
    void removeShortcut(const QString &name);
};


#endif // SHORTCUT_H
