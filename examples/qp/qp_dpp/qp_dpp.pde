//////////////////////////////////////////////////////////////////////////////
// Product: DPP example
// Last Updated for Version: 4.2.04
// Date of the Last Update:  Jan 04, 2011
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
#include "dpp.h"
#include "bsp.h"

// Local-scope objects -------------------------------------------------------
static QEvent const *l_tableQueueSto[N_PHILO];
static QEvent const *l_philoQueueSto[N_PHILO][N_PHILO];
static QSubscrList   l_subscrSto[MAX_PUB_SIG];

static union SmallEvents {
    void   *e0;                                          // minimum event size
    uint8_t e1[sizeof(TableEvt)];
    // ... other event types to go into this pool
} l_smlPoolSto[2*N_PHILO];                 // storage for the small event pool

//............................................................................
void setup() {
    BSP_init();                                          // initialize the BSP

    QF::init();       // initialize the framework and the underlying RT kernel

                                                  // initialize event pools...
    QF::poolInit(l_smlPoolSto, sizeof(l_smlPoolSto), sizeof(l_smlPoolSto[0]));

    QF::psInit(l_subscrSto, Q_DIM(l_subscrSto));     // init publish-subscribe

                                                // start the active objects...
    uint8_t n;
    for (n = 0; n < N_PHILO; ++n) {
        AO_Philo[n]->start((uint8_t)(n + 1),
                    l_philoQueueSto[n], Q_DIM(l_philoQueueSto[n]),
                    (void *)0, 0);
    }
    AO_Table->start((uint8_t)(N_PHILO + 1),
                    l_tableQueueSto, Q_DIM(l_tableQueueSto),
                    (void *)0, 0);
}

//////////////////////////////////////////////////////////////////////////////
// NOTE: Do not define the loop() function, because this function is
// already defined in the QP port to Arduino
