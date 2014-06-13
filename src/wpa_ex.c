/*
 *  Copyright 2014 LKC Technologies, Inc.
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *     http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

#include <err.h>
#include <errno.h>
#include <poll.h>
#include <stdint.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <sys/uio.h>
#include <unistd.h>

#include <arpa/inet.h>  // for htons and ntohs

#include "wpa_ctrl/wpa_ctrl.h"

//#define DEBUG
#ifdef DEBUG
#define debug(...) fprintf(stderr, __VA_ARGS__)
#else
#define debug(...)
#endif

#define BUFFER_SIZE 2048

static struct wpa_ctrl *ctrl = 0;
static size_t erl_buffer_ix = 0;
static char erl_buffer[BUFFER_SIZE];
static char wpa_buffer[BUFFER_SIZE];

static void send_to_erl(char *msg, size_t len)
{
    struct iovec iov[2];

    uint16_t be_len = htons(len);

    iov[0].iov_base = &be_len;
    iov[0].iov_len = sizeof(uint16_t);
    iov[1].iov_base = msg;
    iov[1].iov_len = len;

    for (;;) {
        ssize_t amount_written = writev(STDOUT_FILENO, iov, 2);
        if (amount_written < 0) {
            if (errno == EINTR)
                continue;
            err(EXIT_FAILURE, "writev");
        } else if ((size_t) amount_written != len + sizeof(uint16_t)) {
            errx(EXIT_FAILURE, "not enough bytes written");
        } else
            break;
    }
}

static void do_wpa_request(char *cmd, size_t len)
{
    size_t reply_len = sizeof(wpa_buffer);
    if (wpa_ctrl_request(ctrl, cmd, len, wpa_buffer, &reply_len, send_to_erl) < 0)
        err(EXIT_FAILURE, "wpa_ctrl_request");
    send_to_erl(wpa_buffer, reply_len);
}

static size_t try_dispatch()
{
    /* Check that we have a length field */
    if (erl_buffer_ix < sizeof(uint16_t))
        return 0;

    uint16_t be_len;
    memcpy(&be_len, erl_buffer, sizeof(uint16_t));
    size_t msglen = ntohs(be_len);
    if (msglen + sizeof(uint16_t) > sizeof(erl_buffer))
        errx(EXIT_FAILURE, "Message too long");

    /* Check whether we've received the entire message */
    if (msglen + sizeof(uint16_t) > erl_buffer_ix)
        return 0;

    do_wpa_request(erl_buffer + sizeof(uint16_t), msglen);

    return msglen + sizeof(uint16_t);
}

static void process_erl()
{
    debug("process_erl\n");
    ssize_t amount_read =
        read(STDIN_FILENO,
            erl_buffer + erl_buffer_ix,
            sizeof(erl_buffer) - erl_buffer_ix);

    if (amount_read < 0) {
        /* EINTR is ok to get if we were interrupted by a signal. */
        if (errno == EINTR)
            return;

        err(EXIT_FAILURE, "read");
    } else if (amount_read == 0) {
        /* EOF. Our Erlang process was terminated. */
        exit(EXIT_SUCCESS);
    }

    erl_buffer_ix += amount_read;
    for (;;) {
        size_t bytes_processed = try_dispatch();
        if (bytes_processed == 0) {
            /* Only have part of the command to process. */
            break;
        } else if (erl_buffer_ix > bytes_processed) {
            /* Processed the command, but there's another one. */
            memmove(erl_buffer, &erl_buffer[bytes_processed], erl_buffer_ix - bytes_processed);
            erl_buffer_ix -= bytes_processed;
        } else {
            /* Processed the whole buffer. */
            erl_buffer_ix = 0;
            break;
        }
    }
}

static void process_wpa()
{
    while (wpa_ctrl_pending(ctrl)) {
        size_t reply_len = sizeof(wpa_buffer);
        if (wpa_ctrl_recv(ctrl, wpa_buffer, &reply_len) < 0)
            err(EXIT_FAILURE, "wpa_ctrl_recv");

        send_to_erl(wpa_buffer, reply_len);
    }
}

int main(int argc, char *argv[])
{
    if (argc != 2)
        errx(EXIT_FAILURE, "%s <path to supplicant control pipe>", argv[0]);

    ctrl = wpa_ctrl_open(argv[1]);
    if (!ctrl)
        err(EXIT_FAILURE, "Couldn't open '%s'", argv[1]);

    if (wpa_ctrl_attach(ctrl) < 0)
        err(EXIT_FAILURE, "wpa_ctrl_attach");

    int wpa_fd = wpa_ctrl_get_fd(ctrl);

    for (;;) {
        struct pollfd fdset[2];

        fdset[0].fd = STDIN_FILENO;
        fdset[0].events = POLLIN;
        fdset[0].revents = 0;

        fdset[1].fd = wpa_fd;
        fdset[1].events = POLLIN;
        fdset[1].revents = 0;

        debug("waiting on poll\n");
        int rc = poll(fdset, 2, -1);
        if (rc < 0) {
            // Retry if EINTR
            if (errno == EINTR)
                continue;

            err(EXIT_FAILURE, "poll");
        }

        debug("poll: revents[0]=%08x, revents[1]=%08x\n", fdset[0].revents, fdset[1].revents);

        if (fdset[0].revents & (POLLIN | POLLHUP))
            process_erl();

        if (fdset[1].revents & POLLIN)
            process_wpa();
    }

    return 0;
}
