#include <QtGui/QApplication>
#include <QtDebug>
#include <QTranslator>
#include <QLocale>
#include "qmlapplicationviewer.h"

Q_DECL_EXPORT int main(int argc, char *argv[])
{
    QScopedPointer<QApplication> app(createApplication(argc, argv));
    QScopedPointer<QmlApplicationViewer> viewer(QmlApplicationViewer::create());

    QTranslator translator;

    qDebug() << "Current locale: " << QLocale::system().name();
    translator.load("/opt/Meegopas/i18n/meegopas_" + QLocale::system().name() + ".qm");
    app.data()->installTranslator(&translator);

    viewer->setOrientation(QmlApplicationViewer::ScreenOrientationAuto);
    viewer->setMainQmlFile(QLatin1String("qml/Meegopas/main.qml"));
    viewer->showExpanded();

    return app->exec();
}
