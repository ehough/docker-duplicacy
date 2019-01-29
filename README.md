# erichough/duplicacy

[Duplicacy Web Edition](https://forum.duplicacy.com/t/duplicacy-web-edition-0-2-10-beta-is-now-available/1606/26) in a container.

*This image is experimental and subject to change.*

## Usage

1. `docker run -p 3875:3875 erichough/duplicacy` 

1. Visit [`http://localhost:3875`](http://localhost:3875)

## Tips and tricks

1. Bind-mount a host directory into the container at `/etc/duplicacy` to view, edit, and/or backup your configuration files (i.e. `duplicacy.json` and `settings.json`).
1. Add `--cap-drop=ALL` for extra security.
1. Add `--restart=always` to be able to make changes via the settings page.

## Duplicacy license

*NOTE: If you don't need to purchase a Duplicacy license, you can safely ignore this section.*

Duplicacy identifies the machine via the hostname and [`machine-id`](https://www.freedesktop.org/software/systemd/man/machine-id.html) pair. So in order to utilize a license, you'll need to make sure that both of these pieces of data do not change over time.

1. Add `--hostname` to your to your `docker run` command to set a persistent hostname for the container.
1. Supply a persistent `machine-id`, which is a 32-character lowercase hexadecimal string.

   Here are a few ways to supply a `machine-id`; choose whichever your like:
  
    1. **Option 1**. Bind-mount an existing `machine-id` into the container at `/var/lib/dbus/machine-id`.
    
       e. g. `docker run -v /host/path/to/machine-id:/var/lib/dbus-machine-id:ro ...`
    1. **Option 2**. Supply the `MACHINE_ID` environment variable to the container. You can generate a random string using online tools ([example](https://www.browserling.com/tools/random-hex)).
    
       e.g. `docker run -e MACHINE_ID=b23c9e0140e92b10c2baaf1f82571a2f ...`
    1. **Option 3**. Bake `/var/lib/dbus/machine-id` into a custom image. e.g. in a `Dockerfile`
    
       ```yaml
       FROM erichough/docker-duplicacy
       COPY files/machine-id /var/lib/dbus/machine-id
       ```

## Sample `docker-compose.yml`

```yaml
version: '3.7'
services:
  duplicacy:
    image: erichough/duplicacy
    hostname: duplicacy-web
    restart: always
    ports:
      - 3875:3875
    cap_drop:
      - ALL
    environment:
      MACHINE_ID: 4c601d79a045519397ade28a2f79e3d3
    volumes:
      - /host/path/to/config:/etc/duplicacy
      - /host/path/to/some-storage:/storage
```
