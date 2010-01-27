/*
 * Copyright (C) 2008, Robert Oostenveld
 * F.C. Donders Centre for Cognitive Neuroimaging, Radboud University Nijmegen,
 * Kapittelweg 29, 6525 EN Nijmegen, The Netherlands
 *
 * $Log: not supported by cvs2svn $
 * Revision 1.3  2008/10/29 20:46:12  roboos
 * consistent use of open_connection and close_connection
 * there were some incorrect uses of close() that on windows did not actually close, resulting in the buffer running out of sockets/threads after prolonged use
 *
 * Revision 1.2  2008/07/09 13:34:21  roboos
 * small change in verbose output, using verbose=0|1
 *
 * Revision 1.1  2008/06/19 20:48:32  roboos
 * added support for flushing header, data and events
 *
 *
 */

#include "mex.h"
#include "matrix.h"
#include "buffer.h"

void buffer_flushdat(char *hostname, int port, mxArray *plhs[], const mxArray *prhs[])
{
	int server;
    int verbose = 0;

	message_t *request  = NULL;
	message_t *response = NULL;
	header_t  *header   = NULL;

	/* allocate the elements that will be used in the communication */
	request      = malloc(sizeof(message_t));
	request->def = malloc(sizeof(messagedef_t));
	request->buf = NULL;
	request->def->version = VERSION;
	request->def->command = FLUSH_DAT;
	request->def->bufsize = 0;

	/* open the TCP socket */
	if ((server = open_connection(hostname, port)) < 0) {
		mexErrMsgTxt("ERROR: failed to create socket\n");
	}

	if (verbose) print_request(request->def);
	clientrequest(server, request, &response);
	if (verbose) print_response(response->def);
	close_connection(server);

	if (response->def->command!=FLUSH_OK) {
		mexErrMsgTxt("ERROR: the buffer returned an error\n");
	}

	if (request) {
		FREE(request->def);
		FREE(request->buf);
		FREE(request);
	}
	if (response) {
		FREE(response->def);
		FREE(response->buf);
		FREE(response);
	}

	return;
}

