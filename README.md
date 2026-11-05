# MapleStory v83 (Cosmic) for AMP

AMP Generic Module template that runs a [Cosmic](https://github.com/P0nk/Cosmic) v83 MapleStory server
inside AMP's container (cubecoders/ampbase:debian, host networking).

* The server files (Java runtime, Server.jar, wz, scripts, config.yaml) are copied into the instance's
  `cosmic/` folder by `amp/deploy-amp.sh` in the Cosmic project. The template downloads nothing itself.
* The MySQL database runs separately in Docker on the host, at 127.0.0.1:3307.
* Login listens on 7574 and channels on 7575-7577 (world 1, channels 1-3).

Add to AMP under Configuration -> Instance Management -> Configuration Repositories as
`Jes7pwn/maplestory-amp:main`, then Fetch Latest.
