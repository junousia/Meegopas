#include <QtGui/QApplication>
#include <QtDebug>
#include <QTranslator>
#include <QLocale>
#include <QFontDatabase>
#if defined(Q_WS_MAEMO_5) || defined(Q_WS_MAEMO_6) || defined(Q_OS_LINUX)
#include <MLocale>
#endif
#include "qmlapplicationviewer.h"

Q_DECL_EXPORT int main(int argc, char *argv[])
{
    QScopedPointer<QApplication> app(createApplication(argc, argv));
    QScopedPointer<QmlApplicationViewer> viewer(QmlApplicationViewer::create());
    QFontDatabase::addApplicationFont("fonts/nokia_pure.ttf");

    QTranslator translator;
#if defined(Q_WS_MAEMO_5) || defined(Q_WS_MAEMO_6) || defined(Q_OS_LINUX)
    QFont newFont;
    newFont.setFamily("Nokia Pure Text Light");
    newFont.setWeight(QFont::Light);
    MLocale locale;
    qDebug() << "Current locale: " << locale.name();
    translator.load("/opt/Meegopas/i18n/meegopas_" + locale.name() + ".qm");
    app.data()->setFont(newFont);
    app.data()->installTranslator(&translator);
    viewer->setMainQmlFile(QLatin1String("qml/harmattan/main.qml"));
#else
    QFont newFont;
    newFont.setFamily("Nokia Pure Text");
    newFont.setWeight(QFont::Light);
    newFont.setStyleStrategy(QFont::PreferAntialias);
    qDebug() << "Current locale: " << "i18n/meegopas_" + QLocale::system().name() + ".qm";
    translator.load("i18n/meegopas_" + QLocale::system().name());
    app.data()->installTranslator(&translator);
    app.data()->setFont(newFont);
    viewer->setMainQmlFile(QLatin1String("qml/symbian/main.qml"));
#endif

    viewer->setOrientation(QmlApplicationViewer::ScreenOrientationAuto);
    viewer->showExpanded();

    return app->exec();
}
