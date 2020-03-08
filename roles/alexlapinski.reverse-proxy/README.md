# Nginx Reverse Proxy

Setup a virtual site within Nginx to act as a reverse proxy.

## Requirements
 * **Nginx** - must be installed and configured

## Role Variables
 * ``site_domain`` - The domain (name of the site) to use for the nginx virtual site.
 * ``target_port`` - The target port of the app to redirect the incoming traffic to.

## Dependencies
 * Nginx

## Example Playbook
```
- name: reverse_proxy
  vars:
    site_domain: cam.local.net
    target_port: 8765
```

## License

MIT

## Author Information

Alex Lapinski <contact@alexlapinski.name>