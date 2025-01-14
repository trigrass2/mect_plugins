/**
 * @file
 *
 * @section LICENSE
 * Copyright Mect s.r.l. 2013
 *
 * @brief HMI Main function
 */
#include <QApplication>
#include <getopt.h>
#include <sys/time.h>
#include <sys/resource.h>
#include <unistd.h>

#include <stdio.h>
#include <stdlib.h>
#include <signal.h>
#ifdef FORCE_CORE_UNLIMITED
#include <sys/resource.h>
#endif
#include "pthread.h"

#include <QString>
#include <QFile>
#include <QDebug>

#include "main.h"
#include "app_logprint.h"
#include "page0.h"

#include "hmi_plc.h"

/* Long options */
static struct option long_options[] = {
    {"version", no_argument,        NULL, 'v'},
    {"qt", no_argument,        NULL, 'q'},
    {"qt", no_argument,        NULL, 'w'},
    {"qt", no_argument,        NULL, 's'},
    {"qt", no_argument,        NULL, 'd'},
    {"qt", no_argument,        NULL, 'i'},
    {"qt", no_argument,        NULL, 'p'},
    {"qt", no_argument,        NULL, 'l'},
    {"qt", no_argument,        NULL, 'a'},
    {"qt", no_argument,        NULL, 'y'},
    {NULL,      no_argument,        NULL,  0}
};

/*
 * Short options.
 * FIXME: KEEP THEIR LETTERS IN SYNC WITH THE RETURN VALUE
 * FROM THE LONG OPTIONS!
 */
static char short_options[] = "vqwsdiplay";

static int application_options(int argc, char *argv[])
{
    int option_index = 0;
    int c = 0;
    
    if (argc <= 0)
        return 0;
    
    if (argv == NULL)
        return 1;
    
    while ((c = getopt_long(argc, argv, short_options, long_options, &option_index)) != -1) {
        switch (c) {
        case 'v':
            printf("mect_plugins version: %d.%d.%d\n", MECT_BUILD_MAJOR, MECT_BUILD_MINOR, MECT_BUILD_BUILD);
            exit(0);
            break;
        default:
            break;
        }
    }
    
    return 0;
}

#undef DO_FILTER_SIGNALS

#ifdef DO_FILTER_SIGNALS
// Define the function to be called when ctrl-c (SIGINT) signal is sent to process
void
signal_callback_handler(int signum)
{
    struct sigaction new_action;

    fprintf(stderr, "Caught signal %d\n",signum);
    fflush(stderr);

    /* TODO: Cleanup and close up stuff here */

    /* Forward the signal */
    new_action.sa_flags = 0;
    sigemptyset (&new_action.sa_mask);
    new_action.sa_handler = SIG_DFL;

    sigaction(signum, &new_action, NULL);

    raise(signum);
}
#endif

/**
 * @brief main
 */
int main(int argc, char *argv[])
{
#ifdef FORCE_CORE_UNLIMITED
    struct rlimit core_limits;
    // core dumps may be disallowed by parent of this process; change that
    fprintf(stderr, "set core limit as unlimited\n");
    core_limits.rlim_cur = core_limits.rlim_max = RLIM_INFINITY;
    setrlimit(RLIMIT_CORE, &core_limits);
#endif

    /* parse the command line option */
    if (application_options(argc, argv) != 0) {
        LOG_PRINT(error_e, "%s: command line option error.\n", __func__);
        return 1;
    }
    LOG_PRINT_NO_INFO(info_e, "Version: %d.%d.%d\n", MECT_BUILD_MAJOR, MECT_BUILD_MINOR, MECT_BUILD_BUILD);
    
#ifdef DO_FILTER_SIGNALS
    /* Register signal and signal handler */
    for (int i = 0; i < _NSIG; i++)
    {
        signal(i, signal_callback_handler);
    }
#endif
    pthread_mutex_init(&datasync_send_mutex, NULL);
    pthread_mutex_init(&datasync_recv_mutex, NULL);

    pthread_condattr_t attr;
    pthread_condattr_init(&attr);
    pthread_condattr_setclock(&attr, CLOCK_MONOTONIC);
    pthread_cond_init(&theWritingCondvar, &attr);
    pthread_mutex_init(&theWritingMutex, NULL);

    pthread_mutex_init(&alarmevents_list_mutex, NULL);


    /* instantiate the GUI application object */
    // multi: transformed:linuxfb:rot270:mmHeight=152:mmWidth=91:0 vnc:qvfb:size=480x800:0

    char vncDisplay[128];
    printVncDisplayString(vncDisplay);

    int myargc = 4;
    char *myargv[] =
    {
        argv[0],
        strdup("-qws"),
        strdup("-display"),
        vncDisplay
    };

    QApplication app(myargc, myargv);

    // Loading Application QSS
    QFile fileQSS("/local/root/hmi.qss");
    if (fileQSS.exists())  {
        fileQSS.open(QFile::ReadOnly);
        QString styleSheet = QString(fileQSS.readAll());
        fileQSS.close();
        app.setStyleSheet(styleSheet);
        qDebug("Loaded hmi.qss");
    }


    /* load the library icons */
    Q_INIT_RESOURCE(atcmicons);
    Q_INIT_RESOURCE(libicons);

    /* initialize the application (load configurations and start threads) */
    initialize();

    /* start page 0 (the splash screen) */
    page0 w;
    w.SHOW();
    w.reload();
    
    /* start the buzzer event filter */
    app.installEventFilter(new MyEventFilter());
    
    /* start the GUI application */
    app.exec();
    
    /* finalize the application (stop threads) */
    finalize();

    return 0;
}
