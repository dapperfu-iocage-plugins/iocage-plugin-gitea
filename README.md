# FreeNAS/FreeBSD ```iocage``` Gitea Plugin.

Adapted from [FreeNAS Gitea Tutorial.](https://github.com/jed-frey/FreeNAS-Gitea)

Features:

- [Gitea: A painless self-hosted Git service.](https://github.com/go-gitea/gitea) [src](https://github.com/go-gitea/gitea). *Gitea is a community managed fork of Gogs, lightweight code hosting solution written in Go and published under the MIT license.*
- MySQL database, to support more users than the default sqlite3 db.
- Redis for cache and session provider.
- NGINX reverse proxy. HTTP redirects to HTTPS.
- SSL enabled. Self-signed.
- SSH enabled (for git user only).

## Installation Instructions.

```
curl -o /tmp/gitea.json https://raw.githubusercontent.com/jed-frey/iocage-plugin-gitea/11.2-RELEASE/gitea.json
iocage fetch --plugin-file --name /tmp/gitea.json ip4_addr="lagg0|192.168.1.220/24"
```

# Corrections & Issues

The only real way to test this is re-creating a jail, so after a while it gets tedius. If you find something doesn't work, open an issue.

If you know how to correct the issue, create a pull request with the fixes.

# Acknowledgments

👍: [This execellent example tutorial on how to create a plugin.](https://www.ixsystems.com/community/resources/create-an-unofficial-iocage-plugin.99/)

👎: [IXSystem's documentation for creating a plugin.](https://www.ixsystems.com/documentation/freenas/11.2/plugins.html#create-a-plugin)

