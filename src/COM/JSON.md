Stratum Mining Protocol

This is the official documentation of lightweight bitcoin mining protocol.

If you’re looking for Stratum mining proxy, please visit mining proxy howto.
If you’re looking for mining software compatibility, please go to the compatibility section.
Content

    Why to Change Something That Works?
        HTTP: Communication Is Driven by Miners...
        Ntime Rolling: Not Enough Job for Fast Miners
        Long Polling: An Anti-Pattern
    How to Fix All That?
        Stratum Protocol
        Extranonce Rolling: The New Dimension
        Other Decisions
    For Mining Software Developers
        Exception Handling
        Real-World Example
    Downloads
    Compatible Miners

This page is both a technical documentation and advocacy of the new mining protocol which can be used for bitcoin mining. If you're a casual miner or just a regular bitcoin user, then you don't have to understand everything in this document.

The main reason why I designed this protocol and implemented opensource pool server is that the current getwork&LP mining protocol has many flaws and it can hardly be used in any large-scale setup. ASIC miners are probably coming at the end of the year 2012, so Bitcoin community definitely needs some solution, which will easily scale to tera-hashes per second per pool user...
1. Why to Change Something That Works?
HTTP: Communication is Driven by Miners...

... However pool server knows much better when clients need new mining jobs. HTTP was designed for web site browsing where clients ask servers for specific content. Pooled mining is different - server knows very well what clients need and can control the communication in a more efficient way. Let’s swap roles and leave orchestration to the server!
Ntime Rolling: Not Enough Jobs For Fast Miners

Nowadays, for every received job from the server, a miner can modify only ntime and nonce. Nonce is a 32bit integer (4.2 billion of iterations). Ntime is a 32bit integer storing UNIX timestamp and should reflect current time, although optimized miners roll ntime slightly into the future, which gives more combinations to miners (nonce range * ntime range). However, a block created from massively modified ntime can be rejected by Bitcoin network.

Strictly following getwork specification, one getwork job is enough for 4.2GHash/s mining rig and (thanks to ntime rolling) this job is usable for one minute or until a new Bitcoin block arrives (depending on what happens first). So, for 42 GHash/s rig you’ll need 10 getwork requests at once, but usually a few more because of some pre-caching strategies implemented by miners to prevent idling on network latencies. And what about 1 THash/s ASIC miners coming soon? We simply need some solution where network load is not at all bounded to miners performance.
Long Polling: An Anti-Pattern

Getwork came as an easy solution for building standalone miners (do you remember when the official Bitcoin client was the only miner?), much before I built my first Bitcoin pool and when frequent polling of local bitcoin daemon wasn't an issue. When pools came into the game, people found out that they must decide between short polling intervals (=higher network load, lower stale ratio) and intervals, which don't overload network and servers, but lead to a much higher ratio of rejected shares. And long polling pattern was the answer. Long polling is a great way to achieve real-time updates using standard web technologies. But as I already mentioned in the text above, web technologies are not ideal for Bitcoin mining.

Long polling uses separate connection to pool server, which leads to various issues on server side, like load balancing of connections between more backends. Load balancing using IP hashes or sticky HTTP sessions are just another workarounds for keeping all that stuff working.

Another problem consists of packet storms, coming from clients trying to reconnect to the server after long polling broadcasts. Sometimes it's hard to distinguish valid long polling reconnections from DDoS attacks. All this makes pool architecture more complicated and harder to maintain, which is reflected in less reliable pool service and has a real impact on miners.

The solution for such issues is related to the previous point about driving load by the server and not by thousands of (sometimes) strangely implemented miners, who are aggressively trying to reach the server.
2. How Can We Fix All That?

Now we know what's wrong in the current situation, so let's design a new protocol and don't repeat bad decisions again:
Stratum Protocol

I originally designed Stratum protocol for lightweight Bitcoin client called Electrum. Later I found out that protocol requirements are quite similar to requirements for bitcoin mining, so I decided to reuse it as-is. Don't be confused by an esoteric protocol name, I tried to stick to standards as much as possible.

In a simplified manner, Stratum is a line-based protocol using plain TCP socket, with payload encoded as JSON-RPC messages. That's all. Client simply opens TCP socket and writes requests to the server in the form of JSON messages finished by the newline character \n. Every line received by the client is again a valid JSON-RPC fragment containing the response.

There are good reasons for such solution: it is very easy to implement and very easy to debug, because both sides are talking in human-readable format. The protocol is unlike many other solutions easily extensible without messing up the backwards compatibility. As a bonus, JSON is widely supported on all platforms and current miners already have JSON libraries included. So packing and unpacking of the message is really simple and convenient.

There's no HTTP overhead involved and there're no hacks like mining extension flags encoded in HTTP headers anymore. But the biggest improvement from HTTP-based getwork is the fact, that server can drive the load by itself, it can send broadcast messages to miners at any time without any long-polling workarounds, load balancing issues and packet storms.
Extranonce Rolling: The New Dimension

This is probably the most innovative part of the new protocol. In contrary to current mining where only ntime and nonce can be iterated, Stratum mining protocol gives a power to miners to easily build unique coinbase transactions locally, so they'll be able to produce unique block headers locally. I recommend to iterate four bytes of extranonce, which gives the possibility to serve 18 EHash/s (Exa-hashes/s) mining rig from a single TCP connection. But it can be easily changed by the pool operator anytime.

Now it is going to be a bit technical, so let's explain it a bit. Block header (that string what is in getwork response and what miners are hashing) is composed from following parts:

    Block version, nbits, hash of previous block in the blockchain and some padding bytes, which are constants.
    Nonce and ntime, which miner can modify already.
    Merkle root hash, which is created by hashing of bitcoin transactions included in the particular mining job.

To produce more unique block headers (and thus be able to generate more unique hashes), we have to modify something.

Every bitcoin block contains so-called coinbase transaction which specify the bitcoin address for sending block reward. Fortunately there's a chance to modify this transaction without breaking anything. By changing coinbase transaction, merkle root will change and we will have unique block header to hash. Currently this (creating unique coinbase) happens on pool servers. So let's move it to miners!
Other Decisions
JSON Versus Your-Preferred-Protocol

I considered many solutions for serializing and deserializing message payloads. I wrote some reasons for JSON above, but let's sumarize them again:

    JSON payload is human readable, easy to implement and debug.
    All bitcoin miners already have JSON libraries included. JSON has native support in almost every language.
    In contrary of most binary protocol, JSON payload can be easily extended without breaking backward compatibility.
    JSON-RPC already specifies three native message types which Stratum uses: request, response and notification. We don't need to reinvent a wheel.
    JSON has definitely some data overhead, but Stratum mining messages typically fits into one TCP packet...

Why I throw away other serializers:

    Custom text protocol is human readable and easy to debug, but not so easy to implement as it may look at first glance. We have to define a way how to pair request and response, because sequential processing of requests may be a bit tricky on some platforms (yes, now I'm referring Twisted framework which I used for pool implementation). We also have to define how to serialize various data types like lists or even mappings. JSON solve all this transparently for us.
    Custom binary protocol is the most compact form which can saves a lot of bandwith, especially while dealing with binary data involved in bitcoin mining. However writing (de)serializers *properly* may be a bit tricky. I wanted the protocol which is easy to implement. Fiddling with byte order and binary headers is not what I was looking for.
    Protocol buffers by Google is interesting concept which may fit the needs, except that only C++, Python and Java are supported.
    Thrift is another binary protocol which I used some time ago, but it is defitely too heavy for our purposes.

Stratum Versus Getblocktemplate

Getblocktemplate introduced in bitcoind 0.7 is a very progressive solution for delegating block creation from full bitcoin client to standalone, specialized software. Stratum mining server uses getblocktemplate mechanism under the hood. There are still some reasons why Stratum is, in my opinion, a better solution for pooled mining:

    It is less complex, much easier to implement in existing miners and it still does the job perfectly.
    For historical reasons getblocktemplate still uses HTTP protocol and long polling mechanism. I described above why this fails on large scale mining.
    Stratum scales much better for rising amount of processed Bitcoin transactions, because it transfers only merkle branch hashes, in the contrary to complete dump of server’s memory pool in getblocktemplate.
    Checking submitted shares is also much cheaper on processing resources in Stratum than in getblocktemplate. 

There's really only one reason why Stratum is worse than getblocktemplate solution at this time: miners cannot choose Bitcoin transactions on their own. In my experience 99% of real miners don’t care about transaction selection anyway, they just want the highest possible block reward. At this point they share the same interest with pool operator, so there’s no real reason to complicate mining protocol just for those 1% who want to create custom blocks for the pool.

I already have some ideas for Stratum mining protocol extension, where miners will be able to suggest their own merkle branch (I call it internally “democratic mining”), which will solve such issues as centralized selection of transactions. For now I decided to focus on such a solution, which will fit to majority of miners and do some extensions later.
3. For Mining Software Developers

Stratum protocol is based on JSON-RPC 2.0. In this chapter I expect that you're familiar with this protocol and you understand terms like "request", "response" and "notification". Please read JSON-RPC specification for more details.

For high level image of the Stratum protocol concept, please read Stratum protocol specification on Google docs. This document needs some care, but give you the basic examples how to connect to Stratum server.
Exception Handling

Stratum defines simple exception handling. Example of rejected share looks like:

{"id": 10, "result": null, "error": (21, "Job not found", null)}

Where error field is defined as (error_code, human_readable_message, traceback). Traceback may contain additional information for debugging errors.

Proposed error codes for mining service are:

    20 - Other/Unknown
    21 - Job not found (=stale)
    22 - Duplicate share
    23 - Low difficulty share
    24 - Unauthorized worker
    25 - Not subscribed

Real-World Example

This chapter contains real log of miner-pool communication which solved testnet3 block
000000002076870fe65a2b6eeed84fa892c0db924f1482243a6247d931dcab32
Miner Connects the Server

On the beginning of the session, client subscribes current connection for receiving mining jobs:

{"id": 1, "method": "mining.subscribe", "params": []}\n
{"id": 1, "result": [ [ ["mining.set_difficulty", "b4b6693b72a50c7116db18d6497cac52"], ["mining.notify", "ae6812eb4cd7735a302a8a9dd95cf71f"]], "08000002", 4], "error": null}\n

The result contains three items:

    Subscriptions details - 2-tuple with name of subscribed notification and subscription ID. Teoretically it may be used for unsubscribing, but obviously miners won't use it.
    Extranonce1 - Hex-encoded, per-connection unique string which will be used for coinbase serialization later. Keep it safe!
    Extranonce2_size - Represents expected length of extranonce2 which will be generated by the miner.

Authorize Workers

Now let authorize some workers. You can authorize as many workers as you wish and at any time during the session. In this way, you can handle big basement of independent mining rigs just by one Stratum connection.

{"params": ["slush.miner1", "password"], "id": 2, "method": "mining.authorize"}\n
{"error": null, "id": 2, "result": true}\n

Server Start Sending Notifications With Mining Jobs

Server sends one job *almost* instantly after the subscription.

Small engineering note: There's a good reason why first job is not included directly in subscription response - miner will need to handle one response type in two different way; firstly as a subscription response and then as a standalone notification. Hook job processing just to JSON-RPC notification sounds a bit better to me.

{"params": ["bf", "4d16b6f85af6e2198f44ae2a6de67f78487ae5611b77c6c0440b921e00000000",
"01000000010000000000000000000000000000000000000000000000000000000000000000ffffffff20020862062f503253482f04b8864e5008",
"072f736c7573682f000000000100f2052a010000001976a914d23fcdf86f7e756a64a7a9688ef9903327048ed988ac00000000", [],
"00000002", "1c2ac4af", "504e86b9", false], "id": null, "method": "mining.notify"}

Now we finally have some interesting stuff here! I'll descibe every field of the notification in the particular order:

    job_id - ID of the job. Use this ID while submitting share generated from this job.
    prevhash - Hash of previous block.
    coinb1 - Initial part of coinbase transaction.
    coinb2 - Final part of coinbase transaction.
    merkle_branch - List of hashes, will be used for calculation of merkle root. This is not a list of all transactions, it only contains prepared hashes of steps of merkle tree algorithm. Please read some materials for understanding how merkle trees calculation works. Unfortunately this example don't have any step hashes included, my bad!
    version - Bitcoin block version.
    nbits - Encoded current network difficulty
    ntime - Current ntime/
    clean_jobs - When true, server indicates that submitting shares from previous jobs don't have a sense and such shares will be rejected. When this flag is set, miner should also drop all previous jobs, so job_ids can be eventually rotated.

How to Build Coinbase Transaction

Now miner received all data required to serialize coinbase transaction: Coinb1, Extranonce1, Extranonce2_size and Coinb2. Firstly we need to generate Extranonce2 (must be unique for given job_id!). Extranonce2_size tell us expected length of binary structure. Just be absolutely sure that your extranonce2 generator always produces extranonce2 with correct length! For example my pool implementation sets extranonce2_size=4, which mean this is valid Extranonce2 (in hex): 00000000.

To produce coinbase, we just concatenate Coinb1 + Extranonce1 + Extranonce2 + Coinb2 together. That's all!

For following calculations we have to produce double-sha256 hash of given coinbase. In following snippets I'm using Python, but I'm sure you'll understand the concept even if you're a rubyist! It is as simple as:

import hashlib
import binascii
coinbase_hash_bin = hashlib.sha256(hashlib.sha256(binascii.unhexlify(coinbase)).digest()).digest()

How to Build Merkle Root

Following Python snippet will generate merkle root for you. Use merkle_branch from broadcast and coinbase_hash_bin from previous snippet as an input:

import binascii

def build_merkle_root(self, merkle_branch, coinbase_hash_bin):
        merkle_root = coinbase_hash_bin
        for h in self.merkle_branch:
                merkle_root = doublesha(merkle_root + binascii.unhexlify(h))
        return binascii.hexlify(merkle_root)

How to Build Block Header?

Now we're almost done! We have to put all together to produce block header for hashing:

version + prevhash + merkle_root + ntime + nbits + '00000000' +
'000000800000000000000000000000000000000000000000000000000000000000000000000000000000000080020000'

First zeroes are blank nonce, the rest is padding to uint512 and it is always the same.

Note that merkle_root must be in reversed byte order. If you're a miner developer, you already have util methods there for doing it. For some example in Python see Stratum mining proxy source codes.
Server Can Occasionally Ask Miner to Change Share Difficulty

Default share difficulty is 1 (big-endian target for difficulty 1 is 0x00000000ffff0000000000000000000000000000000000000000000000000000), but server can ask you anytime during the session to change it:
{ "id": null, "method": "mining.set_difficulty", "params": [2]}

This Means That Difficulty 2 Will Be Applied to Every Next Job Received From the Server.
How to Submit Share?

When miner find the job which meets requested difficulty, it can submit share to the server:

{"params": ["slush.miner1", "bf", "00000001", "504e86ed", "b2957c02"], "id": 4, "method": "mining.submit"}
{"error": null, "id": 4, "result": true}

Values in particular order: worker_name (previously authorized!), job_id, extranonce2, ntime, nonce.

That's it!
4. Downloads

    Stratum mining proxy - Source code of Stratum proxy on Github
    Windows binaries (EXE) of Stratum mining proxy - Detailed instructions can be found here.
    Stratum mining pool - Opensource bitcoin mining pool build on Stratum server framework in Python.

5. Compatible Miners

For all current getwork-compatible miners you can use Stratum mining proxy running locally on your mining computer. One mining proxy can handle (almost) unlimited number of connected workers, so running one proxy for all of your mining rigs is a way to go.

Miners with native support of Stratum protocol (no proxy needed!)

    bfgminer
    cgminer (version 2.8.1 and newer)
    poclbm (version 20120920 and newer)

If you want support of Stratum protocol in your miner, just ask its developer and show him this page. Also don't hesitate to contact me and ask for implementation details.