# erichough/duplicacy

[Duplicacy Web Edition](https://forum.duplicacy.com/t/duplicacy-web-edition-0-2-10-beta-is-now-available/1606/26) in a container.

*This image is experimental and subject to change.*

## Usage

1. `docker run -p 3875:3875 erichough/duplicacy` 

1. Visit [`http://localhost:3875`](http://localhost:3875)

## Tips and tricks

1. Bind-mount a host directory into the container at `/etc/duplicacy` to view and manage your configuration files (i.e. `duplicacy.json` and `settings.json`).
1. Add `--cap-drop=ALL` for extra security.
1. Add `--restart=always` to be able to make changes via the settings page.

## Sample `docker-compose.yml`

```yaml
version: '3.7'
services:
  duplicacy:
    image: erichough/duplicacy
    restart: always
    ports:
      - 3875:3875
    cap_drop:
      - ALL
    volumes:
      - /host/path/to/config:/etc/duplicacy
      - /host/path/to/some-storage:/storage
```
