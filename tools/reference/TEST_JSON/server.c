/*
 * server.c
 *
 *  Created on: 2017 aug. 9
 *      Author: BDJ2Bp
 */
#include <stdio.h>
#include <stdlib.h>
#include <unistd.h>
#include <errno.h>
#include <string.h>
#include "json/json.h"
#include <sys/types.h>
#include <sys/socket.h>
#include <arpa/inet.h>

int main()
{
    int listenfd = 0, connfd = 0;   //related with the server
    struct sockaddr_in serv_addr;

    //json_object * jobj;
    uint8_t buf[158], i;

    memset(&buf, '0', sizeof(buf));
    listenfd = socket(AF_INET, SOCK_STREAM, 0);

    serv_addr.sin_family = AF_INET;
    serv_addr.sin_addr.s_addr = htonl(INADDR_ANY);
    serv_addr.sin_port = htons(8888);

    bind(listenfd, (struct sockaddr*)&serv_addr, sizeof(serv_addr));
    printf("binding\n");

    listen(listenfd, 5);
    printf("listening\n");
    connfd = accept(listenfd, (struct sockaddr*)NULL, NULL);

    printf("Reading from client\n");

    while ( (read(connfd, buf, 157)) > 0 )
     {
        for ( i = 0; i < 157; i++ )
        //printf("%s\n", json_object_to_json_string(jobj));
        //json_parse(jobj);
        printf("%d\n", buf[i]);
     }

    return 0;
}
