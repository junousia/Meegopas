#include <QtGui/QApplication>
#include <QtDebug>
#include <QTranslator>
#include <QLocale>
#ifdef Q_OS_SYMBIAN
#else
#include <MLocale>
#endif
#include "qmlapplicationviewer.h"

Q_DECL_EXPORT int main(int argc, char *argv[])
{
    QScopedPointer<QApplication> app(createApplication(argc, argv));
    QScopedPointer<QmlApplicationViewer> viewer(QmlApplicationViewer::create());

    QTranslator translator;
#ifdef Q_OS_SYMBIAN
    viewer->setMainQmlFile(QLatin1String("qml/symbian/main.qml"));
#else
    MLocale locale;
    qDebug() << "Current locale: " << locale.name();
    translator.load("/opt/Meegopas/i18n/meegopas_" + locale.name() + ".qm");
    viewer->setMainQmlFile(QLatin1String("qml/harmattan/main.qml"));
    app.data()->installTranslator(&translator);
#endif

    viewer->setOrientation(QmlApplicationViewer::ScreenOrientationAuto);
    viewer->showExpanded();

    return app->exec();
}
