#include <QtGui/QApplication>
#include <QtDebug>
#include <QTranslator>
#include <QLocale>
#if defined(Q_WS_MAEMO_5) || defined(Q_WS_MAEMO_6)
#include <MLocale>
#endif
#include "qmlapplicationviewer.h"

Q_DECL_EXPORT int main(int argc, char *argv[])
{
    QScopedPointer<QApplication> app(createApplication(argc, argv));
    QScopedPointer<QmlApplicationViewer> viewer(QmlApplicationViewer::create());

    QTranslator translator;
#if defined(Q_WS_MAEMO_5) || defined(Q_WS_MAEMO_6)
    MLocale locale;
    qDebug() << "Current locale: " << locale.name();
    translator.load("/opt/Meegopas/i18n/meegopas_" + locale.name() + ".qm");
    app.data()->installTranslator(&translator);
    viewer->setMainQmlFile(QLatin1String("qml/harmattan/main.qml"));
#else
    qDebug() << "Current locale: " << "i18n/meegopas_" + QLocale::system().name() + ".qm";
    translator.load("i18n/meegopas_" + QLocale::system().name());
    app.data()->installTranslator(&translator);
    viewer->setMainQmlFile(QLatin1String("qml/symbian/main.qml"));
#endif

    viewer->setOrientation(QmlApplicationViewer::ScreenOrientationAuto);
    viewer->showExpanded();

    return app->exec();
}
