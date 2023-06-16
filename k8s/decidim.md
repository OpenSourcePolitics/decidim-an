# k8s setup

This is a temporary setup, where we move AN to a prod k8s cluster with yaml files.
In a second phase, we’ll migrate from yaml files to [decidim operator](https://forge.liiib.re/libre.sh/decidim-operator).

## Debug

In order to debug traffic, you can try to sh into web container:
```
k exec -it decidim-an-deployment-xxx-yyy -c web sh
```

And then try to reach the app container:
```
curl localhost:3000 -v --header "X-Forwarded-Proto: https" --header "Host: ppan-pprod.opensourcepolitics.net"