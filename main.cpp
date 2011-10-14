#include <QtGui/QApplication>
#include <QtDebug>
#include <QTranslator>
#include <QLocale>
#include <MLocale>
#include "qmlapplicationviewer.h"

Q_DECL_EXPORT int main(int argc, char *argv[])
{
    QScopedPointer<QApplication> app(createApplication(argc, argv));
    QScopedPointer<QmlApplicationViewer> viewer(QmlApplicationViewer::create());

    QTranslator translator;

    MLocale locale;
    qDebug() << "Current locale: " << locale.name();

    translator.load("/opt/Meegopas/i18n/meegopas_" + locale.name() + ".qm");
    app.data()->installTranslator(&translator);
    viewer->setOrientation(QmlApplicationViewer::ScreenOrientationAuto);
    viewer->setMainQmlFile(QLatin1String("qml/Meegopas/main.qml"));
    viewer->showExpanded();

    return app->exec();
}
