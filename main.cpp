#include <QtGui/QApplication>
#include <QtDebug>
#include <QTranslator>
#include <QLocale>
#ifdef Q_OS_LINUX
#include <MLocale>
#endif
#include "qmlapplicationviewer.h"

Q_DECL_EXPORT int main(int argc, char *argv[])
{
    QScopedPointer<QApplication> app(createApplication(argc, argv));
    QScopedPointer<QmlApplicationViewer> viewer(QmlApplicationViewer::create());

    QTranslator translator;
#ifndef Q_OS_LINUX
    qDebug() << "Current locale: " << QLocale::system().name();
    translator.load("i18n/meegopas_" + QLocale::system().name() + ".qm");
    viewer->setMainQmlFile(QLatin1String("qml/symbian/main.qml"));
#else
    MLocale locale;
    qDebug() << "Current locale: " << locale.name();
    translator.load("/opt/Meegopas/i18n/meegopas_" + locale.name() + ".qm");
    app.data()->installTranslator(&translator);
    viewer->setMainQmlFile(QLatin1String("qml/harmattan/main.qml"));
#endif

    viewer->setOrientation(QmlApplicationViewer::ScreenOrientationAuto);
    viewer->showExpanded();

    return app->exec();
}
