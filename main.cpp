#include <QtGui/QApplication>
#include <QDeclarativeContext>
#include <QtDebug>
#include <QTranslator>
#include <QLocale>
#include <QFontDatabase>
#include "qmlapplicationviewer.h"
#include "qplatformdefs.h"
#if defined(Q_WS_MAEMO_5) || defined(MEEGO_EDITION_HARMATTAN)
#include <MLocale>
#include "shortcut.h"
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


        QStringList cmdline_args = QCoreApplication::arguments();
        qDebug() << cmdline_args;

    qDebug() << "Current locale: " << locale.name();
    translator.load(":/i18n/meegopas_" + locale.name() + ".qm");
    app.data()->setFont(newFont);
    app.data()->installTranslator(&translator);

    QDeclarativeContext *ctxt = viewer->rootContext();

    /*  */
    Shortcut sc;
    ctxt->setContextProperty("Shortcut", &sc);

    viewer->addImportPath(QLatin1String("qrc:/images/"));
    viewer->addImportPath(QLatin1String("qrc:/i18n/"));
    viewer->setSource(QUrl("qrc:/qml/main.qml"));
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
