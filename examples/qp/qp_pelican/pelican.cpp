//////////////////////////////////////////////////////////////////////////////
// Product: PELICAN crossing example
// Last Updated for Version: 4.2.04
// Date of the Last Update:  Sep 26, 2011
//
//                    Q u a n t u m     L e a P s
//                    ---------------------------
//                    innovating embedded systems
//
// Copyright (C) 2002-2011 Quantum Leaps, LLC. All rights reserved.
//
// This software may be distributed and modified under the terms of the GNU
// General Public License version 2 (GPL) as published by the Free Software
// Foundation and appearing in the file GPL.TXT included in the packaging of
// this file. Please note that GPL Section 2[b] requires that all works based
// on this software must also be made publicly available under the terms of
// the GPL ("Copyleft").
//
// Alternatively, this software may be distributed and modified under the
// terms of Quantum Leaps commercial licenses, which expressly supersede
// the GPL and are specifically designed for licensees interested in
// retaining the proprietary status of their code.
//
// Contact information:
// Quantum Leaps Web site:  http://www.quantum-leaps.com
// e-mail:                  info@quantum-leaps.com
//////////////////////////////////////////////////////////////////////////////
#include "qp_port.h"
#include "bsp.h"
#include "pelican.h"

Q_DEFINE_THIS_FILE

// Pelican class -------------------------------------------------------------
class Pelican : public QActive {                       // derived from QActive
    QTimeEvt m_timeout;                     // time event to generate timeouts
    uint8_t  m_flashCtr;                           // pedestrian flash counter

public:
    Pelican();

private:
    static QState initial         (Pelican *me, QEvent const *e);
    static QState offline         (Pelican *me, QEvent const *e);
    static QState operational     (Pelican *me, QEvent const *e);
    static QState carsEnabled     (Pelican *me, QEvent const *e);
    static QState carsGreen       (Pelican *me, QEvent const *e);
    static QState carsGreenNoPed  (Pelican *me, QEvent const *e);
    static QState carsGreenPedWait(Pelican *me, QEvent const *e);
    static QState carsGreenInt    (Pelican *me, QEvent const *e);
    static QState carsYellow      (Pelican *me, QEvent const *e);
    static QState pedsEnabled     (Pelican *me, QEvent const *e);
    static QState pedsWalk        (Pelican *me, QEvent const *e);
    static QState pedsFlash       (Pelican *me, QEvent const *e);
};

enum PelicanTimeouts {                            // various timeouts in ticks
    CARS_GREEN_MIN_TOUT = BSP_TICKS_PER_SEC * 8,         // min green for cars
    CARS_YELLOW_TOUT = BSP_TICKS_PER_SEC * 3,               // yellow for cars
    PEDS_WALK_TOUT   = BSP_TICKS_PER_SEC * 3,         // walking time for peds
    PEDS_FLASH_TOUT  = BSP_TICKS_PER_SEC / 5,     // flashing timeout for peds
    PEDS_FLASH_NUM   = 5*2,                      // number of flashes for peds
    OFF_FLASH_TOUT   = BSP_TICKS_PER_SEC / 2      // flashing timeout when off
};

// Local objects -------------------------------------------------------------
static Pelican l_Pelican;      // the single instance of Pelican active object

// Global objects ------------------------------------------------------------
QActive * const AO_Pelican = &l_Pelican;                 // the opaque pointer

//............................................................................
Pelican::Pelican()
 : QActive((QStateHandler)&Pelican::initial),
   m_timeout(TIMEOUT_SIG)
{}

// HSM definition ------------------------------------------------------------
QState Pelican::initial(Pelican *me, QEvent const *e) {
    me->subscribe(PEDS_WAITING_SIG);

    return Q_TRAN(&Pelican::operational);
}
//............................................................................
QState Pelican::operational(Pelican *me, QEvent const *e) {
    switch (e->sig) {
        case Q_ENTRY_SIG: {
            BSP_signalCars(CARS_RED);
            BSP_signalPeds(PEDS_DONT_WALK);
            return Q_HANDLED();
        }
        case Q_INIT_SIG: {
            return Q_TRAN(&Pelican::carsEnabled);
        }
        case OFF_SIG: {
            return Q_TRAN(&Pelican::offline);
        }
        // uncomment this case to test assertion failure...
        /*
        case ON_SIG: {
            Q_ERROR();
            return Q_HANDLED();
        }
        */
    }
    return Q_SUPER(&QHsm::top);
}
//............................................................................
QState Pelican::carsEnabled(Pelican *me, QEvent const *e) {
    switch (e->sig) {
        case Q_EXIT_SIG: {
            BSP_signalCars(CARS_RED);
            return Q_HANDLED();
        }
        case Q_INIT_SIG: {
            return Q_TRAN(&Pelican::carsGreen);
        }
    }
    return Q_SUPER(&Pelican::operational);
}
//............................................................................
QState Pelican::carsGreen(Pelican *me, QEvent const *e) {
    switch (e->sig) {
        case Q_ENTRY_SIG: {
            BSP_signalCars(CARS_GREEN);
            me->m_timeout.postIn(me, CARS_GREEN_MIN_TOUT);
            return Q_HANDLED();
        }
        case Q_EXIT_SIG: {
            me->m_timeout.disarm();
            return Q_HANDLED();
        }
        case Q_INIT_SIG: {
            return Q_TRAN(&Pelican::carsGreenNoPed);
        }
    }
    return Q_SUPER(&Pelican::carsEnabled);
}
//............................................................................
QState Pelican::carsGreenNoPed(Pelican *me, QEvent const *e) {
    switch (e->sig) {
        case Q_ENTRY_SIG: {
            BSP_showState("carsGreenNoPed");
            return Q_HANDLED();
        }
        case PEDS_WAITING_SIG: {
            return Q_TRAN(&Pelican::carsGreenPedWait);
        }
        case TIMEOUT_SIG: {
            return Q_TRAN(&Pelican::carsGreenInt);
        }
    }
    return Q_SUPER(&Pelican::carsGreen);
}
//............................................................................
QState Pelican::carsGreenPedWait(Pelican *me, QEvent const *e) {
    switch (e->sig) {
        case Q_ENTRY_SIG: {
            BSP_showState("carsGreenPedWait");
            return Q_HANDLED();
        }
        case TIMEOUT_SIG: {
            return Q_TRAN(&Pelican::carsYellow);
        }
    }
    return Q_SUPER(&Pelican::carsGreen);
}
//............................................................................
QState Pelican::carsGreenInt(Pelican *me, QEvent const *e) {
    switch (e->sig) {
        case Q_ENTRY_SIG: {
            BSP_showState("carsGreenInt");
            return Q_HANDLED();
        }
        case PEDS_WAITING_SIG: {
            return Q_TRAN(&Pelican::carsYellow);
        }
    }
    return Q_SUPER(&Pelican::carsGreen);
}
//............................................................................
QState Pelican::carsYellow(Pelican *me, QEvent const *e) {
    switch (e->sig) {
        case Q_ENTRY_SIG: {
            BSP_showState("carsYellow");
            BSP_signalCars(CARS_YELLOW);
            me->m_timeout.postIn(me, CARS_YELLOW_TOUT);
            return Q_HANDLED();
        }
        case Q_EXIT_SIG: {
            me->m_timeout.disarm();
            return Q_HANDLED();
        }
        case TIMEOUT_SIG: {
            return Q_TRAN(&Pelican::pedsEnabled);
        }
    }
    return Q_SUPER(&Pelican::carsEnabled);
}
//............................................................................
QState Pelican::pedsEnabled(Pelican *me, QEvent const *e) {
    switch (e->sig) {
        case Q_EXIT_SIG: {
            BSP_signalPeds(PEDS_DONT_WALK);
            return Q_HANDLED();
        }
        case Q_INIT_SIG: {
            return Q_TRAN(&Pelican::pedsWalk);
        }
    }
    return Q_SUPER(&Pelican::operational);
}
//............................................................................
QState Pelican::pedsWalk(Pelican *me, QEvent const *e) {
    switch (e->sig) {
        case Q_ENTRY_SIG: {
            BSP_showState("pedsWalk");
            BSP_signalPeds(PEDS_WALK);
            me->m_timeout.postIn(me, PEDS_WALK_TOUT);
            return Q_HANDLED();
        }
        case Q_EXIT_SIG: {
            me->m_timeout.disarm();
            return Q_HANDLED();
        }
        case TIMEOUT_SIG: {
            return Q_TRAN(&Pelican::pedsFlash);
        }
    }
    return Q_SUPER(&Pelican::pedsEnabled);
}
//............................................................................
QState Pelican::pedsFlash(Pelican *me, QEvent const *e) {
    switch (e->sig) {
        case Q_ENTRY_SIG: {
            BSP_showState("pedsWalk");
            me->m_timeout.postEvery(me, PEDS_FLASH_TOUT);
            me->m_flashCtr = PEDS_FLASH_NUM*2 + 1;
            return Q_HANDLED();
        }
        case Q_EXIT_SIG: {
            me->m_timeout.disarm();
            return Q_HANDLED();
        }
        case TIMEOUT_SIG: {
            if (me->m_flashCtr != 0) {                      // still flashing?
                if ((me->m_flashCtr & 1) == 0) {              // even counter?
                    BSP_signalPeds(PEDS_DONT_WALK);
                }
                else {                                  // must be odd counter
                    BSP_signalPeds(PEDS_BLANK);
               }
                --me->m_flashCtr;
            }
            else {                                            // done flashing
                return Q_TRAN(&Pelican::carsEnabled);
            }
            return Q_HANDLED();
        }
    }
    return Q_SUPER(&Pelican::pedsEnabled);
}
//............................................................................
QState Pelican::offline(Pelican *me, QEvent const *e) {
    switch (e->sig) {
        case Q_ENTRY_SIG: {
            BSP_showState("offline");
            me->m_timeout.postEvery(me, OFF_FLASH_TOUT);
            me->m_flashCtr = 0;
            return Q_HANDLED();
        }
        case Q_EXIT_SIG: {
            me->m_timeout.disarm();
            return Q_HANDLED();
        }
        case TIMEOUT_SIG: {
            if ((me->m_flashCtr & 1) == 0) {                  // even counter?
                BSP_signalCars(CARS_RED);
                BSP_signalPeds(PEDS_DONT_WALK);
            }
            else {
                BSP_signalCars(CARS_BLANK);
                BSP_signalPeds(PEDS_BLANK);
            }
            me->m_flashCtr ^= 1;                   // toggle the flash counter
            return Q_HANDLED();
        }
        case ON_SIG: {
            return Q_TRAN(&Pelican::operational);
        }
    }
    return Q_SUPER(&QHsm::top);
}
