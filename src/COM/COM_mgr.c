/* *****************************************************************************
**
**                       DE10 standard project
**
** Project      : DE10 standard project
** Module       : COM_Mgr
**
** Description  : Communication manager. That is essentially TCP socket put in
**                threads.
**
** ************************************************************************** */

/* *****************************************************************************
**  REVISION HISTORY
** Date         Inits   Description
** ----------------------------------------------------------------------------
** 10.08.17     bd      [no issue number] File creation
**
** ************************************************************************** */

/* *****************************************************************************
**                          SYSTEM INCLUDE FILES
** ************************************************************************** */
#include "Macros.h" /* Divers macros definitions */
#include "Types.h"  /* Legacy types definitions */

#include <pthread.h>  /* posix thread defns */
#include <stdio.h>    /* Standard IO defns */
#include <stdlib.h>   /* Standard lib C defns */
#include <string.h>   /* String defns */
#include <unistd.h>   /* Types defns */

/* Now here for testing purposes */
#include <sys/socket.h>
#include <sys/types.h>
#include <netinet/in.h>
#include <netinet/tcp.h>
#include <netdb.h>
/* *****************************************************************************
**                          NON-SYSTEM INCLUDE FILES
** ************************************************************************** */
#include "COM_mgr.h" /* Dealing with threads, client and server */

/* Protocol definitions */
#if 0
#include "stratum.h" /* Dealing with the protocol layer, TCP, sockets */
#endif
/* *****************************************************************************
**                          ENUM & MACRO DEFINITIONS
** ************************************************************************** */
#define NUM_COM_CLIENT (1) /* number of running client simultaneously */
#define RBUFSIZE 8192
#define RECVSIZE (RBUFSIZE - 4)

typedef enum
{
    eCOM_MGR_PRCL_GETWORK=0,
    eCOM_MGR_PRCL_STRATUM

} eCOM_Mgr_PrtcType_t;

/* *****************************************************************************
**                              TYPE DEFINITIONS
** ************************************************************************** */
typedef struct
{
    /* Empty for now */
} COM_Mgr_Result_t;

/* Need perhaps a connection descriptor something where we can register connection related data */
typedef struct
{
    pthread_t *astThId;
    pthread_attr_t *astAttr;
    const dword dwNumClients;
    const eCOM_Mgr_PrtcType_t ePrclType;

} COM_Mgr_Cnx_t;

typedef struct
{
    COM_Mgr_Cnx_t const* pstCnx;
    dword dwCnxNum;

    /* Usefull for statistic display */

} COM_Mgr_Desc_t;

/* Modules private data */
typedef struct
{
    dword dwErrCnt;
    dword dwThStatus;
    dword dwAttrStatus;

} COM_Mgr_Data_t;

/* *****************************************************************************
**                                 GLOBALS
** ************************************************************************** */

/* *****************************************************************************
**                                 LOCALS
** ************************************************************************** */
/* Stratum connection declaration */
static pthread_t astThIdStrtm[NUM_COM_CLIENT];
static pthread_attr_t astAttrStrtm[NUM_COM_CLIENT];

static COM_Mgr_Cnx_t astCOM_Mgr_Cnx[] =
{
    {
        &astThIdStrtm[0],
        &astAttrStrtm[0],
        NUM_COM_CLIENT,
        eCOM_MGR_PRCL_STRATUM
    }
};

static COM_Mgr_Desc_t stLocalDesc =
{
    &astCOM_Mgr_Cnx[0],
    mArraySize(astCOM_Mgr_Cnx)
};

static COM_Mgr_Data_t stLocalData;

/* *****************************************************************************
**                              LOCALS ROUTINES
** ************************************************************************** */
static void ResetData(void);
static void* CnxClient(void* pvData); /* That is the client thread. That will move */

/* *****************************************************************************
**                                  API
** ************************************************************************** */
dword COM_Mgr_Setup(void)
{
    dword dwRetVal;
    word byIndex;
    word byIndexTh;

    /* Initialise local variables */
    dwRetVal = 0;

    /* Reset modules private data */
    ResetData();

    /* Shall we clean up the result here ? */

    /* Visit connection list */
    for( byIndex=0; byIndex < mArraySize(astCOM_Mgr_Cnx); byIndex++ )
    {
        memset( (void*)&astCOM_Mgr_Cnx[byIndex].astAttr[0],
                (sizeof(pthread_t)*astCOM_Mgr_Cnx[byIndex].dwNumClients),
                0x00 );

        memset( (void*)&astCOM_Mgr_Cnx[byIndex].astAttr[0],
                (sizeof(pthread_attr_t)*astCOM_Mgr_Cnx[byIndex].dwNumClients),
                0x00 );
    }

    /* Prepare connection start */
    for( byIndex=0; byIndex < stLocalDesc.dwCnxNum; byIndex++ )
    {
        if( eCOM_MGR_PRCL_STRATUM == stLocalDesc.pstCnx[byIndex].ePrclType )
        {
            /* Start init the stratum prot */
        }

        /* old getwork protocol support */
        if( eCOM_MGR_PRCL_GETWORK == stLocalDesc.pstCnx[byIndex].ePrclType )
        {
            /* Start init the getwork prot */
        }

        /* Prepare threads */
        for( byIndexTh=0; byIndexTh < stLocalDesc.pstCnx[byIndex].dwNumClients; byIndexTh++ )
        {
            pthread_attr_init(&stLocalDesc.pstCnx[byIndex].astAttr[byIndexTh]);
            pthread_attr_setdetachstate(&stLocalDesc.pstCnx[byIndex].astAttr[byIndexTh], PTHREAD_CREATE_JOINABLE);
        }
    }

    return dwRetVal;
}

dword COM_Mgr_Init(void)
{
    dword dwRetVal;
    word byIndex;
    word byIndexTh;

    /* Initial locals */
    dwRetVal = 0;

    /* Prepare connection start */
    for( byIndex=0; byIndex < stLocalDesc.dwCnxNum; byIndex++ )
    {
        /* Prepare threads */
        for( byIndexTh=0; byIndexTh < stLocalDesc.pstCnx[byIndex].dwNumClients; byIndexTh++ )
        {
            if ( 0 != pthread_create( &stLocalDesc.pstCnx[byIndex].astThId[byIndexTh],
                                      NULL,
                                      CnxClient,
                                      NULL )
               )
            {
                /* Update return variable consequently */
                dwRetVal = 1;
                printf("ERROR; return code from pthread_create()\n");
            }
        }
    }

    return dwRetVal;
}

/* Things to do in the background task */
dword COM_Mgr_Bkgnd(void)
{
    dword dwRetVal;

    dwRetVal = 0;

    /* Monitor clients and connections */

    /* Client connection recovery strategy ? */

    return dwRetVal;
}

/* *****************************************************************************
**                            LOCALS ROUTINES Defn
** ************************************************************************** */
static void ResetData(void)
{
    memset((void*)&stLocalData,sizeof(COM_Mgr_Data_t),0x00);
    return;
}

static void* CnxClient(void* pvData)
{
    printf("Connection test\n");
	struct addrinfo *servinfo;
	struct addrinfo hints;
	struct addrinfo *p;
	char *sockaddr_url, *sockaddr_port;
	int sockd;
	int swork_id;
	ssize_t ssent = 0;
	char s[RBUFSIZE];
	int reqsize;

	swork_id=1;

	memset(&hints, 0, sizeof(struct addrinfo));
	hints.ai_family = AF_UNSPEC;
	hints.ai_socktype = SOCK_STREAM;

	sockaddr_url = "eu.stratum.slushpool.com";
	sockaddr_port = "3333";

	if (getaddrinfo(sockaddr_url, sockaddr_port, &hints, &servinfo) != 0)
	{
		printf("\nTEST FAIL 0\n");
	}

	for (p = servinfo; p != NULL; p = p->ai_next) {
		sockd = socket(p->ai_family, p->ai_socktype, p->ai_protocol);
		if (sockd == -1) {
			printf("TEST FAIL 1\n");
			continue;
		}

		/* Iterate non blocking over entries returned by getaddrinfo
		 * to cope with round robin DNS entries, finding the first one
		 * we can connect to quickly. */
#if 0
		noblock_socket(sockd);
#endif
		if (connect(sockd, p->ai_addr, p->ai_addrlen) == -1) {
			printf("Failed sock connect\n");
#if 0
			struct timeval tv_timeout = {1, 0};
			int selret;
			fd_set rw;
			if (!sock_connecting()) {
				CLOSESOCKET(sockd);
				continue;
			}

			while(selret < 0 && interrupted())
   		    {
				FD_ZERO(&rw);
				FD_SET(sockd, &rw);
				selret = select(sockd + 1, NULL, &rw, NULL, &tv_timeout);
				if  (selret > 0 && FD_ISSET(sockd, &rw)) {
					socklen_t len;
					int err, n;

					len = sizeof(err);
					n = getsockopt(sockd, SOL_SOCKET, SO_ERROR, (void *)&err, &len);
					if (!n && !err) {
						printf("Succeeded delayed connect\n");
						block_socket(sockd);
						break;
					}
				}
			}

			close(sockd);
			printf("Select timeout/failed connect\n");
			continue;
#endif
		}
		printf("Succeeded immediate connect\n");
#if 0
		block_socket(sockd);
#endif

		sprintf(s, "{\"id\": %d, \"method\": \"mining.subscribe\", \"params\": []}", swork_id++);
		strcat(s, "\n");
		reqsize = strlen(s);

		while ( reqsize > 0 ) {
			struct timeval timeout = {1, 0};
			ssize_t sent;
			fd_set wd;

			FD_ZERO(&wd);
			FD_SET(sockd, &wd);
			if (select(sockd + 1, NULL, &wd, NULL, &timeout) < 1) {
				printf("Send select failed\n");
			}
			else
			{
				printf("Select send success\n");
			}

			sent = send(sockd, s + ssent, reqsize, MSG_NOSIGNAL);

			if (sent < 0) {
				sent = 0;
			}
			ssent += sent;
			reqsize -= sent;
		}


		/* Now receive */
		do {
			char srec[RBUFSIZE];
			ssize_t n;
			memset(srec, 0, RBUFSIZE);
			n = recv(sockd, srec, RECVSIZE, 0);
			if (!n) {
				printf("Socket closed waiting in recv_line\n");
			}

			printf("recv_line : %s\n",srec);

			if(!strstr(srec, "\n"))
			{
				break;
			}
		} while (1);

		break;
	}

    pthread_exit(NULL);
}
