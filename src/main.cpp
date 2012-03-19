#include <QtGui/QApplication>
#include <QDeclarativeContext>
#include <QtDebug>
#include <QTranslator>
#include <QLocale>
#include <QFontDatabase>
#include <QtDBus/QtDBus>
#include "qmlapplicationviewer.h"
#include "qplatformdefs.h"
#if defined(Q_WS_MAEMO_5) || defined(MEEGO_EDITION_HARMATTAN)
#include <MLocale>
#include "shortcut.h"
#include "meegopasadaptor.h"
#endif

Q_DECL_EXPORT int main(int argc, char *argv[])
{
    QScopedPointer<QApplication> app(createApplication(argc, argv));
    QScopedPointer<QmlApplicationViewer> viewer(QmlApplicationViewer::create());

    QTranslator translator;
#if defined(Q_WS_MAEMO_5) || defined(MEEGO_EDITION_HARMATTAN)
    QFont newFont;
    newFont.setFamily("Nokia Pure Text Light");
    newFont.setWeight(QFont::Light);
    MLocale locale;
    qDebug() << "Current locale: " << locale.name();
    translator.load(":/i18n/meegopas_" + locale.name() + ".qm");
    app.data()->setFont(newFont);
    app.data()->installTranslator(&translator);

    QDeclarativeContext *ctxt = viewer->rootContext();

    /* set shortcut to app */
    Shortcut sc;
    ctxt->setContextProperty("Shortcut", &sc);

    viewer->addImportPath(QLatin1String("qrc:/images/"));
    viewer->addImportPath(QLatin1String("qrc:/i18n/"));

    /* publish viewer class to QML */
    ctxt->setContextProperty("QmlApplicationViewer", &(*viewer));

    /* set starting page */
    viewer->setSource(QUrl("qrc:/qml/main.qml"));

    /* register dbus interface */
    QDBusConnection bus = QDBusConnection::sessionBus();
    Route route;
    route.setContext(ctxt);
    new MeegopasAdaptor(&route);

    if(bus.registerService("com.juknousi.meegopas") == QDBusConnectionInterface::ServiceNotRegistered)
        qDebug() << "Registering DBus service failed";

    if(bus.registerObject("/com/juknousi/meegopas", &route) == false)
        qDebug() << "Registering DBus adaptor object failed";

    ctxt->setContextProperty("Route", &route);
#else
    QFont newFont;
    newFont.setFamily("Nokia Pure Text Light");
    newFont.setWeight(QFont::Light);
    newFont.setStyleStrategy(QFont::PreferAntialias);
    qDebug() << "Current locale: " << "qrc:/i18n/meegopas_" + QLocale::system().name() + ".qm";
    translator.load(":/i18n/meegopas_" + QLocale::system().name());
    app.data()->installTranslator(&translator);
    app.data()->setFont(newFont);
    viewer->addImportPath(QLatin1String("qrc:/images/"));
    viewer->addImportPath(QLatin1String("qrc:/i18n/"));
    viewer->setSource(QUrl("qrc:/qml/main.qml"));
#endif

    viewer->setOrientation(QmlApplicationViewer::ScreenOrientationAuto);
    viewer->showExpanded();
    return app->exec();
}
