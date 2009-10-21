/*
 * Copyright (C) 2008, Christian Hesse & Robert Oostenveld
 * F.C. Donders Centre for Cognitive Neuroimaging, Radboud University Nijmegen,
 * Kapittelweg 29, 6525 EN Nijmegen, The Netherlands
 *
 * $Log: not supported by cvs2svn $
 * Revision 1.2  2009/01/23 17:49:56  roboos
 * removed some unnecessary code
 *
 * Revision 1.1  2008/07/09 10:08:25  roboos
 * renamed the various demo applications into demo_xxx
 *
 * Revision 1.1  2008/07/08 18:42:08  release
 * moved files from core source directory to test
 *
 * Revision 1.7  2008/05/29 07:55:00  roboos
 * moved checks for the packing of structs and wordsize to seperate function
 *
 * Revision 1.6  2008/05/22 13:37:28  roboos
 * some small changes to make it compile with borland
 *
 * Revision 1.5  2008/03/13 13:35:24  roboos
 * use varargin for hostname and port, or use defaults
 *
 * Revision 1.4  2008/03/13 12:32:55  thohar
 * added headers for win32 build
 *
 * Revision 1.3  2008/03/10 10:04:57  roboos
 * use host argument in making threads
 *
 * Revision 1.2  2008/03/08 10:33:48  roboos
 * changed some code to reflect the renamed low-level functions, no functional changes
 *
 * Revision 1.1  2008/02/19 20:15:27  roboos
 * implemented standalone functions, easier in debugging and to show the flexibility
 *
 *
 */

#include <stdio.h>
#include <stdlib.h>
#include <time.h>

#include "message.h"
#include "buffer.h"
#include "unix_includes.h"
#include "socket_includes.h"

int main(int argc, char *argv[]) {
	host_t host;

    /* verify that all datatypes have the expected syze in bytes */
    check_datatypes();

	if (argc>2) {
		sprintf(host.name, argv[1]);
		host.port = atoi(argv[2]);
	}
	else {
		sprintf(host.name, DEFAULT_HOSTNAME);
		host.port = DEFAULT_PORT;
	}

	/* start the buffer */
	tcpserver((void *)(&host));

	return 0;
}

