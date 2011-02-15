/*!
!!!======
!!!======
!!!
!!! Routine- VMS.C by B. Coish             08-JUL-03 / ?INSTALL?
!!!
!!! Purpose-
!!!
!!!     Routines to handle various VMS specific functions.  
!!!     (E.g. Handling commandline wild card expansion)
!!!
!!! Make-
!!!
!!!     LB VMS
!!!
!!! Index-
!!!
!!!     Ruby command line wild card expansion;
!!!
!!! Dymaxion Standard Version- 03
!!!
!!! Modifications-
!!!
!!!     08-JUL-03       BH / TH / TH   12=15647
!!!     - Created.
!!!
!!!     ?INSTALL?	BH /?WT?/?QA?  12=15647
!!!     - Fix infinite loop condition within VMSCmdGlob.
!!!
!!!======
!!!======
*/
#include "ruby.h"
#include "rubysig.h"
#include <fcntl.h>
#include <sys/stat.h>
#include <stdio.h>
#include <stdlib.h>
#include <errno.h>
#include <assert.h>
#include <socket.h>

#ifndef index
#define index(x, y) strchr((x), (y))
#endif
#define isdirsep(x) ((x) == '.')

#ifndef bool
#define bool int
#endif

#ifndef CharNext                /* defined as CharNext[AW] on Windows.*/
# if defined(DJGPP)
#   define CharNext(p) ((p) + mblen(p, MB_CUR_MAX))
# else
#   define CharNext(p) ((p) + 1)
# endif
#endif

extern VALUE rb_last_status;

typedef struct _VMSCmdLineElement {
    struct _VMSCmdLineElement *next, *prev;
    char *str;
    int len;
    int flags;
} VMSCmdLineElement;

void VMSInitialize(int *argc, char ***argv);
static void insert(const char *path, VALUE vinfo);
void VMSFreeCmdLine(void);
void VMSCmdGlob (VMSCmdLineElement *patt);
int VMSMakeCmdVector (char *cmdline, char ***vec, int InputCmd);
char* getCommandLine(int argc, char**argv);

/*!
   Pupose-
	Perform VMS command line wild card expansion.
   
   Inputs-
      	argc
 	- Address of the number of arguments in argv.
      	argv
        - Address of a two dimensional array of strings
          containing commandline args.
   
   Outputs-
	argc
        - New count of arguments in argv.
      	argv
        - New list of arguments (with wild card expansion)

   Notes-
	This routine should be called before the command line
        arguments are used.

*/
void VMSInitialize(int *argc, char ***argv)
{

   int ret;
   *argc = VMSMakeCmdVector(getCommandLine(*argc, *argv), argv, TRUE);
}


/*!
   Purpose-
	Flatten the specified commandline vector into a single string 
        for processing.

   Inputs-
	argc 	
        - Count of arguments in argv.
 	argv 	
        - Array of commandline arguments.

   Outputs-
	getCommandLine	 
        - The values contained in argv flattened into a single string; 
          NULL otherwise.

   Notes-
   	The returned string is dynamically allocated and must be
        freed.  
*/
char* getCommandLine(int argc, char**argv)
{
   char *buf=NULL, *temp=NULL;
   int arg_cnt = 0, adjsize=0;
   int quote=0;

   if(argc <= 0 || !argv) {
      return NULL;
   }

   arg_cnt = 0;
   buf = strdup(argv[arg_cnt++]);
   for(; (arg_cnt < argc); arg_cnt++) {
      adjsize=2;
      /* Check for previously quoted string */
      if(strchr(argv[arg_cnt],' ') != NULL){ 
         adjsize+=2; quote=1; 
      }
         
      temp = realloc(buf, strlen(buf)+strlen(argv[arg_cnt])+adjsize);
      if(!temp) return NULL;
      else buf = temp;

      if(!quote) {
         sprintf(buf,"%s %s",buf,argv[arg_cnt]);
      } else {
         sprintf(buf,"%s \"%s\"",buf,argv[arg_cnt]);
      }
   }
   return buf;
}


//
// Possible values for flags
//

#define VMSGLOB   0x1	// element contains a wildcard
#define VMSMALLOC 0x2	// string in element was malloc'ed

VMSCmdLineElement *VMSCmdHead = NULL, *VMSCmdTail = NULL;

/*!
   Purpose-
	Deallocates nodes associated with the commandline elements.
*/
void VMSFreeCmdLine(void)
{
    VMSCmdLineElement *ptr;
    
    while(VMSCmdHead) {
	ptr = VMSCmdHead;
	VMSCmdHead = VMSCmdHead->next;
	free(ptr);
    }
    VMSCmdHead = VMSCmdTail = NULL;
}

typedef struct {
    VMSCmdLineElement *head;
    VMSCmdLineElement *tail;
} ListInfo;

/*!
   Purpose-
	Adds a path value onto the end of the vinfo VMS command 
        line list.
   
   Inputs-
	path
        - value to be added into the commandline list.
	vinfo
        - A ListInfo type, information concerning the linked list
          commandline such as, start of list, end of list, etc..
*/
static void insert(const char *path, VALUE vinfo)
{
    VMSCmdLineElement *tmpcurr;
    ListInfo *listinfo = (ListInfo *)vinfo;

    tmpcurr = ALLOC(VMSCmdLineElement);
    MEMZERO(tmpcurr, VMSCmdLineElement, 1);
    tmpcurr->len = strlen(path);
    tmpcurr->str = ALLOC_N(char, tmpcurr->len + 1);
    tmpcurr->flags |= VMSMALLOC;
    strcpy(tmpcurr->str, path);
    if (listinfo->tail) {
	listinfo->tail->next = tmpcurr;
	tmpcurr->prev = listinfo->tail;
	listinfo->tail = tmpcurr;
    }
    else {
	listinfo->tail = listinfo->head = tmpcurr;
    }
}

#ifdef HAVE_SYS_PARAM_H
# include <sys/param.h>
#else
# define MAXPATHLEN 512
#endif

/*!
   Purpose-
	Takes a pattern and matches it to a list of files. (i.e. Glob)

   Inputs-
	patt 
        - VMSCmdLineElement containing a pattern such as "*.c"

   Outputs-
	patt 
        - If pattern matched patt now has a list of file names.
             Otherwise patt is not changed.
*/
void VMSCmdGlob (VMSCmdLineElement *patt)
{
    ListInfo listinfo;
    char buffer[MAXPATHLEN], *buf = buffer;
    char *p;

    listinfo.head = listinfo.tail = 0;

    if (patt->len >= MAXPATHLEN)
	buf = ruby_xmalloc(patt->len + 1);

    strncpy (buf, patt->str, patt->len);
    buf[patt->len] = '\0';

    for (p = buf; *p; p = CharNext(p))
	if (*p == '\\')
	    *p = '/';
    rb_globi(buf, insert, (VALUE)&listinfo);
    if (buf != buffer)
	free(buf);

    if (listinfo.head && listinfo.tail) {
	listinfo.head->prev = patt->prev;
	listinfo.tail->next = patt->next;
	if (listinfo.head->prev)
	    listinfo.head->prev->next = listinfo.head;
	if (listinfo.tail->next)
	    listinfo.tail->next->prev = listinfo.tail;
    }
    if (patt->flags & VMSMALLOC)
	free(patt->str);
    // free(patt);  //TODO:  memory leak occures here. we have to fix it.
}

/*!
   Purpose-
	Take a flattened command line and construct an argument list.
        (like argv in main)

   Inputs-
	cmdline 
        -  Flattened command line string.
   	InputCmd 
        - TRUE if cmdline is internal command FALSE otherwise.

   Outputs-
	vec
        - New vector containing a the list of command line
          arguments that were parsed from cmdline.
 
   Notes-
	vec dynamically allocates memory to store the command vector
        produced from cmdline: it must be freed. 
*/
int   VMSMakeCmdVector (char *cmdline, char ***vec, int InputCmd)
{
    int cmdlen = strlen(cmdline);
    int done, instring, globbing, quoted, len;
    int newline, need_free = 0, i;
    int elements, strsz;
    int slashes = 0;
    char *ptr, *base, *buffer, *cmdLineSave;
    char **vptr;
    char quote;
    VMSCmdLineElement *curr;

    //
    // just return if we don't have a command line
    //

    if (cmdlen == 0) {
	*vec = NULL;
	return 0;
    }

    cmdLineSave = cmdline;
    cmdline = strdup(cmdline);
   
    //
    // strip trailing white space
    //

    ptr = cmdline+(cmdlen - 1);
    while(ptr >= cmdline && ISSPACE(*ptr))
        --ptr;
    *++ptr = '\0';


    //
    // Ok, parse the command line, building a list of CmdLineElements.
    // When we've finished, and it's an input command (meaning that it's
    // the processes argv), we'll do globing and then build the argument 
    // vector.
    // The outer loop does one interation for each element seen. 
    // The inner loop does one interation for each character in the element.
    //

    for (done = 0, ptr = cmdline; *ptr;) {

	//
	// zap any leading whitespace
	//

	while(ISSPACE(*ptr))
	    ptr++;
	base = ptr;

	for (done = newline = globbing = instring = quoted = 0; 
	     *ptr && !done; ptr++) {

	    //
	    // Switch on the current character. We only care about the
	    // white-space characters, the  wild-card characters, and the
	    // quote characters.
	    //

	    switch (*ptr) {
	      case '\\':
	        if (ptr[1] == '"') ptr++;
	        break;
	      case ' ':
	      case '\t':
#if 0
	      case '/':  // have to do this for NT/DOS option strings

		//
		// check to see if we're parsing an option switch
		//

		if (*ptr == '/' && base == ptr)
		    continue;
#endif
		//
		// if we're not in a string, then we're finished with this
		// element
		//

		if (!instring)
		    done++;
		break;
	      case '*':
	      case '?':

		// 
		// record the fact that this element has a wildcard character
		// N.B. Don't glob if inside a single quoted string
		//

		if (!(instring && quote == '\''))
		    globbing++;
		break;

	      case '\n':

		//
		// If this string contains a newline, mark it as such so
		// we can replace it with the two character sequence "\n"
		// (cmd.exe doesn't like raw newlines in strings...sigh).
		//

		newline++;
		break;

	      case '\'':
	      case '\"':

		//
		// if we're already in a string, see if this is the
		// terminating close-quote. If it is, we're finished with 
		// the string, but not neccessarily with the element.
		// If we're not already in a string, start one.
		//

		if (instring) {
		    if (quote == *ptr) {
			instring = 0;
			quote = '\0';
		    }
		}
		else {
		    instring++;
		    quote = *ptr;
		    quoted++;
		}
		break;
	    }
	}

	//
	// need to back up ptr by one due to last increment of for loop
	// (if we got out by seeing white space)
	//

	if (*ptr)
	    ptr--;

	//
	// when we get here, we've got a pair of pointers to the element,
	// base and ptr. Base points to the start of the element while ptr
	// points to the character following the element.
	//

	curr = ALLOC(VMSCmdLineElement);
	memset (curr, 0, sizeof(*curr));

	len = ptr - base;

	//
	// if it's an input vector element and it's enclosed by quotes, 
	// we can remove them.
	//

	if (InputCmd && !instring && (base[0] == '\"' && base[len-1] == '\"')) {
	    char *p;
	    base++;
	    len -= 2;
	    base[len] = 0;
	    for (p = base; p < base + len; p++) {
		if ((p[0] == '\\' || p[0] == '\"') && p[1] == '\"') {
		    strcpy(p, p + 1);
		    len--;
		}
	    }
	}
	else if (InputCmd && !instring && (base[0] == '\'' && base[len-1] == '\'')) {
	    base++;
	    len -= 2;
	}

	curr->str = base;
	curr->len = len;
	curr->flags |= (globbing ? VMSGLOB : 0);

	//
	// Now put it in the list of elements
	//
	if (VMSCmdTail) {
	    VMSCmdTail->next = curr;
	    curr->prev = VMSCmdTail;
	    VMSCmdTail = curr;
	}
	else {
	    VMSCmdHead = VMSCmdTail = curr;
	}
    }

    if (InputCmd) {

	//
	// When we get here we've finished parsing the command line. Now 
	// we need to run the list, expanding any globbing patterns.
	//
	
	for(curr = VMSCmdHead; curr; curr = curr->next) {
	    if (curr->flags & VMSGLOB) {
		VMSCmdGlob(curr);
	    }
	}
    }

    //
    // Almost done! 
    // Count up the elements, then allocate space for a vector of pointers
    // (argv) and a string table for the elements.
    // 

    for (elements = 0, strsz = 0, curr = VMSCmdHead; curr; curr = curr->next) {
	elements++;
	strsz += (curr->len + 1);
    }

    len = (elements+1)*sizeof(char *) + strsz;
    buffer = ALLOC_N(char, len);
    
    memset (buffer, 0, len);

    //
    // make vptr point to the start of the buffer
    // and ptr point to the area we'll consider the string table.
    //
    //   buffer (*vec)
    //   |
    //   V       ^---------------------V
    //   +---+---+---+---+---+---+---+---+---+---+---+---+---+---+---+
    //   |   |       | ....  | NULL  |   | ..... |\0 |   | ..... |\0 |...
    //   +---+---+---+---+---+---+---+---+---+---+---+---+---+---+---+
    //   |-  elements+1             -| ^ 1st element   ^ 2nd element

    vptr = (char **) buffer;

    ptr = buffer + (elements+1) * sizeof(char *);

    for (curr =  VMSCmdHead; curr;  curr = curr->next) {
	strncpy (ptr, curr->str, curr->len);
	ptr[curr->len] = '\0';
	*vptr++ = ptr;
	ptr += curr->len + 1;
    }
    VMSFreeCmdLine();
    *vec = (char **) buffer;
    free(cmdline);
    cmdline = cmdLineSave;
    return elements;
}

static int
is_socket(int fd)
{
    int type;
    size_t len;

    len = sizeof(type);
    if (getsockopt(fd, SOL_SOCKET, SO_TYPE, (void *)&type, &len) == 0)
        return 1;
    if (errno == ENOTSOCK) errno = 0;

    return 0;
}

#undef select

int
rb_vms_select(int maxfd, fd_set *rfd, fd_set *wfd, fd_set *efd, struct timeval *tv) {
    int i, maxsock, ret, socks, nsocks;
    fd_set rs, ws, es, *rp = 0, *wp = 0, *ep = 0;
    struct timeval z;

    FD_ZERO(&rs);
    FD_ZERO(&ws);
    FD_ZERO(&es);

    /* count socket and non-socket fds, and move socket bits to local
     * fd_sets */
    maxsock = socks = nsocks = 0;
    if (rfd || wfd || efd) {
	for (i = 0; i < maxfd; ++i) {
	    int r = (rfd != 0) && FD_ISSET(i, rfd);
	    int w = (wfd != 0) && FD_ISSET(i, wfd);
	    int e = (efd != 0) && FD_ISSET(i, efd);
	    if (!r && !w && !e) continue;
	    if (is_socket(i)) {
		if (r) {
		    FD_SET(i, (rp = &rs));
		    FD_CLR(i, rfd);
		}
		if (w) {
		    FD_SET(i, (wp = &ws));
		    FD_CLR(i, wfd);
		}
		if (e) {
		    FD_SET(i, (ep = &es));
		    FD_CLR(i, efd);
		}
		maxsock = i + 1;
		socks++;
	    }
	    else {
		nsocks += r + w + e;
	    }
	}
    }

    if (!nsocks) {
	/* sockets only */
        ret = select(maxsock, rp, wp, ep, tv);
        if (rfd) *rfd = rs;
        if (wfd) *wfd = ws;
        if (efd) *efd = es;
	return ret;
    }

    if (!socks) {
	/* assuming non-socket fds are always ready */
	return nsocks;
    }

    /* check if sockets are ready */
    z.tv_sec = 0;
    z.tv_usec = 0;
    ret = select(maxsock, rp, wp, ep, &z);
    if (ret <= 0) {
	return nsocks;
    }

    /* copy set bits back */
    for (i = 0; i < maxsock; ++i) {
	if (rp && FD_ISSET(i, rp)) FD_SET(i, rfd);
	if (wp && FD_ISSET(i, wp)) FD_SET(i, wfd);
	if (ep && FD_ISSET(i, ep)) FD_SET(i, efd);
    }
    ret += nsocks;

    return ret;
}

/* need in ruby/io.c. */
int ReadDataPending()
{
        return 0;
}

