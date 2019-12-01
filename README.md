# GoDaddy hook for `dehydrated`

This is a hook for the [Let's Encrypt](https://letsencrypt.org/) ACME client [dehydrated](https://github.com/lukas2511/dehydrated) (previously known as `letsencrypt.sh`) that allows you to use [GoDaddy](https://www.GoDaddy.com/) [APIs](https://developer.godaddy.com/) DNS records to respond to `dns-01` challenges. Requires bash and your GoDaddy API Key and Secret being in the environment.

## Installation

```
$ cd ~
$ git clone https://github.com/lukas2511/dehydrated
$ cd dehydrated
$ mkdir hooks
$ git clone https://github.com/SeattleDevs/letsencrypt-GoDaddy-hook.git hooks/godaddy
```

## Configuration

Your Godady API ey and secret are expected to be in the environment.  If you do not have a key and secret yet, go to [Godady APIs getting started](https://developer.godaddy.com/getstarted) to obtain them.
If the API key and secret values are not in the enviornment yet, set them up by the following commands in bash:

```
$ export GODADDY_KEY='example-key'
$ export GODADDY_SECRET='example-secret'
```

## Usage

```
$ ./dehydrated -c -d example.com -t dns-01 -k 'hooks/godaddy/hook.sh'
```
