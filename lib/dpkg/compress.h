/*
 * libdpkg - Debian packaging suite library routines
 * compress.h - compression support functions
 *
 * Copyright © 2004 Scott James Remnant <scott@netsplit.com>
 * Copyright © 2006-2009 Guillem Jover <guillem@debian.org>
 *
 * This is free software; you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation; either version 2 of the License, or
 * (at your option) any later version.
 *
 * This is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with this program.  If not, see <http://www.gnu.org/licenses/>.
 */

#ifndef LIBDPKG_COMPRESS_H
#define LIBDPKG_COMPRESS_H

#include <dpkg/macros.h>

DPKG_BEGIN_DECLS

#define GZIP		"gzip"
#define BZIP2		"bzip2"
#define LZMA		"lzma"

enum compress_type {
  compress_type_none,
  compress_type_gzip,
  compress_type_bzip2,
  compress_type_lzma,
};

void decompress_filter(enum compress_type type, int fd_in, int fd_out,
                       const char *desc, ...) DPKG_ATTR_NORET
                       DPKG_ATTR_PRINTF(4);
void compress_filter(enum compress_type type, int fd_in, int fd_out,
                     const char *compression, const char *desc, ...)
                     DPKG_ATTR_NORET DPKG_ATTR_PRINTF(5);

DPKG_END_DECLS

#endif /* LIBDPKG_COMPRESS_H */
